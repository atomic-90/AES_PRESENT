    #include "hexutils.h"
    #include <stdexcept>
    #include <sstream>
    #include <iomanip>
    #include <cctype>

    uint8_t hexCharToByte(char c) {
        if ('0' <= c && c <= '9') return c - '0';
        else if ('a' <= c && c <= 'f') return 10 + (c - 'a');
        else if ('A' <= c && c <= 'F') return 10 + (c - 'A');
        else throw std::invalid_argument("Invalid hex character");
    }

    std::vector<uint8_t> hexStringToBytes(const std::string& hex) {
        if (hex.size() % 2 != 0) throw std::invalid_argument("Hex string must have even length");

        std::vector<uint8_t> bytes;
        for (size_t i = 0; i < hex.size(); i += 2) {
            uint8_t high = hexCharToByte(hex[i]);
            uint8_t low = hexCharToByte(hex[i + 1]);
            bytes.push_back((high << 4) | low);
        }
        return bytes;
    }

    std::string bytesToHexString(const std::vector<uint8_t>& data) {
        std::ostringstream oss;
        for (uint8_t byte : data) {
            oss << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(byte);
        }
        return oss.str();
    }