    #include "present.h"
    #include "hexutils.h"
    #include <iostream>
    #include <fstream>
    #include <array>
    #include <vector>
    #include <cstring>

    using namespace std;

    // Total (user + system) CPU time in microseconds for this process.
    long getCpuTimeMicros() {
        struct rusage u{};
        getrusage(RUSAGE_SELF, &u);
        long user_us = u.ru_utime.tv_sec * 1000000L + u.ru_utime.tv_usec;
        long sys_us  = u.ru_stime.tv_sec * 1000000L + u.ru_stime.tv_usec;
        return user_us + sys_us;
    }

    long getMemoryUsageKB() {
        struct rusage usage;
        getrusage(RUSAGE_SELF, &usage);
        #ifdef __APPLE__
            return usage.ru_maxrss / 1024; // macOS reports in bytes
        #else
            return usage.ru_maxrss; // Linux reports in kilobytes
        #endif
    }

    void printUsage() {
        cout << "Usage:\n"
            << "  ./present_cli --mode block --encrypt|--decrypt --key <hexkey> --input <hexdata>\n"
            << "  ./present_cli --mode ctr --encrypt|--decrypt --key <hexkey> --infile <file> --outfile <file> --nonce <hex> --filetype <bmp|bin> --threads 4\n"
            << "Examples:\n"
            << "  ./present_cli --mode block --encrypt --key 00000000000000000000 --input 0000000000000000\n"
            << "  ./present_cli --mode ctr --encrypt --key 00000000000000000000 --nonce 0102030405060708 --filetype bmp --infile input.bmp --outfile output.bmp\n"
            << "  ./present_cli --mode ctr --decrypt --key 00000000000000000000 --nonce 0102030405060708 --filetype bin --infile enc.bin --outfile dec.bin\n";
    }



    int main(int argc, char* argv[]) {
        if (argc < 2) {
            printUsage();
            return 1;
        }

        string mode, action , presentBits = "80";
        string keyHex, inputHex, fileType, infile, outfile, nonceHex;
        int numThreads = 1; // default

        for (int i = 1; i < argc; ++i) {
            if (strcmp(argv[i], "--present") == 0 && i + 1 < argc) presentBits = argv[++i];
            else if (strcmp(argv[i], "--threads") == 0 && i + 1 < argc)numThreads = atoi(argv[++i]);
            else if (strcmp(argv[i], "--mode") == 0 && i + 1 < argc) mode = argv[++i];
            else if (strcmp(argv[i], "--encrypt") == 0) action = "encrypt";
            else if (strcmp(argv[i], "--decrypt") == 0) action = "decrypt";
            else if (strcmp(argv[i], "--key") == 0 && i + 1 < argc) keyHex = argv[++i];
            else if (strcmp(argv[i], "--input") == 0 && i + 1 < argc) inputHex = argv[++i];
            else if (strcmp(argv[i], "--infile") == 0 && i + 1 < argc) infile = argv[++i];
            else if (strcmp(argv[i], "--outfile") == 0 && i + 1 < argc) outfile = argv[++i];
            else if (strcmp(argv[i], "--nonce") == 0 && i + 1 < argc) nonceHex = argv[++i];
            else if (strcmp(argv[i], "--filetype") == 0 && i + 1 < argc) fileType = argv[++i];
        }

        PresentKeySize presentType;
        if (presentBits == "80") presentType = PresentKeySize::PRESENT_80;
        else if (presentBits == "128") presentType = PresentKeySize::PRESENT_128;
        else {
            cerr << "Error: Invalid PRESENT bit size. Use 80 or 128.\n";
            return 1;
        }

        if (keyHex.empty()) {
            cerr << "Error: Key is required.\n";
            return 1;
        }

        vector<uint8_t> key = hexStringToBytes(keyHex);
        PresentKeySize keySize = (key.size() == 10) ? PRESENT_80 :
                            (key.size() == 16) ? PRESENT_128 :
                            throw std::invalid_argument("Key must be 80 or 128 bits.");

        Present present(keySize, key);
        long cpuStartUs = getCpuTimeMicros();

        auto start = chrono::high_resolution_clock::now();

        if (mode == "block") {
        if (inputHex.empty()) {
            cerr << "Error: Input is required for block mode.\n";
            return 1;
        }

        vector<uint8_t> input = hexStringToBytes(inputHex);
        if (input.size() != 8) {
            cerr << "Error: Input must be 64 bits (16 hex chars).\n";
            return 1;
        }

        uint64_t block = 0;
        for (int i = 0; i < 8; ++i)
            block = (block << 8) | input[i];

        uint64_t result = (action == "encrypt")
                            ? present.encryptBlock(block)
                            : present.decryptBlock(block);

        cout << "Output: ";
        for (int i = 7; i >= 0; --i)
            printf("%02llX", (result >> (i * 8)) & 0xFF);
        cout << "\n";
        }

        else if (mode == "ctr") {
        if (infile.empty() || outfile.empty() || nonceHex.empty() || fileType.empty()) {
            cerr << "Error: --infile, --outfile, --nonce, and --filetype are required for CTR mode.\n";
            return 1;
        }

        vector<uint8_t> nonceVec = hexStringToBytes(nonceHex);
        if (nonceVec.size() != 8) {
            cerr << "Error: Nonce must be 64 bits (16 hex chars).\n";
            return 1;
        }

        array<uint8_t, 8> nonce;
        std::copy(nonceVec.begin(), nonceVec.end(), nonce.begin());

        if (fileType == "bmp") {
            if (action == "encrypt")
                present.encryptBMP_CTR(infile, outfile, nonce);
            else
                present.decryptBMP_CTR(infile, outfile, nonce);
        }
        else if (fileType == "bin")
        {
            if (numThreads > 1) 
            {
                if (action == "encrypt" || action == "decrypt") {
                    present.encryptCTR_MT(infile, outfile, nonce, numThreads);
                } 
                else {
                cerr << "Error: Must specify --encrypt or --decrypt.\n";
                return 1;
                }
            } 
            else
            {
                present.encryptCTR(infile, outfile, nonce); // default single-threaded
            }
        }
        else {
            cerr << "Invalid filetype. Use 'bmp' or 'bin'.\n";
            return 1;
        }

        cout << "Operation complete. Output saved to " << outfile << "\n";
        }

        auto end = chrono::high_resolution_clock::now();
        auto duration = chrono::duration_cast<chrono::microseconds>(end - start);
        

        long memUsedKB = getMemoryUsageKB();
        long cpuEndsUs = getCpuTimeMicros();
        long cpuUsedUs = cpuEndsUs - cpuStartUs;

        /*cout << "Performance Summary:\n";
        cout << "Execution Time: " << duration.count() << " µs\n";
        cout << "Peak Memory Usage: " << memUsedKB << " KB\n";
        cout << "Estimated Energy (relative): " << duration.count() * memUsedKB << " units(µs.KB)\n";

        std::ifstream infileSize(infile, std::ios::binary | std::ios::ate);
        std::streamsize fileSize = infileSize.tellg();
        infileSize.close();

        double timePerKB = (fileSize > 0) ? static_cast<double>(duration.count()) / (fileSize / 1024.0) : 0.0;
        double energyPerKB = (fileSize > 0) ? (duration.count() * memUsedKB) / (fileSize / 1024.0) : 0.0;

        cout << "File Size: " << fileSize << " bytes\n";
        cout << "Time per KB: " << timePerKB << " µs/KB\n";
        cout << "Relative Energy per KB: " << energyPerKB << " µs·KB per KB data\n";
    */
        std::cout << "Performance Summary:\n";
    std::cout << "Mode: " << mode << "\n";
    if (!fileType.empty()) std::cout << "Filetype: " << fileType << "\n";
    std::cout << "Threads: " << numThreads << "\n";
    std::cout << "Execution Time (wall): " << duration.count() << " µs\n";
    std::cout << "CPU Time (user+sys): " << cpuUsedUs << " µs\n";
    std::cout << "Peak Memory Usage: " << memUsedKB << " KB\n";
    std::cout << "Estimated Energy (synthetic): " << (duration.count() * memUsedKB) << " µs·KB\n";

    if (mode == "ctr") {
        std::ifstream infileSize(infile, std::ios::binary | std::ios::ate);
        std::streamsize fileSize = infileSize.tellg();
        infileSize.close();

        // For BMP we skip the 54-byte header; that's the processed payload.
        const bool isBmp = (fileType == "bmp");
        long long processedBytes = std::max<long long>(0, static_cast<long long>(fileSize) - (isBmp ? 54 : 0));

        double timePerKB = (processedBytes > 0)? static_cast<double>(duration.count()) / (processedBytes / 1024.0): 0.0;

        double energyPerKB = (processedBytes > 0)? (duration.count() * memUsedKB) / (processedBytes / 1024.0): 0.0;

        double throughputMBps = (duration.count() > 0)? (processedBytes / 1e6) / (duration.count() / 1e6): 0.0;

        std::cout << "File Size: " << fileSize << " bytes\n";
        std::cout << "Processed Bytes: " << processedBytes << "\n";
        std::cout << "Time per KB: " << timePerKB << " µs/KB\n";
        std::cout << "Throughput: " << throughputMBps << " MB/s\n";
        std::cout << "Relative Energy per KB: " << energyPerKB << " µs·KB per KB data\n";
    }
        return 0;
    }


