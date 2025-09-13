-------------------------------------------------------------------------------
--
-- Title       : EX_WB_reg
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : John Abraham
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/EX_WB_reg.vhd
-- Generated   : Thu Apr 17 23:46:15 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Pipeline register to store values between EXE and WB stages.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity EX_WB_reg is
	port(
		clk : in std_logic;
		RegWrite : in STD_LOGIC;
		rd_addr : in STD_LOGIC_vector(4 downto 0);
		rd_data : in STD_LOGIC_vector(127 downto 0);
		RegWrite_out : out STD_LOGIC;
		rd_addr_out : out STD_LOGIC_vector(4 downto 0); 
		rd_data_out : out STD_LOGIC_vector(127 downto 0)
	);
end EX_WB_reg;

architecture behavioral of EX_WB_reg is
	signal RegWrite_reg : STD_LOGIC;
	signal rd_addr_reg : STD_LOGIC_vector(4 downto 0);
	signal rd_data_reg : STD_LOGIC_vector(127 downto 0);
begin

	process(clk) 
	begin 
		if rising_edge(clk) then	
			RegWrite_reg <= RegWrite;
			rd_addr_reg <= rd_addr;
			rd_data_reg <= rd_data;
		end if;
	end process;
	
	RegWrite_out <= RegWrite_reg;
	rd_addr_out <= rd_addr_reg;
	rd_data_out <= rd_data_reg;
	
end behavioral;	  
