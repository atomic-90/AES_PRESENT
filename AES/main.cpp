    #include "aes.h"
    #include "hexutils.h"
    #include <iostream>
    #include <fstream>
    #include <array>
    #include <vector>
    #include <cstring>
    #include <sys/resource.h>
    #include <chrono>
    #include <sys/time.h>
    #include <cstdlib>
    #include <algorithm>

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
            << "  ./aes_cli --aes <128|192|256> --mode block --encrypt|--decrypt --key <hexkey> --input <hexdata>\n"
            << "  ./aes_cli --aes <128|192|256> --mode ctr --encrypt|--decrypt --key <hexkey> --infile <file> --outfile <file> --nonce <hex> --filetype <bmp|bin> --threads 4\n"
            << "Examples:\n"
            << "  ./aes_cli --aes 128 --mode block --encrypt --key 00112233445566778899aabbccddeeff --input 00112233445566778899aabbccddeeff\n"
            << "  ./aes_cli --aes 192 --mode ctr --encrypt --key 00112233445566778899aabbccddeeff00112233445566 --nonce aabbccddeeff0011 --filetype bmp --infile ./input_images/sample.bmp --outfile ./output_images/enc_sample.bmp\n"
            << "  ./aes_cli --aes 256 --mode ctr --decrypt --key 00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff --nonce aabbccddeeff0011 --filetype bin --infile ./input/test.txt --outfile ./output/dec_test.txt\n";

    }

    int main(int argc, char* argv[]) {
        if (argc < 2) {
            printUsage();
            return 1;
        }

        int numThreads = 1;
        string mode, action ,aesBits = "128";
        string keyHex, inputHex, fileType, infile, outfile, nonceHex;

        for (int i = 1; i < argc; ++i) {
            if (strcmp(argv[i], "--aes") == 0 && i + 1 < argc) aesBits = argv[++i];
            else if (strcmp(argv[i], "--threads") == 0 && i + 1 < argc) numThreads = atoi(argv[++i]);
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

        AESType aesType;
        if (aesBits == "128") aesType = AESType::AES_128;
        else if (aesBits == "192") aesType = AESType::AES_192;
        else if (aesBits == "256") aesType = AESType::AES_256;
        else {
            cerr << "Error: Invalid AES bit size. Use 128, 192, or 256.\n";
            return 1;
        }

        if (keyHex.empty()) {
            cerr << "Error: Key is required.\n";
            return 1;
        }

        vector<uint8_t> key = hexStringToBytes(keyHex);
        if (aesType == AESType::AES_128 && key.size() != 16) {
            cerr << "Error: Key must be 128 bits (32 hex chars).\n";
            return 1;
        }
        if (aesType == AESType::AES_192 && key.size() != 24) {
            cerr << "Error: Key must be 192 bits (48 hex chars) for AES-192.\n";
            return 1;
        }
        if (aesType == AESType::AES_256 && key.size() != 32) {
            cerr << "Error: Key must be 256 bits (64 hex chars) for AES-256.\n";
            return 1;
        }

        AES aes;
        


        aes.KeyExpansion(key.data(), aesType);
        // DEBUG: print aes parameters and first few round key bytes
    //cout << "DEBUG: AES type: " << aesBits << " ; key bytes: " << bytesToHexString(key) << endl;

    //cout << "DEBUG: plaintext (inputHex) = " << inputHex << endl;

        long cpuStartsUs = getCpuTimeMicros();

        auto start = chrono::high_resolution_clock::now();

        if (mode == "block") {
            if (inputHex.empty()) {
                cerr << "Error: Input is required for block mode.\n";
                return 1;
            }
            vector<uint8_t> input = hexStringToBytes(inputHex);
            if (input.size() != 16) {
                cerr << "Error: Input must be 16 bytes (32 hex chars).\n";
                return 1;
            }
            

            vector<uint8_t> output(16);

            //auto start = chrono::high_resolution_clock::now();

            if (action == "encrypt")
                aes.EncryptAES(input.data(), key.data(), output.data());
            else if (action == "decrypt")
                aes.DecryptAES(input.data(), key.data(), output.data());
            else {
                cerr << "Error: Must specify --encrypt or --decrypt.\n";
                return 1;
            }

            //auto end = chrono::high_resolution_clock::now();
            //chrono::duration<double, milli> elapsed = end - start;

            cout << "Output: " << bytesToHexString(output) << endl;
            //cout << "Time taken: " << elapsed.count() << " ms" << endl;
            
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

            //auto start = chrono::high_resolution_clock::now();

            if (fileType == "bmp") {
                if (action == "encrypt")
                    aes.encryptBMP_CTR(infile, outfile, key.data(), aesType, nonce);
                else if (action == "decrypt")
                    aes.decryptBMP_CTR(infile, outfile, key.data(), aesType, nonce);
                else {
                    cerr << "Error: Must specify --encrypt or --decrypt.\n";
                    return 1;
                }
            }
            else if (fileType == "bin") {
                if (numThreads == 1)
                    aes.AES_CTR(infile, outfile, nonce, key.data(), aesType);
                else if (numThreads > 1)
                    aes.AES_CTR_MT(infile, outfile, nonce, key.data(), aesType,numThreads);
                else {
                    cerr << "Error: Must specify --encrypt or --decrypt.\n";
                    return 1;
                }
            }
            else {
                cerr << "Error: Invalid filetype. Use 'bmp' or 'bin'.\n";
                return 1;
            }

            //auto end = chrono::high_resolution_clock::now();
            //chrono::duration<double, milli> elapsed = end - start;

            cout << "Operation complete. Output saved to " << outfile << endl;
            //cout << "Time taken: " << elapsed.count() << " ms" << endl;
        }

        else {
            cerr << "Error: Invalid mode. Choose 'block' or 'ctr'.\n";
            return 1;
        }

        auto end = chrono::high_resolution_clock::now();
        auto duration = chrono::duration_cast<chrono::microseconds>(end - start);

        long memUsedKB = getMemoryUsageKB();
        long cpuEndsUs = getCpuTimeMicros();
        long cpuUsedUs = cpuEndsUs - cpuStartsUs;
    /*
        cout << "Performance Summary:\n";
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