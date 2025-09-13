-------------------------------------------------------------------------------
--
-- Title       : Forwarding_unit
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : John Abraham
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/Forwarding_unit.vhd
-- Generated   : Thu Apr 17 12:26:13 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Checks to see if a register is read before it is written back to the register file.
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity Forwarding_unit is
	port(
		EX_WB_RegWrite : in STD_LOGIC;			--comes from the EX/WB reg
		EX_WB_rd_data : in STD_LOGIC_vector(127 downto 0);  --comes from the EX/WB reg 
		EX_WB_rd_addr : in STD_LOGIC_vector(4 downto 0);	  --comes from the EX/WB reg   
		
		ID_EX_instr : in STD_LOGIC_vector(24 downto 0);  --comes from the ID/EX reg
		ID_EX_rs1 : in STD_LOGIC_vector(127 downto 0);   --comes from the ID/EX reg
		ID_EX_rs2 : in STD_LOGIC_vector(127 downto 0);   --comes from the ID/EX reg
		ID_EX_rs3 : in STD_LOGIC_vector(127 downto 0);   --comes from the ID/EX reg
		ID_EX_rs1_addr : in std_logic_vector(4 downto 0);
		ID_EX_rs2_addr : in std_logic_vector(4 downto 0);  
		ID_EX_rs3_addr : in std_logic_vector(4 downto 0);		  
		
		instr_out : out STD_LOGIC_vector(24 downto 0);	--output to ALU
		rs1_out : out STD_LOGIC_vector(127 downto 0);	--output to ALU
		rs2_out : out STD_LOGIC_vector(127 downto 0);	--output to ALU
		rs3_out : out STD_LOGIC_vector(127 downto 0);	--output to ALU	
		rd_out : out STD_LOGIC_vector(127 downto 0);	--output to ALU for load forward
		forward : out std_logic							--signal that informs ALU of incoming ALUdata for load
	);
end Forwarding_unit;


architecture behavioral of Forwarding_unit is 
begin	   
	process(ID_EX_instr)
	begin  			
		-- Default assignments
	    rs1_out <= ID_EX_rs1;
	    rs2_out <= ID_EX_rs2;
	    rs3_out <= ID_EX_rs3;
		instr_out <= ID_EX_instr;
		
		forward <= '0'; --reset forward signal in next cycle if it was enabled.	
			
		if ID_EX_instr(24) = '0' and EX_WB_RegWrite = '1' and ID_EX_instr(4 downto 0) = EX_WB_rd_addr then  --if load, foward
			rd_out <= EX_WB_rd_data;
			forward <= '1';
			
		elsif (ID_EX_instr(24) = '1' and ID_EX_instr(23) = '1' and ID_EX_instr(18 downto 15) = "0000") then   -- if nop instr, dont forward
			null ;
		else 
			 
			if EX_WB_RegWrite = '1' and EX_WB_rd_data /= (EX_WB_rd_data'range => '0') and ID_EX_rs1_addr = EX_WB_rd_addr then 
				rs1_out <= EX_WB_rd_data;	 --forward the previous ALU result
			end if;
			if EX_WB_RegWrite = '1' and EX_WB_rd_data /= (EX_WB_rd_data'range => '0') and ID_EX_rs2_addr = EX_WB_rd_addr then 
				rs2_out <= EX_WB_rd_data; 	 --forward the previous ALU result
			end if;
			if EX_WB_RegWrite = '1' and EX_WB_rd_data /= (EX_WB_rd_data'range => '0') and ID_EX_rs3_addr = EX_WB_rd_addr then 
				rs3_out <= EX_WB_rd_data; 	 --forward the previous ALU result
			end if;	
		end if;
	end process;
end behavioral;	



					 
					 
					 
					 
					 
					 
					 

