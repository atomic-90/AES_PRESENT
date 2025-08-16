  `timescale 1ns / 1ps
  
  module tb_aes_fsm_combo;
  
    // Clock/Reset
    reg clk = 0;
    reg rst = 1;
  
    // Starts (separate pulses for enc/dec)
    reg start_enc = 0;
    reg start_dec = 0;
  
    // Common key
    reg  [127:0] key;
  
    // Encrypt path
    reg  [127:0] pt_in;
    wire [127:0] ct_out;
    wire         enc_done;
  
    // Decrypt path
    reg  [127:0] ct_in_dec;
    wire [127:0] pt_out_dec;
    wire         dec_done;
  
    // Cycle counting
    integer cyc = 0;
    integer enc_start_cyc = 0, enc_end_cyc = 0;
    integer dec_start_cyc = 0, dec_end_cyc = 0;
  
    // FIPS-197 known answers
    localparam [127:0] EXP_PT = 128'h00112233445566778899aabbccddeeff;
    localparam [127:0] EXP_CT = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
    localparam [127:0] EXP_K  = 128'h000102030405060708090a0b0c0d0e0f;
  
    // 100 MHz clock
    always #5 clk = ~clk;
  
    // Synchronous cycle counter
    always @(posedge clk) begin
      cyc <= rst ? 0 : (cyc + 1);
    end
  
    // =========================
    // DUTs
    // =========================
  
    // Encrypt DUT (MODE_DEC=0)
    // If your aes_fsm uses plaintext/ciphertext port names, replace:
    //   .in_block(pt_in)    -> .plaintext(pt_in)
    //   .out_block(ct_out)  -> .ciphertext(ct_out)
    aes_fsm #(.MODE_DEC(1'b0)) u_enc (
      .clk        (clk),
      .reset      (rst),
      .start      (start_enc),
      .in_block   (pt_in),
      .cipher_key (key),
      .out_block  (ct_out),
      .done       (enc_done)
    );
  
    // Decrypt DUT (MODE_DEC=1)
    aes_fsm #(.MODE_DEC(1'b1)) u_dec (
      .clk        (clk),
      .reset      (rst),
      .start      (start_dec),
      .in_block   (ct_in_dec),
      .cipher_key (key),
      .out_block  (pt_out_dec),
      .done       (dec_done)
    );
  
    // =========================
    // Test sequence
    // =========================
    initial begin
      // Init inputs
      key       = 128'h0;
      pt_in     = 128'h0;
      ct_in_dec = 128'h0;
  
      // Reset for a few cycles
      repeat (3) @(posedge clk);
      rst <= 1'b0;
  
      // Load FIPS-197 vector
      key   <= EXP_K;
      pt_in <= EXP_PT;
  
      // -------------------------
      // Encrypt phase
      // -------------------------
      @(posedge clk);
      start_enc <= 1'b1; enc_start_cyc = cyc;
      @(posedge clk);
      start_enc <= 1'b0;
  
      // Wait for encryption to finish
      wait (enc_done == 1'b1);
      enc_end_cyc = cyc;
  
      // Quick check of encryption result
      $display("\n---------------- ENCRYPT RESULT ----------------");
      $display("Plaintext          : %h", pt_in);
      $display("Key                : %h", key);
      $display("Ciphertext (DUT)   : %h", ct_out);
      $display("Ciphertext (Exp)   : %h", EXP_CT);
      $display("Latency (cycles)   : %0d", enc_end_cyc - enc_start_cyc);
      $display("Encrypt PASS?      : %s", (ct_out === EXP_CT) ? "YES" : "NO");
  
      // -------------------------
      // Decrypt phase (feed enc output)
      // -------------------------
      // Present ciphertext to decryptor, then pulse start
      @(posedge clk);
      ct_in_dec <= ct_out;
  
      @(posedge clk);
      start_dec <= 1'b1; dec_start_cyc = cyc;
      @(posedge clk);
      start_dec <= 1'b0;
  
      // Wait for decryption to finish
      wait (dec_done == 1'b1);
      dec_end_cyc = cyc;
  
      // Final checks
      $display("\n---------------- DECRYPT RESULT ----------------");
      $display("Ciphertext         : %h", ct_in_dec);
      $display("Key                : %h", key);
      $display("Plaintext (DUT)    : %h", pt_out_dec);
      $display("Plaintext (Exp)    : %h", EXP_PT);
      $display("Latency (cycles)   : %0d", dec_end_cyc - dec_start_cyc);
      $display("Decrypt PASS?      : %s", (pt_out_dec === EXP_PT) ? "YES" : "NO");
  
      // Round-trip check
      $display("\n==================== SUMMARY ===================");
      $display("Encrypt PASS       : %s", (ct_out === EXP_CT) ? "YES" : "NO");
      $display("Decrypt PASS       : %s", (pt_out_dec === EXP_PT) ? "YES" : "NO");
      $display("Round-trip PASS    : %s", (pt_out_dec === pt_in) ? "YES" : "NO");
      $display("Enc Latency (cyc)  : %0d", enc_end_cyc - enc_start_cyc);
      $display("Dec Latency (cyc)  : %0d", dec_end_cyc - dec_start_cyc);
      $display("================================================\n");
  
      #20 $finish;
    end
  
  endmodule
