//-------------------------------------------------------------------------------------------------
//  Written by JiruXu
//  SystemVerilogCSP: make the data format
//  University of Southern California
//-------------------------------------------------------------------------------------------------


package dataformat;

	class dataformater;
	
        
		static function bit[19:0] packdata(bit[4:0] senderaddr, bit[4:0] receaddr, bit[1:0] typeofdata, bit[7:0] data);
		  bit[19:0] pdata = {typeofdata, senderaddr, receaddr, data};
		  return pdata;
		endfunction
		
		static function bit[7:0] unpackdata(bit[19:0] inputdata);
		  bit[7:0] unpdata = inputdata[7:0];
		  return unpdata;
		endfunction

		static function bit[4:0] getsendaddr(bit[19:0] inputdata);
		  bit[4:0] unpdata = inputdata[17:13];
		  return unpdata;
		endfunction		

		static function bit[4:0] getreceaddr(bit[19:0] inputdata);
		  bit[4:0] unpdata = inputdata[12:8];
		  return unpdata;
		endfunction		
		
	endclass

endpackage : dataformat
 

