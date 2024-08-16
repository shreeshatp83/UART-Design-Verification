`timescale 1ns / 1ps



module uartrx #(
parameter clk_freq  =10000000,
parameter baud_rate = 9600
    )
    (input clock,rst,rx,output reg done, output reg [7:0] rxdata);
    
    localparam clkcount = (clk_freq/baud_rate);
    
    integer count = 0;
    integer  counts = 0;
    
    enum bit [1:0] {idle = 2'b00,start = 2'b01} state;
     
    reg uclk = 0;
    
    always@(posedge clock)
    begin 
    if(clock < clkcount/2)
        count <= count +1;
        else begin
        count = 0;
        uclk <= ~uclk;
        end 
      end
      
      
      always@(posedge clock)
      begin
       if(rst) begin
            rxdata <= 8'b0;
            counts <=0;
            done <=1'b0;
        end
    
    else begin
    case(state)
    
    idle: 
    begin
    rxdata <= 8'b0;
    counts <= 0;
    done <= 1'b0;
    
        if(rx == 1'b0) begin
            state <= start;
            end
            else begin
            state <= idle;
            end
    end
        
   start : begin 
   if(counts <= 7) begin 
            counts <= counts +1;
            rxdata = {rx,rxdata[7:1]};
            end
   else begin
       counts <=0;
       done <=1'b1;
       end
   end   
   
   default: state <= idle;
   
        
        endcase
        end
        end
                
      
      endmodule