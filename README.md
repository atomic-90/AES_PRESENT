## SOFTWARE PART ==================================================================

### AES_PRESENT

Implementation of AES and PRESENT using c++ for software and verilog for FPGA based designs

# _FEATURES_

– AES (128/192/256) and PRESENT (80/128) block ciphers
– CTR mode for arbitrary files and BMP images (no padding required)
– Single-thread and multi-thread paths (std::thread)
– Built-in performance telemetry: wall/CPU time, peak RSS, time/KB, relative energy proxy
– Known-Answer Tests (NIST AES; PRESENT spec vectors)

# _REPO LAYOUT_

AES_PRESENT_PROJECT/
├─ AES/
│ ├─ aes.h, aes.cpp # AES core (S-box, MixColumns, KeyExpansion, CTR helpers)
│ ├─ hexutils.h, hexutils.cpp # Hex and I/O helpers
│ ├─ main.cpp # CLI entry for AES
│ └─ input/ sample.bmp tiny.bin large.bin
└─ PRESENT/
├─ present.h, present.cpp # PRESENT core (S-box/pLayer, 80/128-bit KSchedule, CTR)
├─ hexutils.h, hexutils.cpp
├─ main.cpp # CLI entry for PRESENT
└─ input/ sample.bmp tiny.bin large.bin

# _AES CLI_

cd AES_PRESENT_PROJECT/AES
g++ -std=c++17 main.cpp aes.cpp hexutils.cpp -o aes_cli

# _PRESENT CLI_

cd ../PRESENT
g++ -std=c++17 main.cpp present.cpp hexutils.cpp -o present_cli

# _AES-128 CTR encrypt BMP_

./aes_cli \
 --aes 128 --mode ctr --encrypt \
 --key 00112233445566778899aabbccddeeff \
 --nonce aabbccddeeff0011 \
 --filetype bmp \
 --infile ./input/sample.bmp \
 --outfile ./out/sample_enc.bmp

# _AES-128 CTR decrypt BMP and verify round-trip_

./aes_cli --aes 128 --mode ctr --decrypt \
 --key 00112233445566778899aabbccddeeff \
 --nonce aabbccddeeff0011 \
 --filetype bmp \
 --infile ./out/sample_enc.bmp \
 --outfile ./out/sample_dec.bmp

cmp -s ./input/sample.bmp ./out/sample_dec.bmp && echo "IDENTICAL"

# _AES (single-thread example)_

./aes_cli --aes 128 --mode ctr --encrypt \
 --key 00112233445566778899aabbccddeeff \
 --nonce aabbccddeeff0011 \
 --filetype bin \
 --infile ./input/large.bin \
 --outfile ./out/large.aes128.ctr.bin

# _PRESENT (80-bit key)_

./present_cli --present 80 --mode ctr --encrypt \
 --key ffffffffffffffffffff \
 --nonce 0000000000000000 \
 --filetype bin \
 --infile ./input/large.bin \
 --outfile ./out/large.present80.ctr.bin

# _CLI options (common)_

    •	--mode ctr (required)
    •	--encrypt | --decrypt (operation)
    •	--aes 128|192|256 or --present 80|128
    •	--key <hex> (16/24/32 bytes for AES; 10/16 bytes for PRESENT)
    •	--nonce <hex> (8 bytes, big-endian)
    •	--filetype bmp|bin
    •	--infile <path> --outfile <path>
    •	Optional multi-thread flag if exposed by your CLI (e.g., --threads 4)

## HARDWARE PART =====================================================================

# _Toolchain & target_

    •	Vivado (tested with 20xx.x)
    •	Device: xc7z020-1clg400 (Zynq-7000)
    •	Clock: 100 MHz (10 ns) default
    •	Top modules:
    •	aes_fsm (AES-128 core)
    •	present_fsm (PRESENT-80 core)
    •	Testbenches:
    •	tb_aes_fsm_combo
    •	tb_present_combo

# _Design overview_

    •	AES-128 (iterative, 1 round/cycle)
    •	Datapath: SubBytes → ShiftRows → MixColumns → AddRoundKey
    •	Final round omits MixColumns
    •	Key expansion precomputes 11 round keys (K⁰..K¹⁰)
    •	Controller FSM: IDLE → LOAD → ARK0 → ROUND[1..9] → FINAL → DONE
    •	PRESENT-80 (iterative, 1 round/cycle)
    •	Datapath per round: AddRoundKey → S-box layer (16×4-bit) → pLayer
    •	31 rounds + final AddRoundKey
    •	80-bit key schedule (rotate-61, S-box top nibble, round-counter XOR)
    •	Controller FSM: IDLE → LOAD → ROUND[1..31] → FINAL_ARK → DONE
