    #ifndef PRESENT_H
    #define PRESENT_H

    #include <cstdint>
    #include <string>
    #include <iostream>

    enum PresentKeySize {
        PRESENT_80 = 80,
        PRESENT_128 = 128
    };

    class Present {
        public:
            Present (PresentKeySize keySize , const std::vector<uint8_t> &key);


            Present(PresentKeySize keySize, const std::vector<uint64_t>& precomputedRoundKeys);

            //Encrypt a single block of plaintext(64 bits)
            uint64_t encryptBlock (uint64_t plaintext);
            uint64_t decryptBlock(uint64_t ciphertext);

            //Encrypt and decrypt using CTR mode
            void encryptCTR (const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce);
            void decryptCTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce);

            void encryptBMP_CTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce);
            void decryptBMP_CTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce);

            void encryptCTR_MT(const std::string& infile, const std::string& outfile, const std::array<uint8_t, 8>& nonce, int numThreads);

            
        
        private:
            PresentKeySize keySize;
            std::vector<uint64_t> roundKeys;

            void KeySchedule (const std::vector<uint8_t> &key);
            void KeySchedule80(const std::vector<uint8_t>& key);
            void KeySchedule128(const std::vector<uint8_t>& key);
            uint64_t addRoundKey (uint64_t state, uint64_t roundKey);
            uint64_t sBoxLayer (uint64_t state);
            uint64_t pLayer (uint64_t state);

            uint8_t sbox ( uint8_t nibble) ;
            uint8_t pbox ( uint8_t nibble) ;

            uint64_t bytesToUint64(const uint8_t* bytes);
            void uint64ToBytes(uint64_t val, uint8_t* out);

            uint64_t invSBoxLayer(uint64_t state);
            uint64_t invPLayer(uint64_t state);

    };

    #endif