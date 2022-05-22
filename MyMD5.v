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
	parameter A0 = 32'h01234567; 
	parameter B0 = 32'h89abcdef;
	parameter C0 = 32'hfedcba98;
	parameter D0 = 32'h76543210;

	
	//------------------------------------------
	// Registers
	//------------------------------------------	
	reg [127:0] data_o, data_o_new;
	
	reg [31:0] A, A_new;
	reg [31:0] B, B_new;
	reg [31:0] C, C_new;
	reg [31:0] D, D_new;
	
	reg ready_out, ready_out_new;
	reg storedatadone,storedatadone_new;
	
	reg [5:0] stage, stage_new;
	reg [5:0] round, round_new;
	reg [43:0] k,k_new;
	
	reg [31:0] M [0:15];
	reg [511:0] storage, storage_new;
	//------------------------------------------
	// STORE DATA
	//------------------------------------------
always @(en1,en2,en3,en4)
begin

	if(en1) begin
		storage_new[511:384] = data_i;
		end
	if(en2) begin
		storage_new[383:256] = data_i;
		end
	if(en3) begin
		storage_new[255:128] = data_i;
		end
	if(en4) begin
		storage_new[127:0]   = data_i;
		storedatadone_new = 1;
		end
	end

	//------------------------------------------
	// UPDATE SIGNAL
	//------------------------------------------
always @(posedge clk)
begin

if(reset) begin
	A = 32'h01234567; 
	B = 32'h89abcdef;
	C = 32'hfedcba98;
	D = 32'h76543210;
	k = 44'hD76AA478070;
	storedatadone = 0;
	data_o = 0;
	ready_out = 0;
	stage = 0;
	round = 0;
	storage = 0;
	end
	
	else begin // UPDATE DATA
	if(storedatadone) begin
		
		stage = stage_new;
		round = round_new;	
		data_o = data_o_new;
		ready_out = ready_out_new;
		
		A = A_new;
		B = B_new;
		C = C_new;
		D = D_new;
		k = k_new;
		end
	end
	storedatadone = storedatadone_new;
	storage = storage_new;
end
//

	//------------------------------------------
	// STAGE AND ROUND CONTROL
	//------------------------------------------	

	reg [127:0] temp_out;
	
