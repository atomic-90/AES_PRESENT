    #include "aes.h"
    #include <iostream>
    #include <cstdint>
    #include <fstream>
    #include <thread>
    #include <mutex>


    using namespace std;



        // AES S-Box and Inverse S-Box
        // These are used for SubBytes and InvSubBytes transformations.
        static const uint8_t SBox[16][16] = {
            {0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76},
            {0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0},
            {0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15},
            {0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75},
            {0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84},
            {0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf},
            {0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8},
            {0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2},
            {0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73},
            {0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb},
            {0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79},
            {0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08},
            {0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a},
            {0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e},
            {0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf},
            {0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16}
        };

        //Inverse S-Box
        // This is used for InvSubBytes transformation.
        static const uint8_t InvSBox[16][16] = {
            {0x52,0x09,0x6a,0xd5,0x30,0x36,0xa5,0x38,0xbf,0x40,0xa3,0x9e,0x81,0xf3,0xd7,0xfb},
            {0x7c,0xe3,0x39,0x82,0x9b,0x2f,0xff,0x87,0x34,0x8e,0x43,0x44,0xc4,0xde,0xe9,0xcb},
            {0x54,0x7b,0x94,0x32,0xa6,0xc2,0x23,0x3d,0xee,0x4c,0x95,0x0b,0x42,0xfa,0xc3,0x4e},
            {0x08,0x2e,0xa1,0x66,0x28,0xd9,0x24,0xb2,0x76,0x5b,0xa2,0x49,0x6d,0x8b,0xd1,0x25},
            {0x72,0xf8,0xf6,0x64,0x86,0x68,0x98,0x16,0xd4,0xa4,0x5c,0xcc,0x5d,0x65,0xb6,0x92},
            {0x6c,0x70,0x48,0x50,0xfd,0xed,0xb9,0xda,0x5e,0x15,0x46,0x57,0xa7,0x8d,0x9d,0x84},
            {0x90,0xd8,0xab,0x00,0x8c,0xbc,0xd3,0x0a,0xf7,0xe4,0x58,0x05,0xb8,0xb3,0x45,0x06},
            {0xd0,0x2c,0x1e,0x8f,0xca,0x3f,0x0f,0x02,0xc1,0xaf,0xbd,0x03,0x01,0x13,0x8a,0x6b},
            {0x3a,0x91,0x11,0x41,0x4f,0x67,0xdc,0xea,0x97,0xf2,0xcf,0xce,0xf0,0xb4,0xe6,0x73},
            {0x96,0xac,0x74,0x22,0xe7,0xad,0x35,0x85,0xe2,0xf9,0x37,0xe8,0x1c,0x75,0xdf,0x6e},
            {0x47,0xf1,0x1a,0x71,0x1d,0x29,0xc5,0x89,0x6f,0xb7,0x62,0x0e,0xaa,0x18,0xbe,0x1b},
            {0xfc,0x56,0x3e,0x4b,0xc6,0xd2,0x79,0x20,0x9a,0xdb,0xc0,0xfe,0x78,0xcd,0x5a,0xf4},
            {0x1f,0xdd,0xa8,0x33,0x88,0x07,0xc7,0x31,0xb1,0x12,0x10,0x59,0x27,0x80,0xec,0x5f},
            {0x60,0x51,0x7f,0xa9,0x19,0xb5,0x4a,0x0d,0x2d,0xe5,0x7a,0x9f,0x93,0xc9,0x9c,0xef},
            {0xa0,0xe0,0x3b,0x4d,0xae,0x2a,0xf5,0xb0,0xc8,0xeb,0xbb,0x3c,0x83,0x53,0x99,0x61},
            {0x17,0x2b,0x04,0x7e,0xba,0x77,0xd6,0x26,0xe1,0x69,0x14,0x63,0x55,0x21,0x0c,0x7d}
        };

        // Round constants used in key expansion
        // These are used in the GFunction during key expansion.
        // Each round constant is used to modify the first byte of the word in the key schedule
        static const uint8_t RoundConstant[15] = {
            0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80,
            0x1B, 0x36, 0x6C, 0xD8, 0xAB, 0x4D, 0x9A
        };

        AES::AES()
        {
            numofwordsinkey = 0;
            numofrounds = 0 ;
            memset(roundKeys, 0, sizeof(roundKeys)); // Initialize round keys to zero
            // Sets a block of memory to a specific byte value.
            // This is important to ensure that the round keys are clean before we start filling them with actual key data.
        }

        /*
        //GFunction is used in key expansion
        void AES::GFunction(uint8_t *word, int round)
        {
            // Rotate the word (circular left shift)
            uint8_t temp = word[0];
            word[0] = word[1];
            word[1] = word[2];
            word[2] = word[3];
            word[3] = temp;
            // Substitute bytes using the S-Box
            for (int i = 0; i < 4; ++i) 
            {
                uint8_t byte = word[i];
                // Extract the row index (high nibble),this gives the first 4 bits of the byte
                uint8_t row = (byte >> 4) & 0x0F; 
                // Extract the column index (low nibble), this gives the last 4 bits of the byte
                uint8_t col = byte & 0x0F;
                word[i] = SBox[row][col];
            }
            word[0] ^= RoundConstant[round];// XOR with the round constant ,only the first byte is modified
        }

        void AES::KeyExpansion(const uint8_t *key, AESType aesType)
        {
            // Convert AESType to key size in bytes
            int keySize = static_cast<int>(aesType) /8; 
            // Number of words in the key (4 bytes per word)
            numofwordsinkey = keySize / 4; 
            // Number of rounds for AES (10, 12, or 14 depending on key size)
            numofrounds = numofwordsinkey + 6; 

            for(int i = 0 ;i < keySize; i++)
            {
                // Copy the key into the round keys array
                //Here we copy the key bytes into the round keys array, that is the first keySize bytes of roundKeys are filled with the key bytes. 
                roundKeys[i] = key[i]; 
            }

            int bytesGenerated = keySize; // Number of bytes generated so far
            int round = 0; // Counter for round constants
            uint8_t temp[4]; // Temporary array to hold a word during expansion

            while(bytesGenerated < (numofrounds + 1) * 16) //Generate keys until we have enough for all rounds
            {
                for(int i = 0; i< 4;i++)
                {
                    temp[i] = roundKeys[(bytesGenerated - 4) + i]; // Get the last word which is if keySize is 16, then the last word is roundKeys[12] to roundKeys[15]
                }
                if(bytesGenerated % keySize == 0 ) //If the number of bytes generated is a multiple of the key size, we apply the GFunction
                {
                    GFunction(temp, round++);
                }
                else if (numofwordsinkey > 6 && (bytesGenerated % keySize == 16)) // If we are in AES-256, we apply the S-Box to the word
                {
                    for (int i = 0; i < 4; ++i)
                    {
                        uint8_t byte = temp[i];
                        uint8_t row = (byte >> 4) & 0x0F;
                        uint8_t col = byte & 0x0F;
                        temp[i] = SBox[row][col];
                    }
                }

                for(int i = 0; i < 4; ++i) 
                {
                    // XOR the generated word with the previous word to create the new round key
                    roundKeys[bytesGenerated] = roundKeys[bytesGenerated - keySize] ^ temp[i];
                    ++bytesGenerated; // Move to the next byte in the round keys array

                }
            }
        }
            */
        // ---------- Helpers (add inside aes.cpp or as AES:: methods) ----------

    // Rotate a 4-byte word left by one byte (word provided as 4 bytes)
    static void RotWord(uint8_t w[4]) {
        uint8_t t = w[0];
        w[0] = w[1]; w[1] = w[2]; w[2] = w[3]; w[3] = t;
    }

    // SubWord: apply SBox to each byte of a 4-byte word
    static void SubWord(uint8_t w[4]) {
        for (int i = 0; i < 4; ++i) {
            uint8_t byte = w[i];
            uint8_t row = (byte >> 4) & 0x0F;
            uint8_t col = byte & 0x0F;
            w[i] = SBox[row][col];
        }
    }

        // ---------- Correct KeyExpansion ----------
    void AES::KeyExpansion(const uint8_t *key, AESType aesType)
    {
        // keySize in bytes (16,24,32)
        int keySize = static_cast<int>(aesType) / 8;
        int Nk = keySize / 4;          // number of 32-bit words in key (4,6,8)
        numofwordsinkey = Nk;
        int Nr = Nk + 6;               // number of rounds (10,12,14)
        numofrounds = Nr;

        // total words in expanded key = Nb * (Nr+1); Nb == 4
        int totalWords = 4 * (Nr + 1);
        int totalBytes = totalWords * 4; // safe size for roundKeys

        // Ensure roundKeys buffer is large enough (roundKeys should be uint8_t[240] in header)
        // Copy initial key bytes into roundKeys[0..keySize-1]
        for (int i = 0; i < keySize; ++i)
            roundKeys[i] = key[i];

        // word index: start at Nk (we already have w[0..Nk-1])
        int wordIndex = Nk;
        uint8_t temp[4];

        while (wordIndex < totalWords) {
            // copy previous word (w[wordIndex-1]) into temp
            int prevOffset = (wordIndex - 1) * 4;
            for (int j = 0; j < 4; ++j)
                temp[j] = roundKeys[prevOffset + j];

            if ((wordIndex % Nk) == 0) {
                // temp = SubWord(RotWord(temp)) ^ Rcon[wordIndex/Nk - 1]
                RotWord(temp);
                SubWord(temp);
                int rcon_index = (wordIndex / Nk) - 1;
                temp[0] ^= RoundConstant[rcon_index];
            } else if (Nk > 6 && (wordIndex % Nk) == 4) {
                // Only for AES-256 (Nk == 8) -> extra SubWord
                SubWord(temp);
            }

            // w[wordIndex] = w[wordIndex - Nk] ^ temp
            int baseOffset = (wordIndex - Nk) * 4;
            int outOffset  = wordIndex * 4;
            for (int j = 0; j < 4; ++j) {
                roundKeys[outOffset + j] = roundKeys[baseOffset + j] ^ temp[j];
            }

            wordIndex++;
        }
        // Done. roundKeys now contains (Nr+1)*16 bytes of expanded keys
    }

        // SubBytes transformation
        // This function substitutes each byte in the state with a corresponding byte from the S-Box
        void AES::SubBytes(uint8_t inputstate[4][4])
        {
            for (int i = 0; i < 4; ++i) 
            {
                for (int j = 0; j < 4; ++j) 
                {
                    uint8_t byte = inputstate[i][j];
                    uint8_t row = (byte >> 4) & 0x0F;
                    uint8_t col = byte & 0x0F;
                    inputstate[i][j] = SBox[row][col];
                }
            }
        }

        // ShiftRows transformation
        // This function shifts the rows of the state to the left by a certain number of bytes
        void AES::ShiftRows(uint8_t inputstate[4][4])
        {
            uint8_t temp;
            temp = inputstate[1][0];
            inputstate[1][0] = inputstate[1][1];
            inputstate[1][1] = inputstate[1][2];
            inputstate[1][2] = inputstate[1][3];
            inputstate[1][3] = temp;

            temp = inputstate[2][0];
            uint8_t tmp2 = inputstate[2][1];
            inputstate[2][0] = inputstate[2][2];
            inputstate[2][1] = inputstate[2][3];
            inputstate[2][2] = temp;
            inputstate[2][3] = tmp2;

            temp = inputstate[3][3];
            inputstate[3][3] = inputstate[3][2];
            inputstate[3][2] = inputstate[3][1];
            inputstate[3][1] = inputstate[3][0];
            inputstate[3][0] = temp;
        }

        // xtime function
        // This function performs the multiplication by 2 in the Galois field GF(2^8)
        // It is used in MixColumns transformation
        // It shifts the byte left by one and reduces it modulo the polynomial x^8 + x^4 + x^3 + x + 1
        // This is equivalent to multiplying the byte by 2 in GF(2^8)
        uint8_t xtime(uint8_t x) 
        {
            return (x << 1) ^ ((x & 0x80) ? 0x1B : 0x00); //checks if the top bit (bit 7) is 1 — i.e., if overflow occurs
            // If it does, it reduces the result modulo the polynomial x^8 + x^4 + x^3 + x + 1 ie. 0x1B
        }

        // MixColumns transformation
        // This function mixes the columns of the state by multiplying them with a fixed matrix
        void AES::MixColumns(uint8_t inputstate[4][4])
        {
            for (int i = 0; i < 4; ++i) 
            {
                uint8_t a0 = inputstate[0][i];
                uint8_t a1 = inputstate[1][i];
                uint8_t a2 = inputstate[2][i];
                uint8_t a3 = inputstate[3][i];

                inputstate[0][i] = xtime(a0) ^ xtime(a1) ^ a1 ^ a2 ^ a3;
                inputstate[1][i] = a0 ^ xtime(a1) ^ xtime(a2) ^ a2 ^ a3;
                inputstate[2][i] = a0 ^ a1 ^ xtime(a2) ^ xtime(a3) ^ a3;
                inputstate[3][i] = xtime(a0) ^ a0 ^ a1 ^ a2 ^ xtime(a3);
            }
        }

        // AddRoundKey transformation
        // This function XORs the state with the round key for the current round
        void AES::AddRoundKey(uint8_t inputstate[4][4], const uint8_t *roundkey)
        {
            for (int row = 0; row < 4; ++row) 
            {
                for (int col = 0; col < 4; ++col)
                {
                    inputstate[row][col] ^= roundkey[col * 4 + row];
                }
            }
        }

        //EncryptAES function
        // This function performs the AES encryption on a 16-byte input block using the expanded round keys
        // It follows the AES encryption process: AddRoundKey, SubBytes, ShiftRows, MixColumns, and AddRoundKey for each round
        // The final round does not include MixColumns
        // The input is a 16-byte block, the key is the expanded round keys, and the output is the encrypted 16-byte block
        void AES::EncryptAES(const uint8_t *input, const uint8_t *key, uint8_t *output)
        {
            
            uint8_t state[4][4];

            for (int i = 0; i < 16; ++i)
                state[i % 4][i / 4] = input[i];

            AddRoundKey(state, roundKeys);

            for (int round = 1; round < numofrounds; ++round) {
                SubBytes(state);
                ShiftRows(state);
                MixColumns(state);
                AddRoundKey(state, roundKeys + round * 16);
            }

            SubBytes(state);
            ShiftRows(state);
            AddRoundKey(state, roundKeys + numofrounds * 16);

            for (int i = 0; i < 16; ++i)
                output[i] = state[i % 4][i / 4];

        }

        // InvSubBytes transformation
        // This function substitutes each byte in the state with a corresponding byte from the Inverse S-Box
        void AES::InvSubBytes(uint8_t inputstate[4][4])
        {
            for (int i = 0; i < 4; ++i) 
            {
                for (int j = 0; j < 4; ++j) 
                {
                    uint8_t byte = inputstate[i][j];
                    uint8_t row = (byte >> 4) & 0x0F;
                    uint8_t col = byte & 0x0F;
                    inputstate[i][j] = InvSBox[row][col];
                }
            }
        }

        // InvShiftRows transformation
        // This function shifts the rows of the state to the right by a certain number of bytes
        // It is the inverse of the ShiftRows transformation
        void AES::InvShiftRows(uint8_t inputstate[4][4])
        {
            uint8_t temp;
            // Row 1
            temp = inputstate[1][3];
            inputstate[1][3] = inputstate[1][2];
            inputstate[1][2] = inputstate[1][1];
            inputstate[1][1] = inputstate[1][0];
            inputstate[1][0] = temp;

            // Row 2
            uint8_t tmp1 = inputstate[2][0];
            inputstate[2][0] = inputstate[2][2];
            inputstate[2][2] = tmp1;
            tmp1 = inputstate[2][1];
            inputstate[2][1] = inputstate[2][3];
            inputstate[2][3] = tmp1;

            // Row 3
            temp = inputstate[3][0];
            inputstate[3][0] = inputstate[3][1];
            inputstate[3][1] = inputstate[3][2];
            inputstate[3][2] = inputstate[3][3];
            inputstate[3][3] = temp;
        }

        //multiply function
        // This function performs multiplication in the Galois field GF(2^8)
        // It is used in the InvMixColumns transformation
        // It multiplies two bytes a and b using the Galois field multiplication rules
        // It uses the xtime function to perform the multiplication by 2
        // It iterates through the bits of b, multiplying a by 2 for each bit
        // and XORing the result with a if the corresponding bit in b is set
        // This is equivalent to multiplying a and b in GF(2^8)
        uint8_t AES::multiply(uint8_t a, uint8_t b)
        {
            uint8_t result = 0;
            while (b) 
            {
                if (b & 1)
                    result ^= a;
                a = xtime(a);
                b >>= 1;
            }
            return result;
        }

        void AES::InvMixColumns(uint8_t inputstate[4][4])
        {
            for (int i = 0; i < 4; ++i) 
            {
                uint8_t a0 = inputstate[0][i];
                uint8_t a1 = inputstate[1][i];
                uint8_t a2 = inputstate[2][i];
                uint8_t a3 = inputstate[3][i];

                inputstate[0][i] = multiply(a0, 0x0e) ^ multiply(a1, 0x0b) ^ multiply(a2, 0x0d) ^ multiply(a3, 0x09);
                inputstate[1][i] = multiply(a0, 0x09) ^ multiply(a1, 0x0e) ^ multiply(a2, 0x0b) ^ multiply(a3, 0x0d);
                inputstate[2][i] = multiply(a0, 0x0d) ^ multiply(a1, 0x09) ^ multiply(a2, 0x0e) ^ multiply(a3, 0x0b);
                inputstate[3][i] = multiply(a0, 0x0b) ^ multiply(a1, 0x0d) ^ multiply(a2, 0x09) ^ multiply(a3, 0x0e);
            }
        }

        void AES::DecryptAES(const uint8_t *input, const uint8_t *key, uint8_t *output)
        {
            uint8_t state[4][4];

            for (int i = 0; i < 16; ++i)
                state[i % 4][i / 4] = input[i];

            AddRoundKey(state, roundKeys + numofrounds * 16);

            for (int round = numofrounds - 1; round >= 1; --round) {
                InvShiftRows(state);
                InvSubBytes(state);
                AddRoundKey(state, roundKeys + round * 16);
                InvMixColumns(state);
            }

            InvShiftRows(state);
            InvSubBytes(state);
            AddRoundKey(state, roundKeys);

            for (int i = 0; i < 16; ++i)
                output[i] = state[i % 4][i / 4];
        }

        void AES::AES_CTR(const std::string& inputPath, const std::string& outputPath, const std::array<uint8_t, 8>& nonce, const uint8_t* key, AESType aesType)
        {
            KeyExpansion(key, aesType);
            // Open input and output files
            // The input file is read in binary mode, and the output file is also written in binary mode.
            // This is important for handling binary data correctly, especially for encryption/decryption.
            std::ifstream infile(inputPath, std::ios::binary);
            if (!infile.is_open()) {
            std::cerr << "File open failed for: " << inputPath << std::endl;
            perror("Reason");
            return;
    }
            std::ofstream outfile(outputPath, std::ios::binary);

            if (!outfile.is_open()) {
            std::cerr << "File open failed for: " << outputPath << std::endl;
            perror("Reason");
            return;
            }

            uint64_t counter = 0; // Counter for CTR mode
            uint8_t buffer[16]; // Buffer to hold the keystream block
            uint8_t keystream[16]; // holds AES(nonce || counter)

            while(infile)
            {
                infile.read(reinterpret_cast<char*>(buffer), 16); // Read 16 bytes from the input file
                std::streamsize bytesRead = infile.gcount(); // Get the number of bytes read
                if (bytesRead <= 0)
                    break; // If no bytes were read, exit the loop

                // Build the AES input block = nonce || counter
                uint8_t inputBlock[16];
                std::memcpy(inputBlock, nonce.data(), 8); // Copy nonce to the first 8 bytes

                for (int i = 0; i < 8; ++i)
                {
                    inputBlock[8 + i] = static_cast<uint8_t>((counter >> (56 - 8 * i)) & 0xFF);
                }// Fill the last 8 bytes with the counter value

                // Encrypt AES(nonce || counter)
                EncryptAES(inputBlock, key, keystream);

                // XOR keystream with data
                for (int i = 0; i < bytesRead; ++i)
                {
                    buffer[i] ^= keystream[i];
                }

                // Write the encrypted data to the output file
                // The output file is written in binary mode, so we use reinterpret_cast to convert the buffer to a char pointer for writing.
                // This is necessary because the output file is opened in binary mode, and we need to write the raw bytes without any formatting.
                outfile.write(reinterpret_cast<char*>(buffer), bytesRead);
                ++counter;
            }
            infile.close();
            outfile.close();
        }


        void AES::encryptFile_CTR(const std::string& inputFile, const std::string& outputFile,
                            const uint8_t* key, AESType aesType, const std::array<uint8_t, 8>& nonce)
        {
            AES_CTR(inputFile, outputFile, nonce, key, aesType);
        }

        void AES::decryptFile_CTR(const std::string& inputFile, const std::string& outputFile,
                            const uint8_t* key, AESType aesType, const std::array<uint8_t, 8>& nonce)
        {
            AES_CTR(inputFile, outputFile, nonce, key, aesType);
        }

    // Process the CTR mode for BMP files
        // This function reads a BMP file, encrypts or decrypts the pixel data using AES in CTR mode, and writes the result to an output file.
        // It reads the first 54 bytes of the BMP file (the header) and writes it unchanged to the output file.
        // The pixel data is processed in 16-byte blocks, where each block is XORed with the keystream generated by AES encryption of the nonce and counter.
        // The nonce is an 8-byte value that is prepended to the counter, which is a 64-bit value
        // The counter is incremented for each 16-byte block processed.

    //--------------------------------------------------------------------------------------------

        void processCTR(const std::string& inputPath, const std::string& outputPath,const uint8_t* key, AESType aesType,const std::array<uint8_t, 8>& nonce)
        {
            std::ifstream infile(inputPath, std::ios::binary);
            if (!infile.is_open()) 
            {
            std::cerr << "File open failed for: " << inputPath << std::endl;
            perror("Reason");
            return;
            }
            std::ofstream outfile(outputPath, std::ios::binary);

            if (!outfile.is_open()) {
            std::cerr << "File open failed for: " << outputPath << std::endl;
            perror("Reason");
            return;
        }

            AES aes;
        aes.KeyExpansion(key, aesType);

        // Read header (first 54 bytes)
        std::vector<uint8_t> header(54);
        infile.read(reinterpret_cast<char*>(header.data()), 54);
        outfile.write(reinterpret_cast<char*>(header.data()), 54);

        // Process pixel data
        uint64_t counter = 0;
        uint8_t buffer[16], keystream[16];

        while (infile)
        {
            infile.read(reinterpret_cast<char*>(buffer), 16);
            std::streamsize bytesRead = infile.gcount();
            if (bytesRead == 0) break;

            // nonce || counter → 16-byte input block
            uint8_t inputBlock[16];
            std::memcpy(inputBlock, nonce.data(), 8);
            for (int i = 0; i < 8; ++i)
                inputBlock[8 + i] = static_cast<uint8_t>((counter >> (56 - 8 * i)) & 0xFF);

            aes.EncryptAES(inputBlock, key, keystream);

            for (int i = 0; i < bytesRead; ++i)
                buffer[i] ^= keystream[i];

            outfile.write(reinterpret_cast<char*>(buffer), bytesRead);
            ++counter;
        }

        infile.close();
        outfile.close();

        }

        void AES::encryptBMP_CTR(const std::string& inputBMP,const std::string& encryptedBMP,const uint8_t* key,AESType aesType,const std::array<uint8_t, 8>& nonce)
        {
            processCTR(inputBMP, encryptedBMP, key, aesType, nonce);
        }

        void AES::decryptBMP_CTR(const std::string& encryptedBMP, const std::string& decryptedBMP, const uint8_t* key, AESType aesType, const std::array<uint8_t, 8>& nonce)
        {
            processCTR(encryptedBMP, decryptedBMP, key, aesType, nonce);
        }

        

        void AES::AES_CTR_MT(const std::string& infile,const std::string& outfile,const std::array<uint8_t, 8>& nonce,const uint8_t* key,AESType type,int numThreads) 
        {
            std::ifstream fin(infile, std::ios::binary | std::ios::ate);
            if (!fin) {
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
            uint64_t totalBlocks = (fileSize + 15) / 16;
            uint64_t blocksPerThread = (totalBlocks + numThreads - 1) / numThreads;

            auto worker = [&](int threadId) {
                uint64_t startBlock = threadId * blocksPerThread;
                uint64_t endBlock = std::min(startBlock + blocksPerThread, totalBlocks);

                AES localAES;
                localAES.KeyExpansion(key, type);

                for (uint64_t blk = startBlock; blk < endBlock; ++blk) {
                    uint64_t counter = blk;
                    uint8_t ctrBlockBytes[16] = {0};

                    // Fill nonce (first 8 bytes) + counter (last 8 bytes)
                    std::memcpy(ctrBlockBytes, nonce.data(), 8);
                    for (int i = 0; i < 8; ++i)
                        ctrBlockBytes[8 + i] = static_cast<uint8_t>((counter >> (56- (8 * i))) & 0xFF);

                    uint8_t keystream[16] = {0};
                    localAES.EncryptAES(ctrBlockBytes, key, keystream);

                    size_t offset = blk * 16;
                    for (int i = 0; i < 16 && offset + i < fileSize; ++i)
                        output[offset + i] = input[offset + i] ^ keystream[i];
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


