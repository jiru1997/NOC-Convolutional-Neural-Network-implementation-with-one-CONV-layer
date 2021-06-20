//-------------------------------------------------------------------------------------------------
// memory module 
// function:load data from filter and send them to PES
//-------------------------------------------------------------------------------------------------
`timescale 1ns/1fs
import SystemVerilogCSP::*;
import dataformat::*;

module memory

	#(parameter WIDTH = 5,
	parameter VALID_DATA_WIDTH = 8,
	parameter FILTER_WIDTH = 50,
	parameter IFMAP_WIDTH = 50,
    parameter RESULT_WIDTH = 80,
	parameter DATA_WIDTH = 20,
    parameter FILTER_NUM = 3,
    parameter IFMAP_NUM = 7,
    parameter NUM_OF_FILTER = 3,
    parameter DEPTH_R = 5,
    parameter WIDTH_R = 5,
	parameter FL = 12,
	parameter BL = 4,
	parameter PACKDEALY = 1)

	(input bit[WIDTH - 1:0] _index,
   interface sys_data_in, 
   interface sys_addr_in,
   interface sys_data_out,
   interface sys_addr_out,
   interface tb_addr_in,
   interface tb_addr_out,
     interface result_addr,
     interface result_data,
     interface ccToMem);

    int fpt;
    bit filterflag;
    bit mapperflag;
    bit flag = 0;
    bit[WIDTH - 1:0] index;
    bit[WIDTH - 1:0] rece_index;
    bit[VALID_DATA_WIDTH - 1:0] f_addr;
    bit[VALID_DATA_WIDTH - 1:0] m_addr;
    bit[VALID_DATA_WIDTH - 1:0] r_addr;
    bit[VALID_DATA_WIDTH - 1:0] f_data;
    bit[VALID_DATA_WIDTH - 1:0] m_data;
    bit[VALID_DATA_WIDTH - 1:0] r_data;
    bit[DATA_WIDTH - 1:0] data_send;                                    
    bit[DATA_WIDTH - 1:0] data_rece;                                    
    bit[FILTER_WIDTH - 1:0][VALID_DATA_WIDTH - 1:0] filter_data;        
	bit[IFMAP_WIDTH - 1:0][VALID_DATA_WIDTH - 1:0]  ifmap_data;         
	bit[RESULT_WIDTH - 1:0][VALID_DATA_WIDTH - 1:0]  final_data;         
	bit[VALID_DATA_WIDTH - 1:0] filter_pointer = 0;
	bit[VALID_DATA_WIDTH - 1:0] ifmapper_pointer = 0;
	bit[VALID_DATA_WIDTH - 1:0] final_pointer = 0;

    always begin
      result_addr.Receive(r_addr);
      #FL;
      result_data.Send(final_data[r_addr]);
      #BL;
    end

    always begin
      fork
      sys_data_in.Receive(f_data);
      sys_addr_in.Receive(f_addr);
      join
      #FL;
      filter_data[f_addr] = f_data;
      $fwrite(fpt,"filter data: mem[%d]= %d\n",f_addr, filter_data[f_addr]);
      //$display("filter data: mem[%d]= %d",f_addr, filter_data[f_addr]);
      if(f_addr == FILTER_NUM * FILTER_NUM - 1) begin
        filterflag = 1;
      end
    end

    always begin
      fork
      sys_data_out.Receive(m_data);
      sys_addr_out.Receive(m_addr);
      join
      #FL;
      ifmap_data[m_addr] = m_data;
      $fwrite(fpt,"mapper data: mem[%d]= %d\n",m_addr, ifmap_data[m_addr]);
      //$display("mapper data: mem[%d]= %d",m_addr, ifmap_data[m_addr]);
      if(m_addr == IFMAP_NUM * IFMAP_NUM - 1) begin
        mapperflag = 1;
      end
    end

    always begin
      tb_addr_in.Receive(data_rece);
      wait(mapperflag == 1 && filterflag == 1);
      if(data_rece[DATA_WIDTH - 1] == 0 && data_rece[DATA_WIDTH - 2] == 1) begin         
      	 rece_index = dataformater::getsendaddr(data_rece);
		 #PACKDEALY;
         ifmapper_pointer = dataformater::unpackdata(data_rece); 
		 #PACKDEALY;
         data_send = dataformater::packdata(index, rece_index, 1, ifmap_data[ifmapper_pointer]);
		 #PACKDEALY;
         tb_addr_out.Send(data_send);
         #BL;
      end
      else if(data_rece[DATA_WIDTH - 1] == 1 && data_rece[DATA_WIDTH - 2] == 0) begin    
      	 rece_index = dataformater::getsendaddr(data_rece); 
         #PACKDEALY;		 
         filter_pointer = dataformater::unpackdata(data_rece); 
		 #PACKDEALY;
         data_send = dataformater::packdata(index, rece_index, 2, filter_data[filter_pointer]);
		 #PACKDEALY;
         tb_addr_out.Send(data_send);
         #BL;
      end
      else if(data_rece[DATA_WIDTH - 1] == 0 && data_rece[DATA_WIDTH - 2] == 0) begin    
      	 final_data[final_pointer] = dataformater::unpackdata(data_rece);
         #PACKDEALY;		 
         $display("-----memory fianl result %d", final_data[final_pointer]);
      	 final_pointer = final_pointer + 1;
         if(final_pointer == DEPTH_R * WIDTH_R * NUM_OF_FILTER) begin
          ccToMem.Send(flag);
          #BL;
          ccToMem.Receive(flag);
          #FL;
         end
      end
      #BL;
    end

  initial begin
 	#0.1;
  fpt = $fopen("transcript.dump");
    index = _index;
    filterflag = 0;
    mapperflag = 0;
    ccToMem.Receive(flag);
	#FL;
  end

endmodule