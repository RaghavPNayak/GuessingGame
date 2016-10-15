`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:06:45 06/16/2016 
// Design Name: 
// Module Name:    project2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module project2(sw,btn,clk,plKey,setNo,a,b,c,d,e,f,g,dp,an,led,enable);
	input clk,plKey,enable,setNo;
	input [3:0] sw;
	input [3:0] btn;
	output [3:0] an;
	output [7:0] led;
	output a,b,c,d,e,f,g,dp;
	
	//Soft var
	reg [7:0] led;
	reg a,b,c,d,e,f,g,dp;
	reg [3:0] an;
	reg [3:0] sw0,sw1,sw2,sw3;
	reg [3:0] tempAn=0;
	reg newClk;
	integer countClk,countLed,countClk1;
	reg [3:0] cstate=0,nstate=0,anstate=0;
	reg [3:0] state=0;
	reg flagSetNo=0,flagP1=0,flagP2=0,flagFinalSaved=0,flagBtn=0,flagGuessSaved=0,flagCheck=0,flagSet=0;
	reg [15:0] finalKey=0, guessKey=0;
	integer guessCount=0,guessCounta=0,guessCountb=0;
	
//	
//	always @(posedge clk) begin
//	if(countClk1>1000)begin
//	newClk=~newClk;
//	countClk1=0;
//	end
//	countClk1=countClk1+1;
//	end
//	
	
	always @(posedge clk) begin
	
	if (~enable) begin cstate=0;nstate=0; end
	else nstate=cstate;

	case(btn)
	4'b1000: begin cstate[3]=1; sw3=sw; end
   4'b0100: begin cstate[2]=1; sw2=sw; end
   4'b0010: begin cstate[1]=1; sw1=sw; end
   4'b0001: begin cstate[0]=1; sw0=sw; end
	4'b0000: cstate=nstate;
	//default: cstate=0; //when no button is pressed
	endcase
	
	
	if(enable==1) begin
		//All conditions embedded in var state
		if(plKey==0 && cstate==0) 															//Display PL-1 & set flagP1=1
		begin 
			state=0; 
			flagP1=1; 
		end
		
		if(cstate>0 && cstate<=15)										//Display numbers on seven segment display 
		begin
			if (state != 4)
				state=1;
		end

		if(plKey==1 && flagP1==1)															//set flagP1=0 & flagP2=1 
		begin 
			state=2;
			cstate=0;
			flagP1=0; 
			flagP2=1;																			//save finalKey + erase cstate=0
		end
		
		if(flagFinalSaved==1 && flagP2==1 && cstate==0)											//Display PL-2
		begin 
			state=3; 
			flagFinalSaved=0; 
		end 
		
		if(setNo==1 && cstate==15) 																			//set flagSetNo=1 --> fixing the guess no
			flagSetNo=1;
			
		if(setNo==0 && flagSetNo==1)
		begin 
			flagSet=1;
			flagSetNo=0;
		end
		
		if(flagP2==1 && flagSet==1)									//save guessKey
		begin 
			state=4;
			flagSet=0;
		end
		
		
		if (flagGuessSaved==1) 
		begin 
			if(guessKey[15:0]==finalKey[15:0])										//Blink Led's and display the number of guesses 
				begin 
					state=5;
					guessCount=guessCount+1;
				end
				
			if((guessKey[15:12]>finalKey[15:12])||(guessKey[15:12]==finalKey[15:12] && guessKey[11:8]>finalKey[11:8])||(guessKey[15:12]==finalKey[15:12] && guessKey[11:8]==finalKey[11:8] && guessKey[7:4]>finalKey[7:4])||(guessKey[15:12]==finalKey[15:12] && guessKey[11:8]==finalKey[11:8] && guessKey[7:4]==finalKey[7:4] && guessKey[3:0]>finalKey[3:0]))
				begin 
					state=6;
					guessCount=guessCount+1;
				end 																			// display 2-HI
				
			if((guessKey[15:12]<finalKey[15:12])||(guessKey[15:12]==finalKey[15:12] && guessKey[11:8]<finalKey[11:8])||(guessKey[15:12]==finalKey[15:12] && guessKey[11:8]==finalKey[11:8] && guessKey[7:4]<finalKey[7:4])||(guessKey[15:12]==finalKey[15:12] && guessKey[11:8]==finalKey[11:8] && guessKey[7:4]==finalKey[7:4] && guessKey[3:0]<finalKey[3:0]))
				begin 
					state=7; 
					guessCount=guessCount+1;
				end 																			// display 2-LO
		end
		
	end
	
	if(enable==0) state=8;
	
	$display("SW No: %d", sw);
	$display("Button: %d", btn);
	$display("CState: %d", cstate);
	$display("State: %d", state);
	$display("Flag of Guess: %b", flagGuessSaved);
	$display("Guess Count: %d", guessCount);
	$display("flagP1: %d", flagP1);
	$display("flagP2: %d", flagP2);
	$display("----------------------------");
	
	case(state)
	4'd0: 
		begin
		anstate=15;
		case(an)
				4'b1110: sevenSeg(4'd1); 
				4'b1101: sevenSegAlpha(3'd2); 
				4'b1011: sevenSegAlpha(3'd1); 
				4'b0111: sevenSegAlpha(3'd0);  
			endcase
		end
	4'd1:
		begin
		anstate=cstate;
			case(an)
				4'b1110: sevenSeg(sw0); 
				4'b1101: sevenSeg(sw1); 
				4'b1011: sevenSeg(sw2); 
				4'b0111: sevenSeg(sw3); 
			endcase
		end
	4'd2:
		begin
		finalKey[3:0]=sw0;
		finalKey[7:4]=sw1;
		finalKey[11:8]=sw2;
		finalKey[15:12]=sw3;
		flagFinalSaved=1;
		end
	4'd3:
		begin
		anstate=15;
		case(an)
			4'b1110: sevenSeg(4'd2); 
			4'b1101: sevenSegAlpha(3'd2); 
			4'b1011: sevenSegAlpha(3'd1); 
			4'b0111: sevenSegAlpha(3'd0);  
		endcase
		end
	4'd4:
		begin
		guessKey[3:0]=sw0;
		guessKey[7:4]=sw1;
		guessKey[11:8]=sw2;
		guessKey[15:12]=sw3;
		//cstate=0;
		//flagSet=0;
		flagGuessSaved=1;
		end
	4'd5:
		begin
			cstate=0;
			flagGuessSaved=0;
			//guessCount=guessCount+1;
			if(countLed>5000000)
			begin
				led=~led;
				countLed=0;
			end
			countLed=countLed+1;
			
			if(guessCount<16)begin
			anstate=1;
			case(an)
			4'b1110: sevenSeg(guessCount);
			endcase
			end
			
			if(guessCount>15 && guessCount<32) begin
			guessCounta=guessCount%16;
			guessCountb=guessCount/16;
			anstate=3;
			case(an)
			4'b1110: sevenSeg(guessCounta);
			4'b1110: sevenSeg(guessCountb);
			endcase
			end
		end
	4'd6:
		begin
		cstate=0;
		flagGuessSaved=0;
		//guessCount=guessCount+1;
		anstate=7;
		case(an)
			4'b1110: sevenSegAlpha(3'd4); 
			4'b1101: sevenSegAlpha(3'd3); 
			4'b1011: sevenSeg(4'd2); 
		endcase
		end
	4'd7:
		begin
		cstate=0;
		flagGuessSaved=0;
		//guessCount=guessCount+1;
		anstate=7;
		case(an)
			4'b1110: sevenSegAlpha(3'd6); 
			4'b1101: sevenSegAlpha(3'd1); 
			4'b1011: sevenSeg(4'd2); 
		endcase
		end
	4'd8: 
		begin
		anstate=0;
		flagSetNo=0;
		flagP1=0;
		flagP2=0;
		guessKey=0;
		finalKey=0;
		cstate=0;
		led=0;
		state=0;
		flagCheck=0;
		guessCount=0;
		guessCounta=0;
		guessCountb=0;
		end
	
	endcase	
		
	if(countClk>25000)
	begin
	case(anstate)
		4'b0000: tempAn=4'b1111;
		4'b0001: tempAn=4'b1110; 
		4'b0010: tempAn=4'b1101;
		4'b0011:
				begin
				case(tempAn)
				4'b1110: tempAn=4'b1101;
				4'b1101: tempAn=4'b1110;
				default: tempAn=4'b1110;
				endcase
				end
		4'b0100: tempAn=4'b1011;
		4'b0101:
			begin
			case(tempAn)
			4'b1110: tempAn=4'b1011;
			4'b1011: tempAn=4'b1110;
			default: tempAn=4'b1110;
			endcase
			end
		4'b0110:	
			begin
			case(tempAn)
			4'b1101: tempAn=4'b1011;
			4'b1011: tempAn=4'b1101;
			default: tempAn=4'b1101;
			endcase
			end
		4'b0111:
			begin
			case(tempAn)
			4'b1110: tempAn=4'b1101;
			4'b1101: tempAn=4'b1011;
			4'b1011: tempAn=4'b1110;
			default: tempAn=4'b1110;
			endcase
			end
		4'b1000: tempAn=4'b0111;
		4'b1001:
			begin
			case(tempAn)
			4'b1110: tempAn=4'b0111;
			4'b0111: tempAn=4'b1110;
			default: tempAn=4'b1110;
			endcase
			end
		4'b1010:
			begin
			case(tempAn)
			4'b1101: tempAn=4'b0111;
			4'b0111: tempAn=4'b1101;
			default: tempAn=4'b1101;
			endcase
			end
		4'b1011:
			begin
			case(tempAn)
			4'b1110: tempAn=4'b1101;
			4'b1101: tempAn=4'b0111;
			4'b0111: tempAn=4'b1110;
			default: tempAn=4'b1110;
			endcase
			end
		4'b1100:
			begin
			case(tempAn)
			4'b0111: tempAn=4'b1011;
			4'b1011: tempAn=4'b0111;
			default: tempAn=4'b0111;
			endcase
			end
		4'b1101:
			begin
			case(tempAn)
			4'b0111: tempAn=4'b1011;
			4'b1011: tempAn=4'b1110;
			4'b1110: tempAn=4'b0111;
			default: tempAn=4'b0111;
			endcase
			end
		4'b1110:
			begin
			case(tempAn)
			4'b0111: tempAn=4'b1011;
			4'b1011: tempAn=4'b1101;
			4'b1101: tempAn=4'b0111;
			default: tempAn=4'b0111;
			endcase
			end
		4'b1111:
			begin
			case(tempAn)
			4'b1110: tempAn=4'b1101;
			4'b1101: tempAn=4'b1011;
			4'b1011: tempAn=4'b0111;
			4'b0111: tempAn=4'b1110;
			default: tempAn=4'b1110;
			endcase
			end
	endcase
	countClk=0;
	end
	else countClk=countClk+1;
	
	an = tempAn;
	end
	
	
	//For Seven Segment Display
	task sevenSeg;
	input [3:0] n0;
	case (n0)
	//abcdegf - 7 segments in that order
	4'd0:  begin a=0; b=0; c=0; d=0; e=0; f=0; g=1; dp=1; end //0
	4'd1:  begin a=1; b=0; c=0; d=1; e=1; f=1; g=1; dp=1; end //1
	4'd2:  begin a=0; b=0; c=1; d=0; e=0; f=1; g=0; dp=1; end //2
	4'd3:  begin a=0; b=0; c=0; d=0; e=1; f=1; g=0; dp=1; end //3
	4'd4:  begin a=1; b=0; c=0; d=1; e=1; f=0; g=0; dp=1; end //4
	4'd5:  begin a=0; b=1; c=0; d=0; e=1; f=0; g=0; dp=1; end //5
	4'd6:  begin a=0; b=1; c=0; d=0; e=0; f=0; g=0; dp=1; end //6
	4'd7:  begin a=0; b=0; c=0; d=1; e=1; f=1; g=1; dp=1; end //7
	4'd8:  begin a=0; b=0; c=0; d=0; e=0; f=0; g=0; dp=1; end //8
	4'd9:  begin a=0; b=0; c=0; d=0; e=1; f=0; g=0; dp=1; end //9
	4'd10: begin a=0; b=0; c=0; d=1; e=0; f=0; g=0; dp=1; end //a
	4'd11: begin a=1; b=1; c=0; d=0; e=0; f=0; g=0; dp=1; end //b
	4'd12: begin a=0; b=1; c=1; d=0; e=0; f=0; g=1; dp=1; end //c
	4'd13: begin a=1; b=0; c=0; d=0; e=0; f=1; g=0; dp=1; end //d
	4'd14: begin a=0; b=1; c=1; d=0; e=0; f=0; g=0; dp=1; end //e
	4'd15: begin a=0; b=1; c=1; d=1; e=0; f=0; g=0; dp=1; end //f
	default: begin a=1; b=1; c=1; d=1; e=1; f=1; g=1; dp=1; end //default
	endcase
	endtask
	
	
	task sevenSegAlpha;
	input [2:0] n1;
	case (n1)
	//abcdegf - 7 segments in that order
	3'd0:  begin a=0; b=0; c=1; d=1; e=0; f=0; g=0; dp=1; end //P
	3'd1:  begin a=1; b=1; c=1; d=0; e=0; f=0; g=1; dp=1; end //L
	3'd2:  begin a=1; b=1; c=1; d=1; e=1; f=1; g=0; dp=1; end //-
	3'd3:  begin a=1; b=0; c=0; d=1; e=0; f=0; g=0; dp=1; end //H
	3'd4:  begin a=1; b=1; c=1; d=1; e=0; f=0; g=1; dp=1; end //I
	3'd5:  begin a=0; b=0; c=0; d=0; e=0; f=0; g=0; dp=1; end //B
	3'd6:  begin a=0; b=0; c=0; d=0; e=0; f=0; g=1; dp=1; end //O
	3'd7:  begin a=0; b=0; c=0; d=1; e=0; f=0; g=0; dp=1; end //A
	default: begin a=1; b=1; c=1; d=1; e=1; f=1; g=1; dp=1; end //default
	endcase
	endtask
	
	
	task sevenSegDef;
	begin
	a=1; b=1; c=1; d=1; e=1; f=1; g=1; dp=1;
	end
	endtask
	
	

endmodule
