  `timescale 1ns/1ps
  module tb_present_combo;
    reg clk=0, rst=1, start_enc=0, start_dec=0;
    reg  [63:0]  pt_in;
    reg  [79:0]  key80;
    wire [63:0]  ct_out;
    wire         enc_done;
  
    reg  [63:0]  ct_in_dec;
    wire [63:0]  pt_out_dec;
    wire         dec_done;
  
    integer cyc=0, enc_s=0, enc_e=0, dec_s=0, dec_e=0;
  
    localparam [63:0]  EXP_CT = 64'h5579C1387B228445;
    localparam [63:0]  EXP_PT = 64'h0000000000000000;
    localparam [79:0]  EXP_K  = 80'h00000000000000000000;
  
    always #5 clk = ~clk;
    always @(posedge clk) cyc <= rst ? 0 : (cyc+1);
  
    // ENC
    present_fsm #(.MODE_DEC(1'b0)) u_enc (
      .clk(clk), .reset(rst), .start(start_enc),
      .in_block(pt_in), .key80(key80),
      .out_block(ct_out), .done(enc_done)
    );
  
    // DEC
    present_fsm #(.MODE_DEC(1'b1)) u_dec (
      .clk(clk), .reset(rst), .start(start_dec),
      .in_block(ct_in_dec), .key80(key80),
      .out_block(pt_out_dec), .done(dec_done)
    );
  
    initial begin
      pt_in  = 64'd0;
      key80  = 80'd0;
      ct_in_dec = 64'd0;
  
      repeat (3) @(posedge clk);
      rst <= 0;
  
      // FIPS vector: P=0, K=0 → C=5579C1387B228445
      pt_in <= EXP_PT; key80 <= EXP_K;
  
      // ENC
      @(posedge clk); start_enc <= 1; enc_s = cyc;
      @(posedge clk); start_enc <= 0;
      wait (enc_done); enc_e = cyc;
  
      $display("\n----- PRESENT ENC -----");
      $display("PT  : %h", pt_in);
      $display("KEY : %h", key80);
      $display("CT  : %h", ct_out);
      $display("EXP : %h", EXP_CT);
      $display("LAT : %0d cycles", enc_e-enc_s);
      $display("PASS: %s", (ct_out===EXP_CT) ? "YES":"NO");
  
      // DEC (feed CT)
      @(posedge clk); ct_in_dec <= ct_out;
      @(posedge clk); start_dec <= 1; dec_s = cyc;
      @(posedge clk); start_dec <= 0;
      wait (dec_done); dec_e = cyc;
  
      $display("\n----- PRESENT DEC -----");
      $display("CT  : %h", ct_in_dec);
      $display("KEY : %h", key80);
      $display("PT  : %h", pt_out_dec);
      $display("EXP : %h", EXP_PT);
      $display("LAT : %0d cycles", dec_e-dec_s);
      $display("PASS: %s", (pt_out_dec===EXP_PT) ? "YES":"NO");
  
      $display("\n===== SUMMARY =====");
      $display("ENC PASS: %s", (ct_out===EXP_CT) ? "YES":"NO");
      $display("DEC PASS: %s", (pt_out_dec===EXP_PT) ? "YES":"NO");
      $display("RT  PASS: %s", (pt_out_dec===pt_in) ? "YES":"NO");
      $display("===================\n");
  
      #20 $finish;
    end
  endmodule