always @(A,B,C,D,round,stage,ready_out,storedatadone)
begin
if(storedatadone) begin
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
end	

	//------------------------------------------
	// ROM
	//------------------------------------------	
	always @(round)
	begin
		case(round+1)   // Ki.___________;   Si.block.
				0:  k_new = 44'hD76AA478070;// 07.0
				1:  k_new = 44'hE8C7B7560C1;// 12.1
				2:  k_new = 44'h242070DB112;// 17.2
				3:  k_new = 44'hC1BDCEEE163;// 22.3
				4:  k_new = 44'hF57C0FAF074;// 07.4
				5:  k_new = 44'h4787C62A0C5;// 12.5
				6:  k_new = 44'hA8304613116;// 17.6
				7:  k_new = 44'hFD469501167;// 22.7
				8:  k_new = 44'h698098D8078;// 07.8		
				9:  k_new = 44'h8B44F7AF0C9;// 12.9
				10: k_new = 44'hFFFF5BB111A;// 17.10
				11: k_new = 44'h895CD7BE16B;// 22.11
				12: k_new = 44'h6B90112207C;// 07.12
				13: k_new = 44'hFD9871930CD;// 12.13
				14: k_new = 44'hA679438E11E;// 17.14
				15: k_new = 44'h49B4082116F;// 22.15		
			
				16: k_new = 44'hf61e2562051;// 05.1
				17: k_new = 44'hc040b340096;// 09.6
				18: k_new = 44'h265e5a510EB;// 14.11
				19: k_new = 44'he9b6c7aa140;// 20.0
				20: k_new = 44'hd62f105d055;// 05.5
				21: k_new = 44'h0244145309A;// 09.10
				22: k_new = 44'hd8a1e6810EF;// 14.15		
				23: k_new = 44'he7d3fbc8144;// 20.4
				24: k_new = 44'h21e1cde6059;// 05.9
				25: k_new = 44'hc33707d609E;// 09.14
				26: k_new = 44'hf4d50d870E3;// 14.3
				27: k_new = 44'h455a14ed148;// 20.8
				28: k_new = 44'ha9e3e90505D;// 05.13
				29: k_new = 44'hfcefa3f8092;// 09.2		
				30: k_new = 44'h676f02d90E7;// 14.7
				31: k_new = 44'h8d2a4c8a14C;// 20.12
				
				32: k_new = 44'hfffa3942045;// 04.5
				33: k_new = 44'h8771f6810B8;// 11.8
				34: k_new = 44'h6d9d612210B;// 16.11
				35: k_new = 44'hfde5380c0DE;// 13.14
				36: k_new = 44'ha4beea44041;// 04.1		
				37: k_new = 44'h4bdecfa90B4;// 11.4
				38: k_new = 44'hf6bb4b60107;// 16.7
				39: k_new = 44'hbebfbc700DA;// 13.10
				40: k_new = 44'h289b7ec604D;// 04.13
				41: k_new = 44'heaa127fa0B0;// 11.0
				42: k_new = 44'hd4ef3085103;// 16.3
				43: k_new = 44'h04881d050D6;// 13.6		
				44: k_new = 44'hd9d4d039049;// 04.9
				45: k_new = 44'he6db99e50BC;// 11.12
				46: k_new = 44'h1fa27cf810F;// 16.15
				47: k_new = 44'hc4ac56650D2;// 13.2
				
				48: k_new = 44'hf4292244060;// 06.0
				49: k_new = 44'h432aff970A7;// 10.7
				50: k_new = 44'hab9423a70FE;// 15.14		
				51: k_new = 44'hfc93a039155;// 21.5
				52: k_new = 44'h655b59c306C;// 06.12
				53: k_new = 44'h8f0ccc920A3;// 10.3
				54: k_new = 44'hffeff47d0FA;// 15.10
				55: k_new = 44'h85845dd1151;// 21.1
				56: k_new = 44'h6fa87e4f068;// 06.8
				57: k_new = 44'hfe2ce6e00AF;// 10.15	
				58: k_new = 44'ha30143140F6;// 15.6
				59: k_new = 44'h4e0811a115D;// 21.13
				60: k_new = 44'hf7537e82064;// 06.4
				61: k_new = 44'hbd3af2350AB;// 10.11
				62: k_new = 44'h2ad7d2bb0F2;// 15.2
				63: k_new = 44'heb86d391159;// 21.9	 
		 endcase
	end	
	//------------------------------------------
	// MAIN FUNCTION
	//------------------------------------------	
		// generate var
	reg [31:0] func_tmp, func_out, shiftbit;
	reg [31:0] f,m,ki;
	reg [3:0]  Mi;
	reg [7:0]  Si;
always @(storedatadone,storage,A,B,C,D,round)
if(storedatadone) begin
	begin
		
		M[0]=storage[511:480]; 
		M[1]=storage[479:448]; 
		M[2]=storage[447:416]; 
		M[3]=storage[415:384]; 
		M[4]=storage[383:352]; 
		M[5]=storage[351:320]; 
		M[6]=storage[319:288]; 
		M[7]=storage[287:256]; 
		M[8]=storage[255:224]; 
		M[9]=storage[223:192]; 
		M[10]=storage[191:160]; 
		M[11]=storage[159:128]; 
		M[12]=storage[127:96]; 
		M[13]=storage[95:64]; 
		M[14]=storage[63:32]; 
		M[15]=storage[31:0];

	// Calculate var
		Mi = k[3:0];
		Si = k[11:4];
		f = F(B,C,D,stage);
		ki = k[43:12];
		m = M[Mi];
		func_tmp = A + f + ki + m ;
		shiftbit = shift(func_tmp,Si);
		func_out = B + shiftbit; 
		
		A_new = D;
		B_new = func_out;
		C_new = B;
		D_new = C;
	end
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
			shift = (data_in << Si)|(data_in>>(32-Si)); 
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
	forever #10 clk = ~clk;
	end
   initial
   begin
     reset = 'b1;
	  @(clk);
	  reset = 'b0;
	  #3;
	  en1   = 'b1;
	  data_i= 128'h54686579206172652064657465726D69;
	  #3;
	  en1   = 'b0;
	  en2   = 'b1;
	  data_i= 128'h6E697374696380000000000000000000;
	  #3;
	  en2   = 'b0;
	  en3   = 'b1;
	  data_i= 128'h0;
	  #3;
	  en3   = 'b0;
	  en4   = 'b1;
	  data_i= 128'h0;
   end

endmodule
