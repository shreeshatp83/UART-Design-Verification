interface uart_if;
  logic clk;
  logic uclktx;
  logic uclkrx;
  logic rst;
  logic rx;
  logic [7:0] dintx;
  logic newd;
  logic tx;
  logic [7:0] doutrx;
  logic donetx;
  logic donerx;
  
endinterface

class transaction;
  
  typedef enum bit  {write = 1'b0 , read = 1'b1} oper_type;
  
  randc oper_type oper;
  
  bit rx;
  
  rand bit [7:0] dintx;
  
  bit newd;
  bit tx;
  
  bit [7:0] doutrx;
  bit donetx;
  bit donerx;
  
 
  
  function transaction copy();
    copy = new();
    copy.rx = this.rx;
    copy.dintx = this.dintx;
    copy.newd = this.newd;
    copy.tx = this.tx;
    copy.doutrx = this.doutrx;
    copy.donetx = this.donetx;
    copy.donerx = this.donerx;
    copy.oper = this.oper;
  endfunction
  
endclass
 
 


 
 
class generator;
  
 transaction tr;
  
  mailbox #(transaction) mbx;
  
  event done;
  
  int count = 0;
  
  event drvnext;
  event sconext;
  
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction
  
  
  task run();
  
    repeat(count) begin
      assert(tr.randomize) else $error("[GEN] :Randomization Failed");
      mbx.put(tr.copy);
      $display("[GEN]: Oper : %0s Din : %0d",tr.oper.name(), tr.dintx);
      @(drvnext);
      @(sconext);
    end
    
    -> done;
  endtask
  
  
endclass
 
/////////////////////////////////////////////////////////
 
class driver;
  
  
  virtual uart_if vif;
  
  transaction tr;
  
  mailbox #(transaction) mbx;
  
  mailbox #(bit [7:0]) mbxds;
  
  
  event drvnext;
  
  bit [7:0] din;
  
  
  bit wr = 0;  ///random operation read / write
  bit [7:0] datarx;  ///data rcvd during read
  
  
  
  
  
  function new(mailbox #(bit [7:0]) mbxds, mailbox #(transaction) mbx);
    this.mbx = mbx;
    this.mbxds = mbxds;
   endfunction
  
  
  
  task reset();
    vif.rst <= 1'b1;
    vif.dintx <= 0;
    vif.newd <= 0;
    vif.rx <= 1'b1;
 
    repeat(5) @(posedge vif.uclktx);
    vif.rst <= 1'b0;
    @(posedge vif.uclktx);
    $display("[DRV] : RESET DONE");
    $display("----------------------------------------");
  endtask
  
  
  
  task run();
  
    forever begin
      mbx.get(tr);
      
      if(tr.oper == 1'b0)  ////data transmission
          begin
          //           
            @(posedge vif.uclktx);
            vif.rst <= 1'b0;
            vif.newd <= 1'b1;  ///start data sending op
            vif.rx <= 1'b1;
            vif.dintx = tr.dintx;
            @(posedge vif.uclktx);
            vif.newd <= 1'b0;
              ////wait for completion 
            //repeat(9) @(posedge vif.uclktx);
            mbxds.put(tr.dintx);
            $display("[DRV]: Data Sent : %0d", tr.dintx);
             wait(vif.donetx == 1'b1);  
             ->drvnext;  
          end
      
      else if (tr.oper == 1'b1)
               begin
                 
                 @(posedge vif.uclkrx);
                  vif.rst <= 1'b0;
                  vif.rx <= 1'b0;
                  vif.newd <= 1'b0;
                  @(posedge vif.uclkrx);
                  
                 for(int i=0; i<=7; i++) 
                 begin   
                      @(posedge vif.uclkrx);                
                      vif.rx <= $urandom;
                      datarx[i] = vif.rx;                                      
                 end 
                 
                 
                mbxds.put(datarx);
                
                $display("[DRV]: Data RCVD : %0d", datarx); 
                wait(vif.donerx == 1'b1);
                 vif.rx <= 1'b1;
				->drvnext;
                 
 
             end         
  
       
      
    end
    
  endtask
  
endclass
 

 
module tb;
  generator gen;
  driver drv;
  event next;
  event done;
  mailbox #(transaction) mbx;
  mailbox #(bit [7:0]) mbxt;
  
  uart_if vif();
  
  uart_top #(1000000, 9600) dut (vif.clk,vif.rst,vif.rx,vif.dintx,vif.send,vif.tx,vif.doutrx,vif.donetx, vif.donerx);
  
  
  
    initial begin
      vif.clk <= 0;
    end
    
    always #10 vif.clk <= ~vif.clk;
  
  
 
  initial begin
    mbx = new();
    mbxt = new();
    gen = new(mbx);
    drv = new(mbxt,mbx);
    gen.count  = 20;
    drv.vif = vif;
    
    gen.drvnext = next;
    
    drv.drvnext = next;
  end
  
  initial begin
    
    fork 
      gen.run(); 
      drv.run();
    join_none
    wait(gen.done.triggered);
    $finish();
  end
  
  initial begin
  $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  
     
assign vif.uclktx = dut.utx.uclk;
assign vif.uclkrx = dut.rtx.uclk;
    
  
  
endmodule