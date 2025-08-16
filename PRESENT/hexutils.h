        #ifndef HEXUTILS_H
        #define HEXUTILS_H

        #include <string>
        #include <vector>
        #include <cstdint>

        // Converts a hex string like "00112233..." to a vector of bytes
        std::vector<uint8_t> hexStringToBytes(const std::string& hex);

        // Converts a vector of bytes to hex string (for printing)
        std::string bytesToHexString(const std::vector<uint8_t>& data);

        #endif