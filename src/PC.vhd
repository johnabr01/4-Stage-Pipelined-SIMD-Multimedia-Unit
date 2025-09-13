-------------------------------------------------------------------------------
--
-- Title       : PC
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : John Abraham
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/PC.vhd
-- Generated   : Wed Apr 16 20:31:51 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Program Counter adds 4 on rising edge of clock and resets if the reset signal is set.
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC is
	port(
		reset : in STD_LOGIC;  
	    clk : in std_logic;
		PC : out unsigned(5 downto 0)
	);
end PC;


architecture behavioral of PC is
signal PC_reg : unsigned(5 downto 0) := (others => '0');
signal reset_released : std_logic := '0';
begin

    process(reset, clk)
    begin 
        if rising_edge(clk) then
            if reset = '1' then
                PC_reg <= (others => '0');
				reset_released <= '0';
			elsif reset_released = '1' then
                PC_reg <= PC_reg + to_unsigned(1, 6);  -- PC + 1
			else
				reset_released <= '1'; --holds pc for one more cycle.	 
            
            end if;
        end if;
    end process;

    PC <= PC_reg;  

end behavioral;
