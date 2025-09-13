-------------------------------------------------------------------------------
--
-- Title       : IF_ID_reg
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : John Abraham
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/IF_ID_reg.vhd
-- Generated   : Thu Apr 17 22:26:38 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Pipeline register to store values between IF stage and ID stage.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID_reg is
	port(
		clk : in STD_LOGIC;
		instr_in : in STD_LOGIC_vector(24 downto 0);
		instr_out : out STD_LOGIC_vector(24 downto 0)
	);
end IF_ID_reg;

architecture behavioral of IF_ID_reg is	
signal instr_reg : std_logic_vector(24 downto 0);
begin
	process(clk)  
	begin 
		if rising_edge(clk) then 	
			instr_reg <= instr_in;		 --This does not immediately update instr_reg. 
		end if;			    			--Instead, VHDL schedules that update to happen after the process suspends, which is usually at the end of the current simulation cycle
	end process;
	
	instr_out <= instr_reg;			   --so instr_reg would display the value of the previous cycle.
end behavioral;
