-------------------------------------------------------------------------------
--
-- Title       : ID_EX_reg
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : John Abraham
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/ID_EX_reg.vhd
-- Generated   : Thu Apr 17 23:05:34 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Pipeline register to store values between the ID and EXE stage.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX_reg is
	port(
		clk : in STD_LOGIC;
		instr_in : in STD_LOGIC_vector(24 downto 0);
		rs1_in : in std_logic_vector(127 downto 0);
		rs2_in : in std_logic_vector(127 downto 0);
		rs3_in : in std_logic_vector(127 downto 0);
		rs1_addr_in : in std_logic_vector(4 downto 0);
		rs2_addr_in : in std_logic_vector(4 downto 0);  
		rs3_addr_in : in std_logic_vector(4 downto 0);
		rd_as_source : in std_logic_vector(127 downto 0);
		
		instr_out : out STD_LOGIC_vector(24 downto 0);
		rs1_out : out std_logic_vector(127 downto 0);
		rs2_out : out std_logic_vector(127 downto 0);
		rs3_out : out std_logic_vector(127 downto 0);
		rs1_addr_out : out std_logic_vector(4 downto 0);
		rs2_addr_out : out std_logic_vector(4 downto 0);  
		rs3_addr_out : out std_logic_vector(4 downto 0);
		rd_as_source_out : out std_logic_vector(127 downto 0)
	);
end ID_EX_reg;


architecture behavioral of ID_EX_reg is
	signal instr_reg : std_logic_vector(24 downto 0) ; 
	signal rs1_in_reg : std_logic_vector(127 downto 0);
	signal rs2_in_reg : std_logic_vector(127 downto 0);
	signal rs3_in_reg : std_logic_vector(127 downto 0);
	signal rd_as_source_reg : std_logic_vector(127 downto 0);
	signal rs1_addr_in_reg : std_logic_vector(4 downto 0);
	signal rs2_addr_in_reg : std_logic_vector(4 downto 0);  
	signal rs3_addr_in_reg : std_logic_vector(4 downto 0);
begin

	process(clk)
	begin 
		if rising_edge(clk) then	
			instr_reg <= instr_in;		 --This does not immediately update instr_reg. 
			rs1_in_reg <= rs1_in;		--Instead, VHDL schedules that update to happen after the process suspends, which is usually at the end of the current simulation cycle
			rs2_in_reg <= rs2_in;	 
			rs3_in_reg <= rs3_in;
			rs1_addr_in_reg <= rs1_addr_in;
			rs2_addr_in_reg <= rs2_addr_in;
			rs3_addr_in_reg <= rs3_addr_in;
			rd_as_source_reg <= rd_as_source;
			
		end if;			    			
	end process;
	
	instr_out <= instr_reg;			   --so instr_reg and other regs would display the value of the previous cycle.
	rs1_out <= rs1_in_reg;
	rs2_out <= rs2_in_reg;
	rs3_out <= rs3_in_reg;	
	rs1_addr_out <= rs1_addr_in_reg; 
	rs2_addr_out <= rs2_addr_in_reg;
	rs3_addr_out <= rs3_addr_in_reg;
	rd_as_source_out <= rd_as_source_reg;

end behavioral;
