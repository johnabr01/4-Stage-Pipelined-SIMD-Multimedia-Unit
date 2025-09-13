-------------------------------------------------------------------------------
--
-- Title       : instr_buff
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : john
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/instr_buff.vhd
-- Generated   : Sun Apr 13 14:20:54 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The instruction buffer can store 64 25-bit instructions. 
--               The contents of the buffer should be loaded by the testbench instructions from a test file at the start of simulation. 
--               On each cycle, the instruction specified by the Program Counter (PC) is fetched, and the value of PC is incremented by 1.
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.instr_array.all;

entity PC_with_instr_buff is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
        instr_array : in instr_array;
        instr_out   : out std_logic_vector(24 downto 0)
    );
end PC_with_instr_buff;

architecture behavioral of PC_with_instr_buff is
    signal pc             : unsigned(5 downto 0) := (others => '0');
    signal reset_released : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc <= (others => '0');
                reset_released <= '0';
            elsif reset_released = '0' then
                -- Hold PC at 0 for one cycle after reset deasserted
                reset_released <= '1';
            else
				-- Fetch instruction from array using current PC
    			instr_out <= instr_array(to_integer(pc));
                pc <= pc + 1;
            end if;
        end if;
    end process;

end behavioral;

