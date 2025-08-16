`timescale 1ns / 1ps


module aes_sbox_cfg #(
    parameter MODE_DEC = 1'b0  // 0 = forward S-box, 1 = inverse S-box
)(
    input  wire [7:0] in,
    output reg  [7:0] out
);
generate
if (MODE_DEC == 1'b0) begin : g_fwd
    always @* begin
        case (in)
            8'h00: out = 8'h63; 8'h01: out = 8'h7c; 8'h02: out = 8'h77; 8'h03: out = 8'h7b;
            8'h04: out = 8'hf2; 8'h05: out = 8'h6b; 8'h06: out = 8'h6f; 8'h07: out = 8'hc5;
            8'h08: out = 8'h30; 8'h09: out = 8'h01; 8'h0a: out = 8'h67; 8'h0b: out = 8'h2b;
            8'h0c: out = 8'hfe; 8'h0d: out = 8'hd7; 8'h0e: out = 8'hab; 8'h0f: out = 8'h76;

            8'h10: out = 8'hca; 8'h11: out = 8'h82; 8'h12: out = 8'hc9; 8'h13: out = 8'h7d;
            8'h14: out = 8'hfa; 8'h15: out = 8'h59; 8'h16: out = 8'h47; 8'h17: out = 8'hf0;
            8'h18: out = 8'had; 8'h19: out = 8'hd4; 8'h1a: out = 8'ha2; 8'h1b: out = 8'haf;
            8'h1c: out = 8'h9c; 8'h1d: out = 8'ha4; 8'h1e: out = 8'h72; 8'h1f: out = 8'hc0;

            8'h20: out = 8'hb7; 8'h21: out = 8'hfd; 8'h22: out = 8'h93; 8'h23: out = 8'h26;
            8'h24: out = 8'h36; 8'h25: out = 8'h3f; 8'h26: out = 8'hf7; 8'h27: out = 8'hcc;
            8'h28: out = 8'h34; 8'h29: out = 8'ha5; 8'h2a: out = 8'he5; 8'h2b: out = 8'hf1;
            8'h2c: out = 8'h71; 8'h2d: out = 8'hd8; 8'h2e: out = 8'h31; 8'h2f: out = 8'h15;

            8'h30: out = 8'h04; 8'h31: out = 8'hc7; 8'h32: out = 8'h23; 8'h33: out = 8'hc3;
            8'h34: out = 8'h18; 8'h35: out = 8'h96; 8'h36: out = 8'h05; 8'h37: out = 8'h9a;
            8'h38: out = 8'h07; 8'h39: out = 8'h12; 8'h3a: out = 8'h80; 8'h3b: out = 8'he2;
            8'h3c: out = 8'heb; 8'h3d: out = 8'h27; 8'h3e: out = 8'hb2; 8'h3f: out = 8'h75;

            8'h40: out = 8'h09; 8'h41: out = 8'h83; 8'h42: out = 8'h2c; 8'h43: out = 8'h1a;
            8'h44: out = 8'h1b; 8'h45: out = 8'h6e; 8'h46: out = 8'h5a; 8'h47: out = 8'ha0;
            8'h48: out = 8'h52; 8'h49: out = 8'h3b; 8'h4a: out = 8'hd6; 8'h4b: out = 8'hb3;
            8'h4c: out = 8'h29; 8'h4d: out = 8'he3; 8'h4e: out = 8'h2f; 8'h4f: out = 8'h84;

            8'h50: out = 8'h53; 8'h51: out = 8'hd1; 8'h52: out = 8'h00; 8'h53: out = 8'hed;
            8'h54: out = 8'h20; 8'h55: out = 8'hfc; 8'h56: out = 8'hb1; 8'h57: out = 8'h5b;
            8'h58: out = 8'h6a; 8'h59: out = 8'hcb; 8'h5a: out = 8'hbe; 8'h5b: out = 8'h39;
            8'h5c: out = 8'h4a; 8'h5d: out = 8'h4c; 8'h5e: out = 8'h58; 8'h5f: out = 8'hcf;

            8'h60: out = 8'hd0; 8'h61: out = 8'hef; 8'h62: out = 8'haa; 8'h63: out = 8'hfb;
            8'h64: out = 8'h43; 8'h65: out = 8'h4d; 8'h66: out = 8'h33; 8'h67: out = 8'h85;
            8'h68: out = 8'h45; 8'h69: out = 8'hf9; 8'h6a: out = 8'h02; 8'h6b: out = 8'h7f;
            8'h6c: out = 8'h50; 8'h6d: out = 8'h3c; 8'h6e: out = 8'h9f; 8'h6f: out = 8'ha8;

            8'h70: out = 8'h51; 8'h71: out = 8'ha3; 8'h72: out = 8'h40; 8'h73: out = 8'h8f;
            8'h74: out = 8'h92; 8'h75: out = 8'h9d; 8'h76: out = 8'h38; 8'h77: out = 8'hf5;
            8'h78: out = 8'hbc; 8'h79: out = 8'hb6; 8'h7a: out = 8'hda; 8'h7b: out = 8'h21;
            8'h7c: out = 8'h10; 8'h7d: out = 8'hff; 8'h7e: out = 8'hf3; 8'h7f: out = 8'hd2;

            8'h80: out = 8'hcd; 8'h81: out = 8'h0c; 8'h82: out = 8'h13; 8'h83: out = 8'hec;
            8'h84: out = 8'h5f; 8'h85: out = 8'h97; 8'h86: out = 8'h44; 8'h87: out = 8'h17;
            8'h88: out = 8'hc4; 8'h89: out = 8'ha7; 8'h8a: out = 8'h7e; 8'h8b: out = 8'h3d;
            8'h8c: out = 8'h64; 8'h8d: out = 8'h5d; 8'h8e: out = 8'h19; 8'h8f: out = 8'h73;
		
		    8'h90: out = 8'h60; 8'h91: out = 8'h81; 8'h92: out = 8'h4f; 8'h93: out = 8'hdc;
		    8'h94: out = 8'h22; 8'h95: out = 8'h2a; 8'h96: out = 8'h90; 8'h97: out = 8'h88;
		    8'h98: out = 8'h46; 8'h99: out = 8'hee; 8'h9a: out = 8'hb8; 8'h9b: out = 8'h14;
		    8'h9c: out = 8'hde; 8'h9d: out = 8'h5e; 8'h9e: out = 8'h0b; 8'h9f: out = 8'hdb;

            8'ha0: out = 8'he0; 8'ha1: out = 8'h32; 8'ha2: out = 8'h3a; 8'ha3: out = 8'h0a;
		    8'ha4: out = 8'h49; 8'ha5: out = 8'h06; 8'ha6: out = 8'h24; 8'ha7: out = 8'h5c;
		    8'ha8: out = 8'hc2; 8'ha9: out = 8'hd3; 8'haa: out = 8'hac; 8'hab: out = 8'h62;
		    8'hac: out = 8'h91; 8'had: out = 8'h95; 8'hae: out = 8'he4; 8'haf: out = 8'h79;

            8'hb0: out = 8'he7; 8'hb1: out = 8'hc8; 8'hb2: out = 8'h37; 8'hb3: out = 8'h6d;
		    8'hb4: out = 8'h8d; 8'hb5: out = 8'hd5; 8'hb6: out = 8'h4e; 8'hb7: out = 8'ha9;
		    8'hb8: out = 8'h6c; 8'hb9: out = 8'h56; 8'hba: out = 8'hf4; 8'hbb: out = 8'hea;
		    8'hbc: out = 8'h65; 8'hbd: out = 8'h7a; 8'hbe: out = 8'hae; 8'hbf: out = 8'h08;

            8'hc0: out = 8'hba; 8'hc1: out = 8'h78; 8'hc2: out = 8'h25; 8'hc3: out = 8'h2e;
		    8'hc4: out = 8'h1c; 8'hc5: out = 8'ha6; 8'hc6: out = 8'hb4; 8'hc7: out = 8'hc6;
		    8'hc8: out = 8'he8; 8'hc9: out = 8'hdd; 8'hca: out = 8'h74; 8'hcb: out = 8'h1f;
		    8'hcc: out = 8'h4b; 8'hcd: out = 8'hbd; 8'hce: out = 8'h8b; 8'hcf: out = 8'h8a;

            8'hd0: out = 8'h70; 8'hd1: out = 8'h3e; 8'hd2: out = 8'hb5; 8'hd3: out = 8'h66;
		    8'hd4: out = 8'h48; 8'hd5: out = 8'h03; 8'hd6: out = 8'hf6; 8'hd7: out = 8'h0e;
		    8'hd8: out = 8'h61; 8'hd9: out = 8'h35; 8'hda: out = 8'h57; 8'hdb: out = 8'hb9;
		    8'hdc: out = 8'h86; 8'hdd: out = 8'hc1; 8'hde: out = 8'h1d; 8'hdf: out = 8'h9e;

            8'he0: out = 8'he1; 8'he1: out = 8'hf8; 8'he2: out = 8'h98; 8'he3: out = 8'h11;
		    8'he4: out = 8'h69; 8'he5: out = 8'hd9; 8'he6: out = 8'h8e; 8'he7: out = 8'h94;
		    8'he8: out = 8'h9b; 8'he9: out = 8'h1e; 8'hea: out = 8'h87; 8'heb: out = 8'he9;
		    8'hec: out = 8'hce; 8'hed: out = 8'h55; 8'hee: out = 8'h28; 8'hef: out = 8'hdf;

		    8'hf0: out = 8'h8c; 8'hf1: out = 8'ha1; 8'hf2: out = 8'h89; 8'hf3: out = 8'h0d;
		    8'hf4: out = 8'hbf; 8'hf5: out = 8'he6; 8'hf6: out = 8'h42; 8'hf7: out = 8'h68;
		    8'hf8: out = 8'h41; 8'hf9: out = 8'h99; 8'hfa: out = 8'h2d; 8'hfb: out = 8'h0f;
		    8'hfc: out = 8'hb0; 8'hfd: out = 8'h54; 8'hfe: out = 8'hbb; 8'hff: out = 8'h16;
		
		    default: out = 8'h00;
        endcase
    end
end else begin : g_inv
    always @* begin
        case (in)
            8'h00: out = 8'h52; 8'h01: out = 8'h09; 8'h02: out = 8'h6a; 8'h03: out = 8'hd5;
            8'h04: out = 8'h30; 8'h05: out = 8'h36; 8'h06: out = 8'ha5; 8'h07: out = 8'h38;
            8'h08: out = 8'hbf; 8'h09: out = 8'h40; 8'h0a: out = 8'ha3; 8'h0b: out = 8'h9e;
            8'h0c: out = 8'h81; 8'h0d: out = 8'hf3; 8'h0e: out = 8'hd7; 8'h0f: out = 8'hfb;

            8'h10: out = 8'h7c; 8'h11: out = 8'he3; 8'h12: out = 8'h39; 8'h13: out = 8'h82;
            8'h14: out = 8'h9b; 8'h15: out = 8'h2f; 8'h16: out = 8'hff; 8'h17: out = 8'h87;
            8'h18: out = 8'h34; 8'h19: out = 8'h8e; 8'h1a: out = 8'h43; 8'h1b: out = 8'h44;
            8'h1c: out = 8'hc4; 8'h1d: out = 8'hde; 8'h1e: out = 8'he9; 8'h1f: out = 8'hcb;

            8'h20: out = 8'h54; 8'h21: out = 8'h7b; 8'h22: out = 8'h94; 8'h23: out = 8'h32;
            8'h24: out = 8'ha6; 8'h25: out = 8'hc2; 8'h26: out = 8'h23; 8'h27: out = 8'h3d;
            8'h28: out = 8'hee; 8'h29: out = 8'h4c; 8'h2a: out = 8'h95; 8'h2b: out = 8'h0b;
            8'h2c: out = 8'h42; 8'h2d: out = 8'hfa; 8'h2e: out = 8'hc3; 8'h2f: out = 8'h4e;

            8'h30: out = 8'h08; 8'h31: out = 8'h2e; 8'h32: out = 8'ha1; 8'h33: out = 8'h66;
            8'h34: out = 8'h28; 8'h35: out = 8'hd9; 8'h36: out = 8'h24; 8'h37: out = 8'hb2;
            8'h38: out = 8'h76; 8'h39: out = 8'h5b; 8'h3a: out = 8'ha2; 8'h3b: out = 8'h49;
            8'h3c: out = 8'h6d; 8'h3d: out = 8'h8b; 8'h3e: out = 8'hd1; 8'h3f: out = 8'h25;

            8'h40: out = 8'h72; 8'h41: out = 8'hf8; 8'h42: out = 8'hf6; 8'h43: out = 8'h64;
            8'h44: out = 8'h86; 8'h45: out = 8'h68; 8'h46: out = 8'h98; 8'h47: out = 8'h16;
            8'h48: out = 8'hd4; 8'h49: out = 8'ha4; 8'h4a: out = 8'h5c; 8'h4b: out = 8'hcc;
            8'h4c: out = 8'h5d; 8'h4d: out = 8'h65; 8'h4e: out = 8'hb6; 8'h4f: out = 8'h92;

            8'h50: out = 8'h6c; 8'h51: out = 8'h70; 8'h52: out = 8'h48; 8'h53: out = 8'h50;
            8'h54: out = 8'hfd; 8'h55: out = 8'hed; 8'h56: out = 8'hb9; 8'h57: out = 8'hda;
            8'h58: out = 8'h5e; 8'h59: out = 8'h15; 8'h5a: out = 8'h46; 8'h5b: out = 8'h57;
            8'h5c: out = 8'ha7; 8'h5d: out = 8'h8d; 8'h5e: out = 8'h9d; 8'h5f: out = 8'h84;

            8'h60: out = 8'h90; 8'h61: out = 8'hd8; 8'h62: out = 8'hab; 8'h63: out = 8'h00;
            8'h64: out = 8'h8c; 8'h65: out = 8'hbc; 8'h66: out = 8'hd3; 8'h67: out = 8'h0a;
            8'h68: out = 8'hf7; 8'h69: out = 8'he4; 8'h6a: out = 8'h58; 8'h6b: out = 8'h05;
            8'h6c: out = 8'hb8; 8'h6d: out = 8'hb3; 8'h6e: out = 8'h45; 8'h6f: out = 8'h06;

            8'h70: out = 8'hd0; 8'h71: out = 8'h2c; 8'h72: out = 8'h1e; 8'h73: out = 8'h8f;
            8'h74: out = 8'hca; 8'h75: out = 8'h3f; 8'h76: out = 8'h0f; 8'h77: out = 8'h02;
            8'h78: out = 8'hc1; 8'h79: out = 8'haf; 8'h7a: out = 8'hbd; 8'h7b: out = 8'h03;
            8'h7c: out = 8'h01; 8'h7d: out = 8'h13; 8'h7e: out = 8'h8a; 8'h7f: out = 8'h6b;

            8'h80: out = 8'h3a; 8'h81: out = 8'h91; 8'h82: out = 8'h11; 8'h83: out = 8'h41;
            8'h84: out = 8'h4f; 8'h85: out = 8'h67; 8'h86: out = 8'hdc; 8'h87: out = 8'hea;
            8'h88: out = 8'h97; 8'h89: out = 8'hf2; 8'h8a: out = 8'hcf; 8'h8b: out = 8'hce;
            8'h8c: out = 8'hf0; 8'h8d: out = 8'hb4; 8'h8e: out = 8'he6; 8'h8f: out = 8'h73;

            8'h90: out = 8'h96; 8'h91: out = 8'hac; 8'h92: out = 8'h74; 8'h93: out = 8'h22;
            8'h94: out = 8'he7; 8'h95: out = 8'had; 8'h96: out = 8'h35; 8'h97: out = 8'h85;
            8'h98: out = 8'he2; 8'h99: out = 8'hf9; 8'h9a: out = 8'h37; 8'h9b: out = 8'he8;
            8'h9c: out = 8'h1c; 8'h9d: out = 8'h75; 8'h9e: out = 8'hdf; 8'h9f: out = 8'h6e;

            8'ha0: out = 8'h47; 8'ha1: out = 8'hf1; 8'ha2: out = 8'h1a; 8'ha3: out = 8'h71;
            8'ha4: out = 8'h1d; 8'ha5: out = 8'h29; 8'ha6: out = 8'hc5; 8'ha7: out = 8'h89;
            8'ha8: out = 8'h6f; 8'ha9: out = 8'hb7; 8'haa: out = 8'h62; 8'hab: out = 8'h0e;
            8'hac: out = 8'haa; 8'had: out = 8'h18; 8'hae: out = 8'hbe; 8'haf: out = 8'h1b;

            8'hb0: out = 8'hfc; 8'hb1: out = 8'h56; 8'hb2: out = 8'h3e; 8'hb3: out = 8'h4b;
            8'hb4: out = 8'hc6; 8'hb5: out = 8'hd2; 8'hb6: out = 8'h79; 8'hb7: out = 8'h20;
            8'hb8: out = 8'h9a; 8'hb9: out = 8'hdb; 8'hba: out = 8'hc0; 8'hbb: out = 8'hfe;
            8'hbc: out = 8'h78; 8'hbd: out = 8'hcd; 8'hbe: out = 8'h5a; 8'hbf: out = 8'hf4;

            8'hc0: out = 8'h1f; 8'hc1: out = 8'hdd; 8'hc2: out = 8'ha8; 8'hc3: out = 8'h33;
            8'hc4: out = 8'h88; 8'hc5: out = 8'h07; 8'hc6: out = 8'hc7; 8'hc7: out = 8'h31;
            8'hc8: out = 8'hb1; 8'hc9: out = 8'h12; 8'hca: out = 8'h10; 8'hcb: out = 8'h59;
            8'hcc: out = 8'h27; 8'hcd: out = 8'h80; 8'hce: out = 8'hec; 8'hcf: out = 8'h5f;

            8'hd0: out = 8'h60; 8'hd1: out = 8'h51; 8'hd2: out = 8'h7f; 8'hd3: out = 8'ha9;
            8'hd4: out = 8'h19; 8'hd5: out = 8'hb5; 8'hd6: out = 8'h4a; 8'hd7: out = 8'h0d;
            8'hd8: out = 8'h2d; 8'hd9: out = 8'he5; 8'hda: out = 8'h7a; 8'hdb: out = 8'h9f;
            8'hdc: out = 8'h93; 8'hdd: out = 8'hc9; 8'hde: out = 8'h9c; 8'hdf: out = 8'hef;

            8'he0: out = 8'ha0; 8'he1: out = 8'he0; 8'he2: out = 8'h3b; 8'he3: out = 8'h4d;
            8'he4: out = 8'hae; 8'he5: out = 8'h2a; 8'he6: out = 8'hf5; 8'he7: out = 8'hb0;
            8'he8: out = 8'hc8; 8'he9: out = 8'heb; 8'hea: out = 8'hbb; 8'heb: out = 8'h3c;
            8'hec: out = 8'h83; 8'hed: out = 8'h53; 8'hee: out = 8'h99; 8'hef: out = 8'h61;

            8'hf0: out = 8'h17; 8'hf1: out = 8'h2b; 8'hf2: out = 8'h04; 8'hf3: out = 8'h7e;
            8'hf4: out = 8'hba; 8'hf5: out = 8'h77; 8'hf6: out = 8'hd6; 8'hf7: out = 8'h26;
            8'hf8: out = 8'he1; 8'hf9: out = 8'h69; 8'hfa: out = 8'h14; 8'hfb: out = 8'h63;
            8'hfc: out = 8'h55; 8'hfd: out = 8'h21; 8'hfe: out = 8'h0c; 8'hff: out = 8'h7d;

            default: out = 8'h00;
        endcase
    end
end
endgenerate
endmodule

module aes_subbytes_cfg #(
    parameter MODE_DEC = 1'b0
)(
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);
    wire [7:0] in_b [0:15];
    wire [7:0] out_b[0:15];
    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : g_bytes
            assign in_b[i] = data_in[127 - 8*i -: 8];
            
            aes_sbox_cfg #(.MODE_DEC(MODE_DEC)) u_sbx (
                .in (in_b[i]),
                .out(out_b[i])
            );
            assign data_out[127 - 8*i -: 8] = out_b[i];
        end
    endgenerate
endmodule

module aes_shiftrows_cfg #(
    parameter MODE_DEC = 1'b0
)(
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);

    // Split input into 16 bytes 
    wire [7:0] state [0:15];
    wire [7:0] perm  [0:15];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_in_split
            assign state[i] = data_in[127 - i*8 -: 8];
        end
    endgenerate
    // Permutation per AES row shifts
    generate
        if (MODE_DEC == 1'b0) begin : g_fwd  
            assign perm[ 0] = state[ 0];
            assign perm[ 1] = state[ 5];
            assign perm[ 2] = state[10];
            assign perm[ 3] = state[15];

            assign perm[ 4] = state[ 4];
            assign perm[ 5] = state[ 9];
            assign perm[ 6] = state[14];
            assign perm[ 7] = state[ 3];

            assign perm[ 8] = state[ 8];
            assign perm[ 9] = state[13];
            assign perm[10] = state[ 2];
            assign perm[11] = state[ 7];

            assign perm[12] = state[12];
            assign perm[13] = state[ 1];
            assign perm[14] = state[ 6];
            assign perm[15] = state[11];
        end else begin : g_inv       
            assign perm[ 0] = state[ 0];
            assign perm[ 1] = state[13];
            assign perm[ 2] = state[10];
            assign perm[ 3] = state[ 7];

            assign perm[ 4] = state[ 4];
            assign perm[ 5] = state[ 1];
            assign perm[ 6] = state[14];
            assign perm[ 7] = state[11];

            assign perm[ 8] = state[ 8];
            assign perm[ 9] = state[ 5];
            assign perm[10] = state[ 2];
            assign perm[11] = state[15];

            assign perm[12] = state[12];
            assign perm[13] = state[ 9];
            assign perm[14] = state[ 6];
            assign perm[15] = state[ 3];
        end
    endgenerate

    // Pack back to 128-bit output
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_out_pack
            assign data_out[127 - i*8 -: 8] = perm[i];
        end
    endgenerate
endmodule

module aes_mixcolumns_cfg #(
    parameter MODE_DEC = 1'b0
)(
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);

    // ---------- GF(2^8) helpers (AES polynomial x^8+x^4+x^3+x+1 -> 0x1b) ----------
    function [7:0] xtime2; // multiply by 0x02
        input [7:0] b;
        begin
            xtime2 = b[7] ? ((b << 1) ^ 8'h1b) : (b << 1);
        end
    endfunction

    function [7:0] xtime3; // multiply by 0x03
        input [7:0] b;
        begin
            xtime3 = xtime2(b) ^ b;
        end
    endfunction

    // extra constants for inverse MixColumns
    function [7:0] xtime4;  input [7:0] b; begin xtime4  = xtime2(xtime2(b)); end endfunction
    function [7:0] xtime8;  input [7:0] b; begin xtime8  = xtime2(xtime4(b)); end endfunction
    function [7:0] xtime9;  input [7:0] b; begin xtime9  = xtime8(b) ^ b;              end endfunction // 8+1
    function [7:0] xtimeB;  input [7:0] b; begin xtimeB  = xtime8(b) ^ xtime2(b) ^ b;  end endfunction // 8+2+1
    function [7:0] xtimeD;  input [7:0] b; begin xtimeD  = xtime8(b) ^ xtime4(b) ^ b;  end endfunction // 8+4+1
    function [7:0] xtimeE;  input [7:0] b; begin xtimeE  = xtime8(b) ^ xtime4(b) ^ xtime2(b); end endfunction // 8+4+2

    // ---------- splitting to bytes (same column-major order you used) ----------
    wire [7:0] s [0:15];
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_in
            assign s[i] = data_in[127 - i*8 -: 8];
        end
    endgenerate

    wire [7:0] m [0:15];

    // ---------- per-column transform ----------
    genvar c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : g_col
            wire [7:0] s0 = s[4*c + 0];
            wire [7:0] s1 = s[4*c + 1];
            wire [7:0] s2 = s[4*c + 2];
            wire [7:0] s3 = s[4*c + 3];

            if (MODE_DEC == 1'b0) begin : g_fwd // encryption
                assign m[4*c + 0] = xtime2(s0) ^ xtime3(s1) ^        s2  ^        s3;
                assign m[4*c + 1] =        s0  ^ xtime2(s1) ^ xtime3(s2) ^        s3;
                assign m[4*c + 2] =        s0  ^        s1  ^ xtime2(s2) ^ xtime3(s3);
                assign m[4*c + 3] = xtime3(s0) ^        s1  ^        s2  ^ xtime2(s3);
            end else begin : g_inv // decryption
                assign m[4*c + 0] = xtimeE(s0) ^ xtimeB(s1) ^ xtimeD(s2) ^ xtime9(s3);
                assign m[4*c + 1] = xtime9(s0) ^ xtimeE(s1) ^ xtimeB(s2) ^ xtimeD(s3);
                assign m[4*c + 2] = xtimeD(s0) ^ xtime9(s1) ^ xtimeE(s2) ^ xtimeB(s3);
                assign m[4*c + 3] = xtimeB(s0) ^ xtimeD(s1) ^ xtime9(s2) ^ xtimeE(s3);
            end
        end
    endgenerate

    // ---------- packing back to 128-bit ----------
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_out
            assign data_out[127 - i*8 -: 8] = m[i];
        end
    endgenerate
endmodule

module aes_addroundkey(
    input  wire [127:0] data_in,
    input  wire [127:0] round_key,
    output wire [127:0] data_out
);
    assign data_out = data_in ^ round_key;
endmodule

module aes_key_expand (
    input  wire [127:0] cipher_key,
    output wire [1407:0] expanded_keys  // 11 round keys × 128 bits
);
  // ----- Forward AES S-box as a function -----
  function [7:0] sbox8;
    input [7:0] x;
    begin
        case (x)
            8'h00: sbox8 = 8'h63; 8'h01: sbox8 = 8'h7c; 8'h02: sbox8 = 8'h77; 8'h03: sbox8 = 8'h7b;
            8'h04: sbox8 = 8'hf2; 8'h05: sbox8 = 8'h6b; 8'h06: sbox8 = 8'h6f; 8'h07: sbox8 = 8'hc5;
            8'h08: sbox8 = 8'h30; 8'h09: sbox8 = 8'h01; 8'h0a: sbox8 = 8'h67; 8'h0b: sbox8 = 8'h2b;
            8'h0c: sbox8 = 8'hfe; 8'h0d: sbox8 = 8'hd7; 8'h0e: sbox8 = 8'hab; 8'h0f: sbox8 = 8'h76;
                   
            8'h10: sbox8 = 8'hca; 8'h11: sbox8 = 8'h82; 8'h12: sbox8 = 8'hc9; 8'h13: sbox8 = 8'h7d;
            8'h14: sbox8 = 8'hfa; 8'h15: sbox8 = 8'h59; 8'h16: sbox8 = 8'h47; 8'h17: sbox8 = 8'hf0;
            8'h18: sbox8 = 8'had; 8'h19: sbox8 = 8'hd4; 8'h1a: sbox8 = 8'ha2; 8'h1b: sbox8 = 8'haf;
            8'h1c: sbox8 = 8'h9c; 8'h1d: sbox8 = 8'ha4; 8'h1e: sbox8 = 8'h72; 8'h1f: sbox8 = 8'hc0;
                   
            8'h20: sbox8 = 8'hb7; 8'h21: sbox8 = 8'hfd; 8'h22: sbox8 = 8'h93; 8'h23: sbox8 = 8'h26;
            8'h24: sbox8 = 8'h36; 8'h25: sbox8 = 8'h3f; 8'h26: sbox8 = 8'hf7; 8'h27: sbox8 = 8'hcc;
            8'h28: sbox8 = 8'h34; 8'h29: sbox8 = 8'ha5; 8'h2a: sbox8 = 8'he5; 8'h2b: sbox8 = 8'hf1;
            8'h2c: sbox8 = 8'h71; 8'h2d: sbox8 = 8'hd8; 8'h2e: sbox8 = 8'h31; 8'h2f: sbox8 = 8'h15;

            8'h30: sbox8 = 8'h04; 8'h31: sbox8 = 8'hc7; 8'h32: sbox8 = 8'h23; 8'h33: sbox8 = 8'hc3;
            8'h34: sbox8 = 8'h18; 8'h35: sbox8 = 8'h96; 8'h36: sbox8 = 8'h05; 8'h37: sbox8 = 8'h9a;
            8'h38: sbox8 = 8'h07; 8'h39: sbox8 = 8'h12; 8'h3a: sbox8 = 8'h80; 8'h3b: sbox8 = 8'he2;
            8'h3c: sbox8 = 8'heb; 8'h3d: sbox8 = 8'h27; 8'h3e: sbox8 = 8'hb2; 8'h3f: sbox8 = 8'h75;

            8'h40: sbox8 = 8'h09; 8'h41: sbox8 = 8'h83; 8'h42: sbox8 = 8'h2c; 8'h43: sbox8 = 8'h1a;
            8'h44: sbox8 = 8'h1b; 8'h45: sbox8 = 8'h6e; 8'h46: sbox8 = 8'h5a; 8'h47: sbox8 = 8'ha0;
            8'h48: sbox8 = 8'h52; 8'h49: sbox8 = 8'h3b; 8'h4a: sbox8 = 8'hd6; 8'h4b: sbox8 = 8'hb3;
            8'h4c: sbox8 = 8'h29; 8'h4d: sbox8 = 8'he3; 8'h4e: sbox8 = 8'h2f; 8'h4f: sbox8 = 8'h84;

            8'h50: sbox8 = 8'h53; 8'h51: sbox8 = 8'hd1; 8'h52: sbox8 = 8'h00; 8'h53: sbox8 = 8'hed;
            8'h54: sbox8 = 8'h20; 8'h55: sbox8 = 8'hfc; 8'h56: sbox8 = 8'hb1; 8'h57: sbox8 = 8'h5b;
            8'h58: sbox8 = 8'h6a; 8'h59: sbox8 = 8'hcb; 8'h5a: sbox8 = 8'hbe; 8'h5b: sbox8 = 8'h39;
            8'h5c: sbox8 = 8'h4a; 8'h5d: sbox8 = 8'h4c; 8'h5e: sbox8 = 8'h58; 8'h5f: sbox8 = 8'hcf;

            8'h60: sbox8 = 8'hd0; 8'h61: sbox8 = 8'hef; 8'h62: sbox8 = 8'haa; 8'h63: sbox8 = 8'hfb;
            8'h64: sbox8 = 8'h43; 8'h65: sbox8 = 8'h4d; 8'h66: sbox8 = 8'h33; 8'h67: sbox8 = 8'h85;
            8'h68: sbox8 = 8'h45; 8'h69: sbox8 = 8'hf9; 8'h6a: sbox8 = 8'h02; 8'h6b: sbox8 = 8'h7f;
            8'h6c: sbox8 = 8'h50; 8'h6d: sbox8 = 8'h3c; 8'h6e: sbox8 = 8'h9f; 8'h6f: sbox8 = 8'ha8;

            8'h70: sbox8 = 8'h51; 8'h71: sbox8 = 8'ha3; 8'h72: sbox8 = 8'h40; 8'h73: sbox8 = 8'h8f;
            8'h74: sbox8 = 8'h92; 8'h75: sbox8 = 8'h9d; 8'h76: sbox8 = 8'h38; 8'h77: sbox8 = 8'hf5;
            8'h78: sbox8 = 8'hbc; 8'h79: sbox8 = 8'hb6; 8'h7a: sbox8 = 8'hda; 8'h7b: sbox8 = 8'h21;
            8'h7c: sbox8 = 8'h10; 8'h7d: sbox8 = 8'hff; 8'h7e: sbox8 = 8'hf3; 8'h7f: sbox8 = 8'hd2;

            8'h80: sbox8 = 8'hcd; 8'h81: sbox8 = 8'h0c; 8'h82: sbox8 = 8'h13; 8'h83: sbox8 = 8'hec;
            8'h84: sbox8 = 8'h5f; 8'h85: sbox8 = 8'h97; 8'h86: sbox8 = 8'h44; 8'h87: sbox8 = 8'h17;
            8'h88: sbox8 = 8'hc4; 8'h89: sbox8 = 8'ha7; 8'h8a: sbox8 = 8'h7e; 8'h8b: sbox8 = 8'h3d;
            8'h8c: sbox8 = 8'h64; 8'h8d: sbox8 = 8'h5d; 8'h8e: sbox8 = 8'h19; 8'h8f: sbox8 = 8'h73;
		
		    8'h90: sbox8 = 8'h60; 8'h91: sbox8 = 8'h81; 8'h92: sbox8 = 8'h4f; 8'h93: sbox8 = 8'hdc;
		    8'h94: sbox8 = 8'h22; 8'h95: sbox8 = 8'h2a; 8'h96: sbox8 = 8'h90; 8'h97: sbox8 = 8'h88;
		    8'h98: sbox8 = 8'h46; 8'h99: sbox8 = 8'hee; 8'h9a: sbox8 = 8'hb8; 8'h9b: sbox8 = 8'h14;
		    8'h9c: sbox8 = 8'hde; 8'h9d: sbox8 = 8'h5e; 8'h9e: sbox8 = 8'h0b; 8'h9f: sbox8 = 8'hdb;

            8'ha0: sbox8 = 8'he0; 8'ha1: sbox8 = 8'h32; 8'ha2: sbox8 = 8'h3a; 8'ha3: sbox8 = 8'h0a;
		    8'ha4: sbox8 = 8'h49; 8'ha5: sbox8 = 8'h06; 8'ha6: sbox8 = 8'h24; 8'ha7: sbox8 = 8'h5c;
		    8'ha8: sbox8 = 8'hc2; 8'ha9: sbox8 = 8'hd3; 8'haa: sbox8 = 8'hac; 8'hab: sbox8 = 8'h62;
		    8'hac: sbox8 = 8'h91; 8'had: sbox8 = 8'h95; 8'hae: sbox8 = 8'he4; 8'haf: sbox8 = 8'h79;

            8'hb0: sbox8 = 8'he7; 8'hb1: sbox8 = 8'hc8; 8'hb2: sbox8 = 8'h37; 8'hb3: sbox8 = 8'h6d;
		    8'hb4: sbox8 = 8'h8d; 8'hb5: sbox8 = 8'hd5; 8'hb6: sbox8 = 8'h4e; 8'hb7: sbox8 = 8'ha9;
		    8'hb8: sbox8 = 8'h6c; 8'hb9: sbox8 = 8'h56; 8'hba: sbox8 = 8'hf4; 8'hbb: sbox8 = 8'hea;
		    8'hbc: sbox8 = 8'h65; 8'hbd: sbox8 = 8'h7a; 8'hbe: sbox8 = 8'hae; 8'hbf: sbox8 = 8'h08;

            8'hc0: sbox8 = 8'hba; 8'hc1: sbox8 = 8'h78; 8'hc2: sbox8 = 8'h25; 8'hc3: sbox8 = 8'h2e;
		    8'hc4: sbox8 = 8'h1c; 8'hc5: sbox8 = 8'ha6; 8'hc6: sbox8 = 8'hb4; 8'hc7: sbox8 = 8'hc6;
		    8'hc8: sbox8 = 8'he8; 8'hc9: sbox8 = 8'hdd; 8'hca: sbox8 = 8'h74; 8'hcb: sbox8 = 8'h1f;
		    8'hcc: sbox8 = 8'h4b; 8'hcd: sbox8 = 8'hbd; 8'hce: sbox8 = 8'h8b; 8'hcf: sbox8 = 8'h8a;

            8'hd0: sbox8 = 8'h70; 8'hd1: sbox8 = 8'h3e; 8'hd2: sbox8 = 8'hb5; 8'hd3: sbox8 = 8'h66;
		    8'hd4: sbox8 = 8'h48; 8'hd5: sbox8 = 8'h03; 8'hd6: sbox8 = 8'hf6; 8'hd7: sbox8 = 8'h0e;
		    8'hd8: sbox8 = 8'h61; 8'hd9: sbox8 = 8'h35; 8'hda: sbox8 = 8'h57; 8'hdb: sbox8 = 8'hb9;
		    8'hdc: sbox8 = 8'h86; 8'hdd: sbox8 = 8'hc1; 8'hde: sbox8 = 8'h1d; 8'hdf: sbox8 = 8'h9e;

            8'he0: sbox8 = 8'he1; 8'he1: sbox8 = 8'hf8; 8'he2: sbox8 = 8'h98; 8'he3: sbox8 = 8'h11;
		    8'he4: sbox8 = 8'h69; 8'he5: sbox8 = 8'hd9; 8'he6: sbox8 = 8'h8e; 8'he7: sbox8 = 8'h94;
		    8'he8: sbox8 = 8'h9b; 8'he9: sbox8 = 8'h1e; 8'hea: sbox8 = 8'h87; 8'heb: sbox8 = 8'he9;
		    8'hec: sbox8 = 8'hce; 8'hed: sbox8 = 8'h55; 8'hee: sbox8 = 8'h28; 8'hef: sbox8 = 8'hdf;

		    8'hf0: sbox8 = 8'h8c; 8'hf1: sbox8 = 8'ha1; 8'hf2: sbox8 = 8'h89; 8'hf3: sbox8 = 8'h0d;
		    8'hf4: sbox8 = 8'hbf; 8'hf5: sbox8 = 8'he6; 8'hf6: sbox8 = 8'h42; 8'hf7: sbox8 = 8'h68;
		    8'hf8: sbox8 = 8'h41; 8'hf9: sbox8 = 8'h99; 8'hfa: sbox8 = 8'h2d; 8'hfb: sbox8 = 8'h0f;
		    8'hfc: sbox8 = 8'hb0; 8'hfd: sbox8 = 8'h54; 8'hfe: sbox8 = 8'hbb; 8'hff: sbox8 = 8'h16;
		
		    default: sbox8 = 8'h00;
      endcase
    end
  endfunction

  // SubWord and RotWord helpers
  function [31:0] subword;
    input [31:0] w;
    begin
      subword = { sbox8(w[31:24]), sbox8(w[23:16]), sbox8(w[15:8]), sbox8(w[7:0]) };
    end
  endfunction

  function [31:0] rotword;
    input [31:0] w;
    begin
      rotword = { w[23:0], w[31:24] };
    end
  endfunction

  // Rcon
  function [31:0] rcon;
    input [3:0] i;
    begin
      case (i)
        4'h1: rcon = 32'h01000000;
        4'h2: rcon = 32'h02000000;
        4'h3: rcon = 32'h04000000;
        4'h4: rcon = 32'h08000000;
        4'h5: rcon = 32'h10000000;
        4'h6: rcon = 32'h20000000;
        4'h7: rcon = 32'h40000000;
        4'h8: rcon = 32'h80000000;
        4'h9: rcon = 32'h1b000000;
        4'ha: rcon = 32'h36000000;
        default: rcon = 32'h00000000;
      endcase
    end
  endfunction

  // 44 words (w0..w43)
  reg [31:0] w [0:43];
  integer i;
  reg [31:0] t;
  always @* begin
    // Load initial key words
    w[0] = cipher_key[127:96];
    w[1] = cipher_key[95:64];
    w[2] = cipher_key[63:32];
    w[3] = cipher_key[31:0];

    
    // Expand
    for (i = 4; i < 44; i = i + 1) begin
      t = w[i-1];
      if (i % 4 == 0) begin
        t = subword(rotword(t)) ^ rcon(i >> 2);
      end
      w[i] = w[i-4] ^ t;
    end
  end

  // Flatten to 1408 bits (same ordering as your version)
  genvar j;
  generate
    for (j = 0; j < 44; j = j + 1) begin : flatten_keys
      assign expanded_keys[1407 - 32*j -: 32] = w[j];
    end
  endgenerate
endmodule

module aes_round_cfg #(
    parameter MODE_DEC = 1'b0
)(
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    input  wire         final_round,
    output wire [127:0] state_out
);

generate
if (MODE_DEC == 1'b0) begin : g_fwd
    // Forward round: SubBytes → ShiftRows → (MixColumns*) → AddRoundKey
    wire [127:0] sb, sr, mix;

    // configurable SubBytes (forward)
    aes_subbytes_cfg #(.MODE_DEC(1'b0)) u_subbytes (.data_in(state_in), .data_out(sb));
    // configurable ShiftRows (forward)
    aes_shiftrows_cfg #(.MODE_DEC(1'b0)) u_shiftrows (.data_in(sb), .data_out(sr));
    // MixColumns only if not final
    aes_mixcolumns_cfg #(.MODE_DEC(1'b0)) u_mix (.data_in(sr), .data_out(mix));

    wire [127:0] ark_in = final_round ? sr : mix;

    aes_addroundkey u_addroundkey (
        .data_in(ark_in),
        .round_key(round_key),
        .data_out(state_out)
    );
end else begin : g_inv
    // Inverse round: InvShiftRows → InvSubBytes → AddRoundKey → (InvMixColumns*)
    wire [127:0] ish, isb, ark, imix;

    // configurable InvShiftRows
    aes_shiftrows_cfg #(.MODE_DEC(1'b1)) u_invshift (.data_in(state_in), .data_out(ish));
    // configurable InvSubBytes
    aes_subbytes_cfg  #(.MODE_DEC(1'b1)) u_invsub   (.data_in(ish),       .data_out(isb));
    // AddRoundKey always
    aes_addroundkey u_addkey (.data_in(isb), .round_key(round_key), .data_out(ark));
    // InvMixColumns only if not final
    aes_mixcolumns_cfg #(.MODE_DEC(1'b1)) u_invmix (.data_in(ark), .data_out(imix));

    assign state_out = final_round ? ark : imix;
    
    // Put this inside the decrypt branch (g_inv) of aes_round_cfg
/*always @* begin
  if (final_round) begin
    $display("[DEC-FINAL] ish=%h", ish);
    $display("[DEC-FINAL] isb=%h", isb);
    $display("[DEC-FINAL] rk0(used)=%h", round_key);
    $display("[DEC-FINAL] isb ^ rk0 = %h", isb ^ round_key);
  end
end*/

end
endgenerate
endmodule

module aes_fsm #(
  parameter MODE_DEC = 1'b0  // 0 = encrypt, 1 = decrypt
)(
  input  wire         clk,
  input  wire         reset,
  input  wire         start,
  input  wire [127:0] in_block,    // plaintext when encrypt, ciphertext when decrypt
  input  wire [127:0] cipher_key,
  output reg  [127:0] out_block,   // ciphertext when encrypt, plaintext when decrypt
  output reg          done
);
  localparam S_IDLE=3'd0, S_KEY_EXP=3'd1, S_KEY_EXP_WAIT=3'd2,
             S_INIT_ADDKEY=3'd3, S_ROUND=3'd4, S_FINAL=3'd5, S_DONE=3'd6;

  reg [2:0]  state, next_state;
  reg [3:0]  round;
  reg [127:0] state_data;
  reg [127:0] round_keys [0:10];
  wire [1407:0] expanded_keys;

  aes_key_expand key_exp_inst (.cipher_key(cipher_key), .expanded_keys(expanded_keys));

  integer i;
  always @(posedge clk) begin
    if (state == S_KEY_EXP_WAIT) begin
      for (i = 0; i < 11; i = i + 1) begin
        if (MODE_DEC)
          round_keys[i] <= expanded_keys[1407 - (10-i)*128 -: 128]; // reverse for decrypt
        else
          round_keys[i] <= expanded_keys[1407 - i*128 -: 128];      // forward for encrypt
      end
    end
  end

  wire [127:0] current_round_key = round_keys[round];

  wire [127:0] round_out;
  // one round only, selected by parameter
  aes_round_cfg #(.MODE_DEC(MODE_DEC)) u_round (
    .state_in    (state_data),
    .round_key   (current_round_key),
    .final_round (round == 4'd10),
    .state_out   (round_out)
  );

  // initial AddRoundKey
  always @(posedge clk) begin
    if (state == S_INIT_ADDKEY)
      state_data <= in_block ^ round_keys[0];
  end

  // seq
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= S_IDLE; round <= 4'd0; state_data <= 128'd0; out_block <= 128'd0; done <= 1'b0;
    end else begin
      state <= next_state;
      if (state == S_ROUND || state == S_FINAL) state_data <= round_out;
      if (state == S_DONE) begin out_block <= state_data; done <= 1'b1; end
      else done <= 1'b0;

      if (state == S_INIT_ADDKEY) round <= 4'd1;
      else if (state == S_ROUND) round <= round + 4'd1;
      else if (state == S_FINAL || state == S_DONE) round <= 4'd0;
    end
  end

  // next-state
  always @* begin
    next_state = state;
    case (state)
      S_IDLE:         if (start) next_state = S_KEY_EXP;
      S_KEY_EXP:      next_state = S_KEY_EXP_WAIT;
      S_KEY_EXP_WAIT: next_state = S_INIT_ADDKEY;
      S_INIT_ADDKEY:  next_state = S_ROUND;
      S_ROUND:        if (round == 4'd9) next_state = S_FINAL;
      S_FINAL:        next_state = S_DONE;
      S_DONE:         next_state = S_IDLE;
      default:        next_state = S_IDLE;
    endcase
  end
  
  // ================= DEBUG DISPLAY =================
  // Expanded Keys
  always @(posedge clk) begin
    if (state == S_KEY_EXP_WAIT) begin
      $display("[%0t] Expanded Keys (%s):", $time, MODE_DEC ? "DECRYPT" : "ENCRYPT");
      //$display("Raw expanded = %h", expanded_keys);
      /*for (i = 0; i < 11; i = i + 1) begin
        $display("Round %0d Key = %h", i, round_keys[i]);
      end*/
    end
  end

  // Initial AddRoundKey
  always @(posedge clk) begin
    if (state == S_INIT_ADDKEY) begin
      $display("[%0t] Initial AddRoundKey:", $time);
      $display(" Input Block   = %h", in_block);
      //$display(" RoundKey[0]   = %h", round_keys[0]);
      $display(" State(after)  = %h", in_block ^ round_keys[0]);
    end
  end

  // Per-Round Output
  always @(posedge clk) begin
    if (state == S_ROUND || state == S_FINAL) begin
      $display("[%0t] Round %0d Output = %h", $time, round, round_out);
    end
  end

  // Final Output
  reg [127:0] final_out_lat;
  always @(posedge clk) begin
    if (state == S_FINAL) final_out_lat <= round_out;
    if (state == S_DONE) begin
      $display("[%0t] Final Output Block = %h", $time, final_out_lat);
    end
  end
  // ==================================================

endmodule
