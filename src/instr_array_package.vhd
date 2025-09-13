library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

package instr_array	is
	-- a 64 element array of 25 bit instructions.
	type instr_array is array (0 to 63) of std_logic_vector(24 downto 0);	
end package instr_array;