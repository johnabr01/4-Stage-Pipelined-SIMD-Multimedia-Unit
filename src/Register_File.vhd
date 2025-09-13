-------------------------------------------------------------------------------
--
-- Title       : Register_File
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : John Abraham
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/Register_File.vhd
-- Generated   : Sun Apr 13 11:54:29 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The register file has 32 128-bit registers. On any cycle,there can be 3 reads and 1 write. 
--               When executing instructions, each cycle two/three 128-bit register values are read,and one 128-bit result can be written if a write signal is valid. 
--               This register write signal must be explicitly declared so it can be checked during simulation and demonstration of your design.
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;  
use ieee.numeric_std.all;

entity Register_File is
	port(	  
		reset : in std_logic;
		clk : in std_logic;	  	--comes from tb
		instr_in : in std_logic_vector(24 downto 0);   --comes from instr_buff
		write_reg_addr : in std_logic_vector(4 downto 0);	--comes from ALU
		write_data : in std_logic_vector(127 downto 0); 	--comes from ALU
		RegWrite : in STD_LOGIC;							--comes from ALU. It is zero only for nop.
			
		instr_out : out std_logic_vector(24 downto 0); --for the ALU to decode the instr and perform the specific operation.
		read_data_rs1 : out std_logic_vector(127 downto 0);
		read_data_rs2 : out std_logic_vector(127 downto 0);
		read_data_rs3 : out std_logic_vector(127 downto 0);
		read_rd_as_source : out std_logic_vector(127 downto 0);
		
		rs1_addr : out std_logic_vector(4 downto 0);
		rs2_addr : out std_logic_vector(4 downto 0);  
		rs3_addr : out std_logic_vector(4 downto 0)

	);
end Register_File;


architecture behavioral of Register_File is	 
    type reg_array_t is array (0 to 31) of std_logic_vector(127 downto 0);
    signal reg_file : reg_array_t := (others => (others => '0'));	
begin 										   
	
	--write only on the rising edge of clk and when the RegWrite signal is valid	
	process (clk)
	variable index : integer;
	variable temp1 :  std_logic_vector(127 downto 0); 
	variable temp2 :  std_logic_vector(127 downto 0);
	variable temp3 :  std_logic_vector(127 downto 0);
    begin 
		--if reset='1' then
		--	reg_file(0) <= X"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";	   --rs1
		--	reg_file(1) <= X"00007FFF00007FFF00007FFF00007FFF";	   --rs2
		--	reg_file(2) <= X"00007FFF00007FFF00007FFF00007FFF";	   --rs3
		--end if;	
		
		
		
		if rising_edge(clk) then
        	if RegWrite = '1' then 
				if instr_in(24) = '0' then
					--temp1 :=reg_file(to_integer(unsigned(write_reg_addr)));
					--temp2 := write_data;
					--temp3 := reg_file(to_integer(unsigned(write_reg_addr))) AND write_data;	
						
					reg_file(to_integer(unsigned(write_reg_addr))) <= reg_file(to_integer(unsigned(write_reg_addr))) OR write_data;
			   	else 
		            index := to_integer(unsigned(write_reg_addr));
		            reg_file(index) <= write_data;
				end if;
	        end if;	
		end if;
    end process;

	--send rs1,rs2,rs3 as outputs		  
	--if rs1, rs2, rs3 are not used by an instruction, we still send them because its easier that way and plus the ALU wont read the registers it doesnt need for computation. 
	read_data_rs1 <= reg_file(to_integer(unsigned(instr_in(9 downto 5)))); 
	read_data_rs2 <= reg_file(to_integer(unsigned(instr_in(14 downto 10))));  
	read_data_rs3 <= reg_file(to_integer(unsigned(instr_in(19 downto 15)))); 
	read_rd_as_source <= reg_file(to_integer(unsigned(instr_in(4 downto 0))));
	
	rs1_addr <= instr_in(9 downto 5);
	rs2_addr <= instr_in(14 downto 10);
	rs3_addr <= instr_in(19 downto 15);
	
	instr_out <= instr_in;

end behavioral;
