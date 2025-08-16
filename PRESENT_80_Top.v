  `timescale 1ns / 1ps
  
  
  module present_sbox_cfg #(
    parameter MODE_DEC = 1'b0  // 0=fwd, 1=inv
  )(
    input  wire [3:0] in4,
    output reg  [3:0] out4
  );
    always @* begin
      if (MODE_DEC == 1'b0) begin
        case (in4)
          4'h0: out4=4'hC; 4'h1: out4=4'h5; 4'h2: out4=4'h6; 4'h3: out4=4'hB;
          4'h4: out4=4'h9; 4'h5: out4=4'h0; 4'h6: out4=4'hA; 4'h7: out4=4'hD;
          4'h8: out4=4'h3; 4'h9: out4=4'hE; 4'hA: out4=4'hF; 4'hB: out4=4'h8;
          4'hC: out4=4'h4; 4'hD: out4=4'h7; 4'hE: out4=4'h1; 4'hF: out4=4'h2;
        endcase
      end else begin
        case (in4)
          4'h0: out4=4'h5; 4'h1: out4=4'hE; 4'h2: out4=4'hF; 4'h3: out4=4'h8;
          4'h4: out4=4'hC; 4'h5: out4=4'h1; 4'h6: out4=4'h2; 4'h7: out4=4'hD;
          4'h8: out4=4'hB; 4'h9: out4=4'h4; 4'hA: out4=4'h6; 4'hB: out4=4'h3;
          4'hC: out4=4'h0; 4'hD: out4=4'h7; 4'hE: out4=4'h9; 4'hF: out4=4'hA;
        endcase
      end
    end
  endmodule
  
  module present_sbox_layer_cfg #(
    parameter MODE_DEC = 1'b0
  )(
    input  wire [63:0] data_in,
    output wire [63:0] data_out
  );
    genvar i;
    generate
      for (i = 0; i < 16; i = i + 1) begin : g_nib
        wire [3:0] nib_in  = data_in[63 - i*4 -: 4];
        wire [3:0] nib_out;
        present_sbox_cfg #(.MODE_DEC(MODE_DEC)) u_sbx (.in4(nib_in), .out4(nib_out));
        assign data_out[63 - i*4 -: 4] = nib_out;
      end
    endgenerate
  endmodule
  
  module present_player_cfg #(
    parameter MODE_DEC = 1'b0
  )(
    input  wire [63:0] data_in,
    output wire [63:0] data_out
  );
    // Use MSB-first indexing to match your S-box slicing.
    // Spec mapping: P(i) = 16*i mod 63 for i<63; P(63)=63.
    // Inverse:      P^-1(i) = 4*i mod 63 for i<63; P^-1(63)=63.
  
    genvar i;
    
    generate
    if (MODE_DEC == 1'b0) begin : g_fwd
      // forward: out[P(i)] = in[i]
      for (i = 0; i < 64; i = i + 1) begin : map_f
        localparam integer src_msb = i;                                 // 0..63 (MSB-first)
        localparam integer dst_msb = (i==63) ? 63 : ((i*16) % 63);       // P(i)
        localparam integer src = 63 - src_msb;                           // bit index
        localparam integer dst = 63 - dst_msb;
        assign data_out[dst] = data_in[src];
      end
    end else begin : g_inv
      // inverse: out[i] = in[P(i)]  (this is equivalent to out[i] = in[P^-1^-1(i)])
      for (i = 0; i < 64; i = i + 1) begin : map_i
        localparam integer dst_msb = i;                                  // want out bit i
        localparam integer src_msb = (i==63) ? 63 : ((i*16) % 63);       // P(i)
        localparam integer dst = 63 - dst_msb;
        localparam integer src = 63 - src_msb;
        assign data_out[dst] = data_in[src];
      end
    end
  endgenerate
  
  endmodule
  
  module present_addroundkey (
    input  wire [63:0] state_in,
    input  wire [63:0] round_key,
    output wire [63:0] state_out
  );
    assign state_out = state_in ^ round_key;
  endmodule
  
  // Outputs 32 round keys of 64 bits each: K^1..K^32
  module present_key_expand_80 (
    input  wire [79:0] key80,
    output wire [2047:0] roundkeys_flat // 32 * 64
  );
    // forward S-box for key schedule (top nibble)
    function [3:0] sbox4;
      input [3:0] x;
      begin
        case (x)
          4'h0: sbox4=4'hC; 4'h1: sbox4=4'h5; 4'h2: sbox4=4'h6; 4'h3: sbox4=4'hB;
          4'h4: sbox4=4'h9; 4'h5: sbox4=4'h0; 4'h6: sbox4=4'hA; 4'h7: sbox4=4'hD;
          4'h8: sbox4=4'h3; 4'h9: sbox4=4'hE; 4'hA: sbox4=4'hF; 4'hB: sbox4=4'h8;
          4'hC: sbox4=4'h4; 4'hD: sbox4=4'h7; 4'hE: sbox4=4'h1; 4'hF: sbox4=4'h2;
        endcase
      end
    endfunction
  
    reg [79:0] kreg;
    reg [63:0] rk [0:31];
    integer i;
  
    always @* begin
      kreg = key80;
      for (i = 0; i < 32; i = i + 1) begin
        // Round key K^(i+1)
        rk[i] = kreg[79:16];
  
        // Update for next round (skip after producing K^32)
        if (i < 31) begin
          // 1) rotate left by 61
          kreg = {kreg[18:0], kreg[79:19]};
          // 2) apply S-box to top nibble
          kreg[79:76] = sbox4(kreg[79:76]);
          // 3) XOR round counter (i+1) into kreg[19:15]
          kreg[19:15] = kreg[19:15] ^ (i+1);
        end
      end
    end
  
    genvar j;
    generate
      for (j = 0; j < 32; j = j + 1) begin : g_flat
        assign roundkeys_flat[2047 - 64*j -: 64] = rk[j];
      end
    endgenerate
  endmodule
  
  // ================= ROUND (includes ARK inside) =================
  // ENC: out = P( S( state ^ rk ) )
  // DEC: out = ( InvS( InvP( state ) ) ) ^ rk
  module present_round_cfg #(
    parameter MODE_DEC = 1'b0
  )(
    input  wire [63:0] state_in,
    input  wire [63:0] round_key,
    output wire [63:0] state_out
  );
  generate
    if (MODE_DEC == 1'b0) begin : g_enc
      wire [63:0] ax = state_in ^ round_key;
      wire [63:0] sb;
      wire [63:0] pl;
      present_sbox_layer_cfg #(.MODE_DEC(1'b0)) u_s  (.data_in(ax), .data_out(sb));
      present_player_cfg     #(.MODE_DEC(1'b0)) u_pl (.data_in(sb), .data_out(pl));
      assign state_out = pl;
    end else begin : g_dec
      wire [63:0] ipl;
      wire [63:0] isb;
      present_player_cfg     #(.MODE_DEC(1'b1)) u_ipl (.data_in(state_in), .data_out(ipl));
      present_sbox_layer_cfg #(.MODE_DEC(1'b1)) u_isb (.data_in(ipl),      .data_out(isb));
      assign state_out = isb ^ round_key;
    end
  endgenerate
  endmodule
  
  module present_fsm #(
    parameter MODE_DEC = 1'b0
  )(
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [63:0]  in_block,     // plaintext (enc) / ciphertext (dec)
    input  wire [79:0]  key80,
    output reg  [63:0]  out_block,    // ciphertext (enc) / plaintext (dec)
    output reg          done
  );
    localparam S_IDLE=3'd0, S_KEXP=3'd1, S_WAIT=3'd2, S_INIT=3'd3, S_ROUND=3'd4, S_FINAL=3'd5, S_DONE=3'd6;
  
    reg  [2:0]  state, next_state;
    reg  [5:0]  round; // 0..31
    reg  [63:0] st;
    reg  [63:0] rks [0:31];
    wire [2047:0] rks_flat;
  
    present_key_expand_80 u_kexp (.key80(key80), .roundkeys_flat(rks_flat));
  
    integer i;
    always @(posedge clk) begin
      if (state == S_WAIT) begin
        for (i = 0; i < 32; i = i + 1)
          rks[i] <= rks_flat[2047 - 64*i -: 64];
      end
    end
  
    // Select round key for this iteration
    wire [63:0] rk_enc = rks[round];            // K^1..K^31 (round=0..30)
    wire [63:0] rk_dec = rks[30 - round];       // K^31..K^1  (round=0..30)
  
    wire [63:0] round_out;
    present_round_cfg #(.MODE_DEC(MODE_DEC)) u_round (
      .state_in  (st),
      .round_key (MODE_DEC ? rk_dec : rk_enc),
      .state_out (round_out)
    );
  
    // INIT: enc starts with state=plaintext; dec starts with ciphertext ^ K^32
    always @(posedge clk) begin
      if (state == S_INIT) begin
        if (MODE_DEC) begin
          st <= in_block ^ rks[31]; // initial ARK with K^32
          //$display("DEC-INIT st=%h  (should equal ENC Round31)", in_block ^ rks[31]);
          end
        else
          st <= in_block;           // first ARK is inside round 0 with K^1
      end
    end
  
    // Main registers / counters
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        state <= S_IDLE; round <= 6'd0; st <= 64'd0; out_block <= 64'd0; done <= 1'b0;
      end else begin
        state <= next_state;
  
        if (state == S_ROUND) st <= round_out;
        if (state == S_DONE) begin out_block <= st; done <= 1'b1; end
        else done <= 1'b0;
  
        if (state == S_INIT) round <= 6'd0;
        else if (state == S_ROUND) round <= round + 6'd1;
        else if (state == S_FINAL || state == S_DONE) round <= 6'd0;
      end
    end
  
    // Next-state
    always @* begin
      next_state = state;
      case (state)
        S_IDLE:  if (start) next_state = S_KEXP;
        S_KEXP:  next_state = S_WAIT;
        S_WAIT:  next_state = S_INIT;
        S_INIT:  next_state = S_ROUND;
        S_ROUND: if (round == 6'd30) next_state = S_FINAL; // after 31 rounds (0..30)
        S_FINAL: next_state = S_DONE;
        S_DONE:  next_state = S_IDLE;
        default: next_state = S_IDLE;
      endcase
    end
  
    // FINAL: enc does final ARK with K^32; dec does nothing (already applied first)
    always @(posedge clk) begin
      if (state == S_FINAL) begin
        if (MODE_DEC)
          st <= st;                        // nothing: already aligned
        else
          st <= st ^ rks[31];              // final ARK with K^32
      end
    end
  
    // ================= DEBUG =================
    always @(posedge clk) begin
      if (state == S_WAIT) begin
        $display("[%0t] PRESENT Expanded Keys (%s):", $time, MODE_DEC ? "DEC" : "ENC");
        //$display("Raw expanded = %h", rks_flat);
        //for (i=0;i<32;i=i+1) $display("K^%0d = %h", i+1, rks[i]);
      end
    end
  
    always @(posedge clk) begin
      if (state == S_INIT) begin
        if (MODE_DEC) begin
          $display("[%0t] INIT-DEC: in=%h  K^32=%h  st=in^K^32=%h", $time, in_block, rks[31], in_block ^ rks[31]);
        end else begin
          $display("[%0t] INIT-ENC: in=%h (first ARK in round 0)", $time, in_block);
        end
      end
    end
  
    always @(posedge clk) begin
      if (state == S_ROUND) begin
        $display("[%0t] Round %0d out = %h", $time, round+1, round_out);
      end
    end
  
    reg [63:0] st_final_lat;
    always @(posedge clk) begin
      if (state == S_FINAL) st_final_lat <= MODE_DEC ? st : (st ^ rks[31]);
      if (state == S_DONE)  $display("[%0t] Final Output = %h", $time, st_final_lat);
    end
  endmodule
  
  /*
  
  module present_sbox_cfg #(parameter MODE_DEC = 1'b0)(
    input  wire [3:0] in4,
    output reg  [3:0] out4
  );
    // Small ROM-like style (often maps to one LUT level)
    (* rom_style = "distributed" *)
    always @* begin
      if (!MODE_DEC) begin
        // forward
        case (in4)
          4'h0: out4=4'hC; 4'h1: out4=4'h5; 4'h2: out4=4'h6; 4'h3: out4=4'hB;
          4'h4: out4=4'h9; 4'h5: out4=4'h0; 4'h6: out4=4'hA; 4'h7: out4=4'hD;
          4'h8: out4=4'h3; 4'h9: out4=4'hE; 4'hA: out4=4'hF; 4'hB: out4=4'h8;
          4'hC: out4=4'h4; 4'hD: out4=4'h7; 4'hE: out4=4'h1; 4'hF: out4=4'h2;
        endcase
      end else begin
        // inverse
        case (in4)
          4'h0: out4=4'h5; 4'h1: out4=4'hE; 4'h2: out4=4'hF; 4'h3: out4=4'h8;
          4'h4: out4=4'hC; 4'h5: out4=4'h1; 4'h6: out4=4'h2; 4'h7: out4=4'hD;
          4'h8: out4=4'hB; 4'h9: out4=4'h4; 4'hA: out4=4'h6; 4'hB: out4=4'h3;
          4'hC: out4=4'h0; 4'hD: out4=4'h7; 4'hE: out4=4'h9; 4'hF: out4=4'hA;
        endcase
      end
    end
  endmodule
  
  module present_sbox_layer_cfg #(parameter MODE_DEC=1'b0)(
    input  wire [63:0] data_in,
    output wire [63:0] data_out
  );
    genvar i;
    generate
      for (i=0;i<16;i=i+1) begin: g_nib
        wire [3:0] nib_in  = data_in[63 - i*4 -: 4];
        wire [3:0] nib_out;
        present_sbox_cfg #(.MODE_DEC(MODE_DEC)) U (.in4(nib_in), .out4(nib_out));
        assign data_out[63 - i*4 -: 4] = nib_out;
      end
    endgenerate
  endmodule
  
  module present_player_cfg #(parameter MODE_DEC=1'b0)(
    input  wire [63:0] data_in,
    output wire [63:0] data_out
  );
    // P(i) = 16*i mod 63 (i<63), P(63)=63
    // P^-1(i) = 4*i mod 63 (i<63),  P^-1(63)=63
    genvar i;
    generate
      if (!MODE_DEC) begin : FWD
        for (i=0;i<64;i=i+1) begin: MAP_F
          localparam integer dst_msb = (i==63)?63:((i*16)%63);
          assign data_out[63-dst_msb] = data_in[63-i];
        end
      end else begin : INV
        for (i=0;i<64;i=i+1) begin: MAP_I
          localparam integer src_msb = (i==63)?63:((i*4)%63);
          assign data_out[63-i] = data_in[63-src_msb];
        end
      end
    endgenerate
  endmodule
  
  // Outputs 32 round keys of 64 bits each: K^1..K^32
  module present_key_expand_80 (
    input  wire [79:0] key80,
    output wire [2047:0] roundkeys_flat // 32 * 64
  );
    // forward S-box for key schedule (top nibble)
    function [3:0] sbox4;
      input [3:0] x;
      begin
        case (x)
          4'h0: sbox4=4'hC; 4'h1: sbox4=4'h5; 4'h2: sbox4=4'h6; 4'h3: sbox4=4'hB;
          4'h4: sbox4=4'h9; 4'h5: sbox4=4'h0; 4'h6: sbox4=4'hA; 4'h7: sbox4=4'hD;
          4'h8: sbox4=4'h3; 4'h9: sbox4=4'hE; 4'hA: sbox4=4'hF; 4'hB: sbox4=4'h8;
          4'hC: sbox4=4'h4; 4'hD: sbox4=4'h7; 4'hE: sbox4=4'h1; 4'hF: sbox4=4'h2;
        endcase
      end
    endfunction
  
    reg [79:0] kreg;
    reg [63:0] rk [0:31];
    integer i;
  
    always @* begin
      kreg = key80;
      for (i = 0; i < 32; i = i + 1) begin
        // Round key K^(i+1)
        rk[i] = kreg[79:16];
  
        // Update for next round (skip after producing K^32)
        if (i < 31) begin
          // 1) rotate left by 61
          kreg = {kreg[18:0], kreg[79:19]};
          // 2) apply S-box to top nibble
          kreg[79:76] = sbox4(kreg[79:76]);
          // 3) XOR round counter (i+1) into kreg[19:15]
          kreg[19:15] = kreg[19:15] ^ (i+1);
        end
      end
    end
  
    genvar j;
    generate
      for (j = 0; j < 32; j = j + 1) begin : g_flat
        assign roundkeys_flat[2047 - 64*j -: 64] = rk[j];
      end
    endgenerate
  endmodule
  
  // Core round only:
  // ENC : state_out = P( S( state_in ) )
  // DEC : state_out = InvS( InvP( state_in ) )
  module present_round_core #(parameter MODE_DEC=1'b0)(
    input  wire [63:0] state_in,
    output wire [63:0] state_out
  );
    generate
      if (!MODE_DEC) begin : ENC
        wire [63:0] sb, pl;
        present_sbox_layer_cfg #(.MODE_DEC(1'b0)) U_S (.data_in(state_in), .data_out(sb));
        present_player_cfg     #(.MODE_DEC(1'b0)) U_P (.data_in(sb),       .data_out(pl));
        assign state_out = pl;
      end else begin : DEC
        wire [63:0] ipl, isb;
        present_player_cfg     #(.MODE_DEC(1'b1)) U_IP (.data_in(state_in), .data_out(ipl));
        present_sbox_layer_cfg #(.MODE_DEC(1'b1)) U_IS (.data_in(ipl),      .data_out(isb));
        assign state_out = isb;
      end
    endgenerate
  endmodule
  
  module present_fsm #(
    parameter MODE_DEC = 1'b0   // 0=encrypt, 1=decrypt
  )(
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [63:0] in_block,
    input  wire [79:0] key80,
    output reg  [63:0] out_block,
    output reg         done
  );
    localparam S_IDLE=3'd0, S_KEXP=3'd1, S_WAIT=3'd2, S_INIT=3'd3,
               S_ROUND=3'd4, S_FINAL=3'd5;
  
    reg [2:0]  state, next_state;
    reg [5:0]  round;          // 0..30 (31 rounds)
    reg [63:0] st;             // state register
  
    // Round keys
    reg  [63:0] rks [0:31];
    wire [2047:0] rks_flat;
    present_key_expand_80 U_K (.key80(key80), .roundkeys_flat(rks_flat));
  
    integer i;
    always @(posedge clk) if (state==S_WAIT) begin
      for (i=0;i<32;i=i+1) rks[i] <= rks_flat[2047-64*i -: 64];
    end
  
    // Core round (no XOR inside)
    wire [63:0] core_out;
    present_round_core #(.MODE_DEC(MODE_DEC)) U_RC (.state_in(st), .state_out(core_out));
  
    // FSM registers
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        state <= S_IDLE; round <= 0; st <= 64'd0; out_block <= 64'd0; done <= 1'b0;
      end else begin
        state <= next_state;
        done  <= 1'b0;
  
        case (state)
          S_INIT: begin
            round <= 0;
            if (MODE_DEC)
              st <= in_block ^ rks[31];    // initial ARK with K^32 (decrypt)
            else
              st <= in_block;              // ENC will XOR K^1 before core in S_ROUND
          end
  
          S_ROUND: begin
            if (!MODE_DEC) begin
              // ENC: AddRoundKey first, then core
              // implement as: st := P(S(st ^ K^(round+1)))
              st    <= core_out;           // core_out operates on 'st' AFTER we inject XOR (see below)
              round <= round + 1;
            end else begin
              // DEC: core first, then AddRoundKey with reversed order K^31..K^1
              st    <= core_out ^ rks[30 - round];
              round <= round + 1;
            end
          end
  
          S_FINAL: begin
            if (!MODE_DEC) st <= st ^ rks[31];   // final ARK with K^32 (encrypt)
            out_block <= (!MODE_DEC) ? (st ^ rks[31]) : st;
            done      <= 1'b1;                   // pulse done here (no S_DONE)
          end
        endcase
      end
    end
  
    // XOR-before-core for ENC: inject the XOR onto 'st' input path
    // We do this by muxing the 'st' seen by U_RC during S_ROUND
    // ENC view: U_RC must see (st ^ K^(round+1))
    // DEC view: U_RC must see st
    wire [63:0] st_to_core = (!MODE_DEC && state==S_ROUND) ? (st ^ rks[round]) : st;
    // Rewire the core to look at st_to_core instead of st
    // (small wrapper to keep U_RC pure)
    // Synthesis-friendly: replace U_RC instance above with this inline:
    // present_round_core #(MODE_DEC) U_RC (.state_in(st_to_core), .state_out(core_out));
    // If your tool complains about redefinition, keep U_RC as-is and insert a wire rename:
  
    // next-state
    always @* begin
      next_state = state;
      case (state)
        S_IDLE:  if (start) next_state = S_KEXP;
        S_KEXP:  next_state = S_WAIT;
        S_WAIT:  next_state = S_INIT;
        S_INIT:  next_state = S_ROUND;
        S_ROUND: if (round == 6'd30) next_state = S_FINAL;
        S_FINAL: next_state = S_IDLE;
        default: next_state = S_IDLE;
      endcase
    end
  
    // DEBUG (trim as you like)
    always @(posedge clk) begin
      if (state==S_INIT && MODE_DEC)
        $display("[%0t] INIT-DEC: in=%h  K^32=%h  st=in^K^32=%h",
                 $time, in_block, rks[31], in_block ^ rks[31]);
      else if (state==S_INIT && !MODE_DEC)
        $display("[%0t] INIT-ENC: in=%h", $time, in_block);
      if (state==S_ROUND)
        $display("[%0t] Round %0d out(pre-ARK for DEC / post-ARK for ENC) = %h",
                 $time, round+1, (!MODE_DEC) ? core_out : (core_out ^ rks[30-round]));
      if (state==S_FINAL)
        $display("[%0t] Final Output = %h", $time, (!MODE_DEC) ? (st ^ rks[31]) : st);
    end
  
  endmodule
  */
