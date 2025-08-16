

    // present.cpp - Implementation of PRESENT key schedule (80-bit)

    #include "present.h"
    #include <stdexcept>
    #include <cstdint>
    #include <vector>
    #include <array>
    #include <fstream>
    #include <iostream>
    #include <mutex>
    #include <thread>
    #include <sys/resource.h>
    #include <chrono>
    #include "hexutils.h"
    #include <sys/time.h>
    #include <cstdlib>
    #include <algorithm>

    Present::Present(PresentKeySize keySize, const std::vector<uint8_t>& key) : keySize(keySize) 
    {
        KeySchedule(key);
    }

    Present::Present(PresentKeySize keySize, const std::vector<uint64_t>& precomputedRoundKeys): keySize(keySize), roundKeys(precomputedRoundKeys) {}

    // -------------------- SBox Table --------------------
    constexpr std::array<uint8_t, 16> SBox = 
    {
        0xC, 0x5, 0x6, 0xB,
        0x9, 0x0, 0xA, 0xD,
        0x3, 0xE, 0xF, 0x8,
        0x4, 0x7, 0x1, 0x2
    };

    // -------------------- PBox Table --------------------
    /*For i from 0 to 63:
     if i ≠ 63:
      bit i → bit (16 × i) mod 63
     else:
      bit 63 → bit 63

    So each bit is moved to a new position.*/

    constexpr std::array<uint8_t, 64> PBox = {
    0, 16, 32, 48, 1, 17, 33, 49,
    2, 18, 34, 50, 3, 19, 35, 51,
    4, 20, 36, 52, 5, 21, 37, 53,
    6, 22, 38, 54, 7, 23, 39, 55,
    8, 24, 40, 56, 9, 25, 41, 57,
    10, 26, 42, 58, 11, 27, 43, 59,
    12, 28, 44, 60, 13, 29, 45, 61,
    14, 30, 46, 62, 15, 31, 47, 63
    };


    // -------------------- Round Key Extraction --------------------
    uint64_t getRoundKey80(const std::vector<uint8_t>& keyReg)
    {
        uint64_t rk = 0;
        for (int i = 0; i < 8; ++i)
            rk = (rk << 8) | keyReg[i];
        return rk;
    }

    // -------------------- Key Rotation (Left by 61 bits) --------------------
    void rotateKey80(std::vector<uint8_t>& keyReg)
    {
        uint64_t high = 0;
        uint16_t low = 0;

        for (int i = 0; i < 8; ++i)
            high = (high << 8) | keyReg[i];

        low = (keyReg[8] << 8) | keyReg[9];

        __uint128_t fullKey = (__uint128_t(high) << 16) | low;
        fullKey = ((fullKey << 61) | (fullKey >> 19)) & ((__uint128_t(1) << 80) - 1);

        for (int i = 9; i >= 0; --i) {
            keyReg[i] = static_cast<uint8_t>(fullKey & 0xFF);
            fullKey >>= 8;
        }
    }

    // -------------------- SBox Application (Bits 79–76) --------------------
    void applySBoxToTopNibble(std::vector<uint8_t>& keyReg)
    {
        uint8_t topNibble = keyReg[0] >> 4;
        topNibble = SBox[topNibble];
        keyReg[0] = (topNibble << 4) | (keyReg[0] & 0x0F);
    }

    // -------------------- Round Counter XOR (Bits 19–15) --------------------
    void xorRoundCounter80(std::vector<uint8_t>& keyReg, int round) 
    {
        /*keyReg[1] ^= (round >> 1);
        keyReg[2] ^= (round & 0x01) << 7;*/

        keyReg[7] ^= (round >> 1);
        keyReg[8] ^= (round & 0x01) << 7;

    }

    // -------------------- Final Key Schedule Function --------------------

    void Present::KeySchedule(const std::vector<uint8_t>& key) {
        if (keySize == PRESENT_80) {
            KeySchedule80(key);
        } else if (keySize == PRESENT_128) {
            KeySchedule128(key);
        } else {
            throw std::invalid_argument("Unsupported key size.");
        }
    }

    // -------------------- Key Schedule for 80-bit Key --------------------    
    // This function generates 32 round keys from an 80-bit key.
    // The key is processed in 10 rounds, each producing a round key.
    // The key is rotated left by 61 bits, and the SBox is applied to the
    // top nibble (bits 79–76). The round counter is XORed into bits 19 to 15 (bytes 1 and 2).
    void Present::KeySchedule80(const std::vector<uint8_t>& key) {
        if (key.size() != 10) {
            throw std::invalid_argument("80-bit key must be 10 bytes.");
        }

        std::vector<uint8_t> keyReg = key;
        roundKeys.resize(32);

        for (int round = 0; round < 32; ++round) {
            roundKeys[round] = getRoundKey80(keyReg);
            rotateKey80(keyReg);
            applySBoxToTopNibble(keyReg);
            xorRoundCounter80(keyReg, round + 1);
        }
    }

    uint64_t Present::bytesToUint64(const uint8_t* bytes) {
        uint64_t value = 0;
        for (int i = 0; i < 8; ++i) {
            value = (value << 8) | bytes[i];
        }
        return value;
    }

    void Present::uint64ToBytes(uint64_t val, uint8_t* out) {
        for (int i = 7; i >= 0; --i) {
            out[i] = val & 0xFF;
            val >>= 8;
        }
    }

    // -------------------- Key Schedule for 128-bit Key --------------------
    // This function generates 32 round keys from a 128-bit key (16 bytes).
    // The key is rotated left by 61 bits, and the SBox is applied to the
    // top two nibbles (bits 127–124 and 123–120). The round counter is XORed
    // into bits 66 to 62 (bytes 14 and 15).
    void Present::KeySchedule128(const std::vector<uint8_t>& key) {
        if (key.size() != 16) {
            throw std::invalid_argument("128-bit key must be 16 bytes.");
        }

        std::vector<uint8_t> keyReg = key;  // 128-bit key as 16 bytes
        roundKeys.resize(32);

        for (int round = 0; round < 32; ++round) {
            // Round key is top 64 bits
            uint64_t roundKey = 0;
            for (int i = 0; i < 8; ++i)
                roundKey = (roundKey << 8) | keyReg[i];
            roundKeys[round] = roundKey;

            // Rotate left by 61 bits
            __uint128_t fullKey = 0;
            for (int i = 0; i < 16; ++i)
                fullKey = (fullKey << 8) | keyReg[i];

            __uint128_t mask = (((__uint128_t)1 << 127)<<1) - 1;
            fullKey = ((fullKey << 61) | (fullKey >> (128 - 61))) & mask;

            for (int i = 15; i >= 0; --i) {
                keyReg[i] = static_cast<uint8_t>(fullKey & 0xFF);
                fullKey >>= 8;
            }

            // Apply SBox to bits 127–124 and 123–120 (top two nibbles)
            //keyReg[0] = (SBox[keyReg[0] >> 4] << 4) | (keyReg[0] & 0x0F);
            //keyReg[1] = (SBox[keyReg[1] >> 4] << 4) | (keyReg[1] & 0x0F);

            keyReg[0] = (uint8_t)((SBox[keyReg[0] >> 4] << 4) | SBox[keyReg[0] & 0x0F]);

            // XOR round counter into bits 66 to 62 (byte 14 and 15)
            /*keyReg[14] ^= (round + 1) >> 1;
            keyReg[15] ^= ((round + 1) & 0x01) << 7;*/
            uint8_t rc = static_cast<uint8_t>((round + 1)& 0x1F);
            keyReg[7] ^= (rc  >> 2)&0x07;
            keyReg[8] ^= ((rc >> 1) & 0x01) << 7;
            keyReg[8] ^= (rc & 0x01) << 6;
        }
    }

    // -------------------- AddRoundKey (XOR state with round key) --------------------
    uint64_t Present::addRoundKey(uint64_t state, uint64_t roundKey) 
    {
        return state ^ roundKey;
    }

    // -------------------- sBoxLayer --------------------
    uint64_t Present::sBoxLayer(uint64_t state)
    {
        uint64_t output = 0;
        for (int i = 0; i < 16; ++i)
        {
            uint8_t nibble = (state >> (i * 4)) & 0xF;
            uint8_t sboxed = SBox[nibble];
            output |= (static_cast<uint64_t>(sboxed) << (i * 4));
        }
        return output;
    }

    // -------------------- pLayer Function --------------------
    uint64_t Present::pLayer(uint64_t state)
    {
        uint64_t result = 0;
        for (int i = 0; i < 64; ++i)
        {
            if ((state >> i) & 0x1) 
            {
                result |= (1ULL << PBox[i]);
            }
        }

        return result;

    };

    uint64_t Present::encryptBlock(uint64_t plaintext) 
    {
        uint64_t state = plaintext;
        for (int round = 0; round < 31; ++round) 
        {
            state = addRoundKey(state, roundKeys[round]);
            state = sBoxLayer(state);
            state = pLayer(state);
        }

        // Final round key
        state = addRoundKey(state, roundKeys[31]);

    return state;
    }

    constexpr std::array<uint8_t, 16> invSBox = {
        0x5, 0xE, 0xF, 0x8,
        0xC, 0x1, 0x2, 0xD,
        0xB, 0x4, 0x6, 0x3,
        0x0, 0x7, 0x9, 0xA
    };

    constexpr std::array<uint8_t, 64> invPBox = {
    0,  4,  8, 12, 16, 20, 24, 28,
    32, 36, 40, 44, 48, 52, 56, 60,
    1,  5,  9, 13, 17, 21, 25, 29,
    33, 37, 41, 45, 49, 53, 57, 61,
    2,  6, 10, 14, 18, 22, 26, 30,
    34, 38, 42, 46, 50, 54, 58, 62,
    3,  7, 11, 15, 19, 23, 27, 31,
    35, 39, 43, 47, 51, 55, 59, 63
    };

    uint64_t Present::invSBoxLayer(uint64_t state) {
        uint64_t output = 0;
        for (int i = 0; i < 16; ++i) {
            uint8_t nibble = (state >> (i * 4)) & 0xF;
            uint8_t restored = invSBox[nibble];
            output |= (static_cast<uint64_t>(restored) << (i * 4));
        }
        return output;
    }

    uint64_t Present::invPLayer(uint64_t state) {
        uint64_t result = 0;
        for (int i = 0; i < 64; ++i) {
            if ((state >> i) & 0x1) {
                result |= (1ULL << invPBox[i]);
            }
        }
        return result;
    }

    uint64_t Present::decryptBlock(uint64_t ciphertext) {
        uint64_t state = addRoundKey(ciphertext, roundKeys[31]);
        for (int round = 30; round >= 0; --round) {
            state = invPLayer(state);
            state = invSBoxLayer(state);
            state = addRoundKey(state, roundKeys[round]);
        }
        return state;
    }

    void Present::encryptCTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce)
    {
        std::ifstream infile(inputPath, std::ios::binary);
        std::ofstream outfile(outputPath, std::ios::binary);
        if (!infile || !outfile)
        {
            std::cerr << "Error opening files." << std::endl;
            return;
        }

        uint64_t counter = 0;
        uint8_t buffer[8];

        while (infile.read(reinterpret_cast<char*>(buffer), 8) || infile.gcount() > 0) {
            std::streamsize bytesRead = infile.gcount();

            // Construct counter block (nonce + counter)
            uint8_t ctrBlockBytes[8];
            for (int i = 0; i < 8; ++i)
                ctrBlockBytes[i] = nonce[i];
            uint64_t ctrBlock = bytesToUint64(ctrBlockBytes) ^ counter;

        // Encrypt counter block
        uint64_t keystream = encryptBlock(ctrBlock);

        // XOR with plaintext block
        uint64_t plaintextBlock = 0;
        for (int i = 0; i < bytesRead; ++i)
            plaintextBlock |= static_cast<uint64_t>(buffer[i]) << (8 * (7 - i));

        uint64_t ciphertextBlock = plaintextBlock ^ keystream;

        // Write ciphertext block
        for (int i = 0; i < bytesRead; ++i) {
            uint8_t byte = (ciphertextBlock >> (8 * (7 - i))) & 0xFF;
            outfile.write(reinterpret_cast<char*>(&byte), 1);
        }

        ++counter;
    }

    infile.close();
    outfile.close();
    }


    void Present::decryptCTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce)
    {
        std::ifstream infile(inputPath, std::ios::binary);
        std::ofstream outfile(outputPath, std::ios::binary);
        if (!infile || !outfile)
        {
            std::cerr << "Error opening files." << std::endl;
            return;
        }

        uint64_t counter = 0;
        uint8_t buffer[8];

        while (infile.read(reinterpret_cast<char*>(buffer), 8) || infile.gcount() > 0) {
            std::streamsize bytesRead = infile.gcount();

            // Construct counter block (nonce + counter)
            uint8_t ctrBlockBytes[8];
            for (int i = 0; i < 8; ++i)
                ctrBlockBytes[i] = nonce[i];
            uint64_t ctrBlock = bytesToUint64(ctrBlockBytes) ^ counter;

            // Encrypt counter block (same for both enc/dec)
            uint64_t keystream = encryptBlock(ctrBlock);

            // XOR with ciphertext block
            uint64_t ciphertextBlock = 0;
            for (int i = 0; i < bytesRead; ++i)
                ciphertextBlock |= static_cast<uint64_t>(buffer[i]) << (8 * (7 - i));

            uint64_t plaintextBlock = ciphertextBlock ^ keystream;

            // Write plaintext block
            for (int i = 0; i < bytesRead; ++i) {
                uint8_t byte = (plaintextBlock >> (8 * (7 - i))) & 0xFF;
                outfile.write(reinterpret_cast<char*>(&byte), 1);
            }

            ++counter;
        }

        infile.close();
        outfile.close();
    }

    void Present::encryptBMP_CTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce)
    {
        std::ifstream infile(inputPath, std::ios::binary);
        std::ofstream outfile(outputPath, std::ios::binary);
        if (!infile || !outfile)
        {
            std::cerr << "Error opening BMP files.\n";
            return;
        }

        // Preserve BMP header (54 bytes)
        std::vector<char> header(54);
        infile.read(header.data(), 54);
        outfile.write(header.data(), 54);

        uint64_t counter = 0;
        uint8_t buffer[8];

        while (infile.read(reinterpret_cast<char*>(buffer), 8) || infile.gcount() > 0) {
            std::streamsize bytesRead = infile.gcount();

            uint8_t ctrBlockBytes[8];
            for (int i = 0; i < 8; ++i)
                ctrBlockBytes[i] = nonce[i];
            uint64_t ctrBlock = bytesToUint64(ctrBlockBytes) ^ counter;

            uint64_t keystream = encryptBlock(ctrBlock);

            uint64_t plaintextBlock = 0;
            for (int i = 0; i < bytesRead; ++i)
                plaintextBlock |= static_cast<uint64_t>(buffer[i]) << (8 * (7 - i));

            uint64_t ciphertextBlock = plaintextBlock ^ keystream;

            for (int i = 0; i < bytesRead; ++i) {
                uint8_t byte = (ciphertextBlock >> (8 * (7 - i))) & 0xFF;
                outfile.write(reinterpret_cast<char*>(&byte), 1);
            }

            ++counter;
        }

        infile.close();
        outfile.close();
    }

    void Present::decryptBMP_CTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce)
    {
        encryptBMP_CTR(inputPath, outputPath, nonce); // symmetric operation
    }

    void Present::encryptCTR_MT(const std::string& infile, const std::string& outfile, const std::array<uint8_t, 8>& nonce, int numThreads)
    {
        std::ifstream fin(infile, std::ios::binary | std::ios::ate);
        if (!fin)
        {
            std::cerr << "Error: Cannot open input file\n";
            return;
        }

        std::streamsize fileSize = fin.tellg();
        fin.seekg(0, std::ios::beg);

        std::vector<uint8_t> input(fileSize);
        if (!fin.read(reinterpret_cast<char*>(input.data()), fileSize)) {
        std::cerr << "Error: Failed to read input file\n";
        return;
        }
        fin.close();

        std::vector<uint8_t> output(fileSize);
        uint64_t totalBlocks = (fileSize + 7) / 8; // PRESENT block size = 8 bytes
        uint64_t blocksPerThread = (totalBlocks + numThreads - 1) / numThreads;

        auto worker = [&](int threadId) {
            uint64_t startBlock = threadId * blocksPerThread;
            uint64_t endBlock = std::min(startBlock + blocksPerThread, totalBlocks);

            Present localCipher(this->keySize, this->roundKeys); // Reuse round keys

            for (uint64_t blk = startBlock; blk < endBlock; ++blk) {
                uint64_t counter = blk;
                uint8_t ctrBlockBytes[8];

                for (int i = 0; i < 8; ++i)
                    ctrBlockBytes[i] = nonce[i];
                uint64_t ctr = bytesToUint64(ctrBlockBytes) ^ counter;
                uint64_t keystream = localCipher.encryptBlock(ctr);

                size_t offset = blk * 8;
                for (int i = 0; i < 8 && offset + i < fileSize; ++i) {
                    output[offset + i] = input[offset + i] ^ ((keystream >> (8 * (7 - i))) & 0xFF);
                }
            }
        };

        std::vector<std::thread> threads;
        for (int t = 0; t < numThreads; ++t)
            threads.emplace_back(worker, t);

        for (auto& th : threads)
            th.join();

        std::ofstream fout(outfile, std::ios::binary);
        fout.write(reinterpret_cast<char*>(output.data()), fileSize);
        fout.close();
    }
