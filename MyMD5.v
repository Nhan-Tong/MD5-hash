module MyMD5(clk, en1,en2,en3,en4, reset, data_i, data_o);
	//------------------------------------------
	// inputs, output
	//------------------------------------------
	
	input clk;
	input en1,en2,en3,en4;
	input reset;
	input [127:0] data_i;
	
	
	output [127:0] data_o;
	
	//------------------------------------------
	// Initial Parameters
	//------------------------------------------
	parameter A0 = 32'h67452301; 
	parameter B0 = 32'hefcdab89;
	parameter C0 = 32'h98badcfe;
	parameter D0 = 32'h10325476;

	
	//------------------------------------------
	// Registers
	//------------------------------------------	
	reg [127:0] data_o, data_o_new;
	
	reg [31:0] A, A_new;
	reg [31:0] B, B_new;
	reg [31:0] C, C_new;
	reg [31:0] D, D_new;
	
	reg ready_out, ready_out_new;
	reg ready_in, ready_in_new;
	reg storedatadone;
	
	reg [5:0] stage, stage_new;
	reg [5:0] round, round_new;
	reg [43:0] k;
	
	reg [31:0] M [0:15];
	reg [511:0] storage, storage_new;
	//------------------------------------------
	// STORE DATA
	//------------------------------------------
always @(clk,en1,en2,en3,en4)
begin
	if(en1) begin
		storage_new[511:384] = data_i;
		end
	if(en1) begin
		storage_new[383:256] = data_i;
		end
	if(en1) begin
		storage_new[255:128] = data_i;
		end
	if(en1) begin
		storage_new[127:0]   = data_i;
		storedatadone = 1;
		end
end
	//------------------------------------------
	// UPDATE SIGNAL
	//------------------------------------------
always @(posedge clk)
begin
if(reset) begin
	A = 32'h67452301; 
	B = 32'hefcdab89;
	C = 32'h98badcfe;
	D = 32'h10325476;
	storedatadone = 0;
	data_o = 0;
	ready_out = 0;
	stage = 0;
	round = 0;
	storage = 0;
	end
	
	else begin // UPDATE DATA
	storage = storage_new;
	stage = stage_new;
	round = round_new;	
	data_o = data_o_new;
	ready_out = ready_out_new;
	A = A_new;
	B = B_new;
	C = C_new;
	D = D_new;
	end
end
//

	//------------------------------------------
	// STAGE AND ROUND CONTROL
	//------------------------------------------	

	reg [127:0] temp_out;
	
always @(A,B,C,D,round,stage,ready_out)
begin

		ready_out_new = 0;
		if(ready_out) begin
			temp_out[127:96] = A + A0;
			temp_out[95:64]  = B + B0;
			temp_out[63:32]  = C + C0;
			temp_out[31:0]   = D + D0;
			data_o_new = temp_out;
			
		end
		else begin
			
			round_new = round;
			stage_new = stage;
			
			case(round)
				0: begin
				stage_new = 0;
				round_new = round + 1;
				end
				
				15,31,47: begin
				stage_new = stage + 1;
				round_new = round + 1;
				end
				
				63: begin
				stage_new = 0;
				round_new = 0;
				ready_out_new = 1;
				end
				default: round_new = round + 1;
			endcase
	end	
