`timescale 1ns / 1ps


module uart_top #( parameter clk_freq = 10000000, baud_rate = 9600 )
(input clk,rst,rx, input [7:0] din, input new_data, output tx,donetx, donerx, output [7:0] doutrx );

uarttx #(clk_freq,baud_rate) utx (clk,rst,new_data,din,tx,donetx);

uartrx #(clk_freq,baud_rate) rtx (clk,rst,rx,donerx,doutrx);



endmodule
