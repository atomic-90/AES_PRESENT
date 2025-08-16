    #include<iostream>
    #include <mutex>
    #include <thread>

    enum class AESType
    {
        AES_128 = 128,
        AES_192 = 192,
        AES_256 = 256
    };

    class AES
    {
        public:
            AES();
            void KeyExpansion(const uint8_t* key, AESType type);
            void EncryptAES(const uint8_t* input, const uint8_t* key, uint8_t* output);
            void DecryptAES(const uint8_t* input, const uint8_t* key, uint8_t* output);
            void AES_EncryptFileCTR(const std::string& inputPath, const std::string& outputPath,const std::array<uint8_t, 8>& nonce, const uint8_t* key, AESType aesType);
            void AES_CTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce, const uint8_t* key, AESType aesType);

            static void encryptBMP_CTR(const std::string& inputBMP,const std::string& encryptedBMP,const uint8_t* key, AESType aesType,const std::array<uint8_t, 8>& nonce);

            static void decryptBMP_CTR(const std::string& encryptedBMP,const std::string& outputBMP,const uint8_t* key,AESType aesType,const std::array<uint8_t, 8>& nonce);

            void encryptFile_CTR(const std::string& inputFile, const std::string& outputFile,
            const uint8_t* key, AESType aesType, const std::array<uint8_t, 8>& nonce);

            void decryptFile_CTR(const std::string& inputFile, const std::string& outputFile,
            const uint8_t* key, AESType aesType, const std::array<uint8_t, 8>& nonce);
            
        
            void AES_CTR_MT(const std::string& infile,const std::string& outfile,const std::array<uint8_t, 8>& nonce,const uint8_t* key,AESType type,int numThreads = std::thread::hardware_concurrency());

        private:
            int numofwordsinkey; // Number of words in the key (4 bytes per word)
            int numofrounds; // Number of rounds for AES
            uint8_t roundKeys[240]; // roundKeys is sized to maximum AES256 requirement (14 rounds × 16 + 16)

            void GFunction(uint8_t* word, int round);
            void SubBytes(uint8_t inputstate[4][4]);
            void ShiftRows(uint8_t inputstate[4][4]);
            void MixColumns(uint8_t inputstate[4][4]);
            void AddRoundKey(uint8_t inputstate[4][4], const uint8_t *roundkey);

            void InvShiftRows(uint8_t inputstate[4][4]);
            void InvSubBytes(uint8_t inputstate[4][4]);
            void InvMixColumns(uint8_t inputstate[4][4]);   
            uint8_t multiply(uint8_t a, uint8_t b);

    };