end	

	//------------------------------------------
	// ROM
	//------------------------------------------	
	always @(round)
	begin
		
		case(round)                 // _____Ki: abs(sin(i+ 1))×232_____.___Si__.block.
				0:  k = 44'hD76AA478070; // 11010111011010101010010001111000.00000111.0000 =.07.0
				1:  k = 44'hE8C7B7560C1; // 11101000110001111011011101010110.00001100.0001 =.12.1
				2:  k = 44'h242070DB112; // 00100100001000000111000011011011.00010001.0010 =.17.3
				3:  k = 44'hC1BDCEEE163; // 11000001101111011100111011101110.00010110.0011 =.22.4
				4:  k = 44'hF57C0FAF074; // 11110101011111000000111110101111.00000111.0100 =.07.5
				5:  k = 44'h4787C62A0C5; // 01000111100001111100011000101010.00001100.0101
				6:  k = 44'hA8304613116; //
				7:  k = 44'hFD469501167; //
				8:  k = 44'h698098D8078; //		
				9:  k = 44'h8B44F7AF0C9; //
				10: k = 44'hFFFF5BB111A;// 
				11: k = 44'h895CD7BE16B;// 
				12: k = 44'h6B90112207C;// 
				13: k = 44'hFD9871930CD;// 
				14: k = 44'hA679438E11E;// 
				15: k = 44'h49B4082116F;// 		
			
				16: k = 44'hf61e2562051;// 11110110000111100010010101100010.00000101.0001 = 5.1
				17: k = 44'hc040b340096;// 11000000010000001011001101000000.00001001.0110 = 9.6
				18: k = 44'h265e5a510EB;// 00100110010111100101101001010001.00001110.1011 = 14.11
				19: k = 44'he9b6c7aa140;// 
				20: k = 44'hd62f105d055;// 
				21: k = 44'h0244145309A;// 
				22: k = 44'hd8a1e6810EF;// 		
				23: k = 44'he7d3fbc8144;// 
				24: k = 44'h21e1cde6059;// 
				25: k = 44'hc33707d609E;// 
				26: k = 44'hf4d50d870E3;// 
				27: k = 44'h455a14ed148;// 
				28: k = 44'ha9e3e90505D;// 
				29: k = 44'hfcefa3f8092;// 		
				30: k = 44'h676f02d90E7;// 
				31: k = 44'h8d2a4c8a14C;// 
				
				32: k = 44'hfffa3942045;// 
				33: k = 44'h8771f6810B8;// 
				34: k = 44'h6d9d612210B;// 
				35: k = 44'hfde5380c17E;// 
				36: k = 44'ha4beea44041;// 		
				37: k = 44'h4bdecfa90B4;// 
				38: k = 44'hf6bb4b60107;// 
				39: k = 44'hbebfbc7017A;// 
				40: k = 44'h289b7ec604D;// 
				41: k = 44'heaa127fa0B0;// 
				42: k = 44'hd4ef3085103;// 
				43: k = 44'h04881d05176;// 		
				44: k = 44'hd9d4d039049;// 
				45: k = 44'he6db99e50BC;// 
				46: k = 44'h1fa27cf810F;// 
				47: k = 44'hc4ac5665172;// 
				
				48: k = 44'hf4292244060;// 
				49: k = 44'h432aff970A7;// 
				50: k = 44'hab9423a70FE;// 		
				51: k = 44'hfc93a039155;// 
				52: k = 44'h655b59c306C;// 
				53: k = 44'h8f0ccc920A3;// 
				54: k = 44'hffeff47d0FA;// 
				55: k = 44'h85845dd1151;// 
				56: k = 44'h6fa87e4f068;// 
				57: k = 44'hfe2ce6e00AF;// 		
				58: k = 44'ha30143140F6;// 
				59: k = 44'h4e0811a115D;// 
				60: k = 44'hf7537e82064;// 
				61: k = 44'hbd3af2350AB;// 
				62: k = 44'h2ad7d2bb0F2;// 
				63: k = 44'heb86d391159;//		 
		 endcase
	end	
	//------------------------------------------
	// MAIN FUNCTION
	//------------------------------------------	
		// generate var
	reg [31:0] func_tmp, func_out;
	reg [31:0] ki,f;
	reg [3:0]  g;
	reg [3:0]  Mi;
	reg [7:0]  Si;
	
always @(A,B,C,D,round,M[0],M[2],M[3],M[4],M[5],M[6],M[7],M[8],M[9],M[10],
M[11],M[12],M[13],M[14],M[15],storage)

	begin
		
		M[0]<=storage[511:480]; 
		M[1]<=storage[479:448]; 
		M[2]<=storage[447:416]; 
		M[3]<=storage[415:384]; 
		M[4]<=storage[383:352]; 
		M[5]<=storage[351:320]; 
		M[6]<=storage[319:288]; 
		M[7]<=storage[287:256]; 
		M[8]<=storage[255:224]; 
		M[9]<=storage[223:192]; 
		M[10]<=storage[191:160]; 
		M[11]<=storage[159:128]; 
		M[12]<=storage[127:96]; 
		M[13]<=storage[95:64]; 
		M[14]<=storage[63:32]; 
		M[15]<=storage[31:0];

	// Calculate var
		Mi = k[3:0];
		Si = k[11:4];
		f = F(B,C,D,stage);
		ki = k[43:12];
		
		func_tmp = A + f + ki + M[Mi] ;
		func_out = B + shift(func_tmp,Si); 
		
		A_new = D;
		B_new = func_out;
		C_new = B;
		D_new = C;
		
	end

	//------------------------------------------
	// F-Functions
	//------------------------------------------	
	
	function [31:0] F(input [31:0]b, input [31:0]c,input [31:0]d, input [2:0] stage);
		begin
			case(stage)
			0: F = (B & C)|((~B)&D);
			1: F = (D & B) | ((~D) & C);
			2: F = B ^ C ^ D;
			3: F = C ^ (B | (~D));
			endcase
		end
	endfunction


	//------------------------------------------
	// BIT SHIFT FUNCTION WITH Si
	//------------------------------------------
	
	function [31:0] shift (input [31:0]data_in, input [7:0]Si);
		begin
			shift = (data_in << Si)|(data_in>>(Si));
		end
	endfunction	
	
	//------------------------------------------
	// 
	//------------------------------------------
endmodule 

`timescale 10ns/1ns

module testbench;


reg clk;
reg reset;
reg en1,en2,en3,en4;

reg [255:0] data_i;
wire [127:0] data_o;

MyMD5 m1(clk,en1,en2,en3,en4, reset, data_i, data_o);
	initial
	begin
	clk = 1'b 0;
	forever #5 clk = ~clk;
	end
   initial
   begin
     reset = 'b1;
	  @(clk);
	  reset = 'b0;
	  @(clk);
	  en1   = 'b1;
	  data_i= 128'h0;
	  @(clk);
	  en1   = 'b0;
	  en2   = 'b1;
	  data_i= 128'h0;
	  @(clk);
	  en2   = 'b0;
	  en3   = 'b1;
	  data_i= 128'h0;
	  @(clk);
	  en3   = 'b0;
	  en4   = 'b1;
	  data_i= 128'h1234567898765432123456789;
   end

endmodule