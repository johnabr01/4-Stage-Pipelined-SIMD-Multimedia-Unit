library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
use work.instr_array.all;

entity tb_Pipelined_SIMD_multimedia_unit is
end tb_Pipelined_SIMD_multimedia_unit;

architecture sim of tb_Pipelined_SIMD_multimedia_unit is

	-- Constants
	constant clk_period : time := 10 ns;
	
	-- Signals
	signal clk              : std_logic := '0';
	signal reset            : std_logic := '0';
	signal instr_array_sig  : instr_array := (others => (others => '0'));
	signal pipeline_data_out : std_logic_vector(127 downto 0);
	
	-- File handles
	file instr_file        : text open read_mode is "instructions.txt";
	file expected_file     : text open read_mode is "expected_regs.txt";
	
	-- For comparison
	type expected_array_t is array (0 to 63) of std_logic_vector(127 downto 0);
	signal expected_outputs : expected_array_t;
	
	-- Helper function
	function slv_to_string(slv: std_logic_vector) return string is
		variable result: string(1 to slv'length);
	begin
		for i in slv'range loop
		result(slv'length - i) := character'VALUE(std_ulogic'image(slv(i)));
		end loop;
		return result;
	end;			 
	
	-- helper function to convert hex to binary
	function hex_to_slv(hexstr: string; width: natural) return std_logic_vector is
		variable result : std_logic_vector(width - 1 downto 0);
		variable hexval : natural;
		variable nibble : std_logic_vector(3 downto 0);
		variable c      : character;
	begin
		for i in 0 to hexstr'length - 1 loop
			c := hexstr(hexstr'low + i);
			case c is
				when '0' => nibble := "0000";
				when '1' => nibble := "0001";
				when '2' => nibble := "0010";
				when '3' => nibble := "0011";
				when '4' => nibble := "0100";
				when '5' => nibble := "0101";
				when '6' => nibble := "0110";
				when '7' => nibble := "0111";
				when '8' => nibble := "1000";
				when '9' => nibble := "1001";
				when 'A' | 'a' => nibble := "1010";
				when 'B' | 'b' => nibble := "1011";
				when 'C' | 'c' => nibble := "1100";
				when 'D' | 'd' => nibble := "1101";
				when 'E' | 'e' => nibble := "1110";
				when 'F' | 'f' => nibble := "1111";
				when others =>
				report "Invalid hex character: " & c severity error;
				nibble := (others => 'X');
			end case;
			result(width - 1 - i * 4 downto width - 4 - i * 4) := nibble;
		end loop;
		return result;
	end;

	signal done : boolean := false;

begin

	-- Clock process
	clk_process : process
	begin
		while not done loop
			clk <= '0'; wait for clk_period / 2;
			clk <= '1'; wait for clk_period / 2;
		end loop;
		wait;
	end process;
	
	-- Instantiate the DUT
	uut: entity work.Pipelined_SIMD_multimedia_unit
		port map (
		clk              => clk,
		reset            => reset,
		instr_array      => instr_array_sig,
		pipeline_data_out => pipeline_data_out
		);
	
	-- Read input and expected files
	load_data : process
		variable line_var : line;
		variable temp25   : std_logic_vector(24 downto 0);
		variable temp128  : std_logic_vector(127 downto 0);	
		variable hexstr : string(1 to 32);  -- for 128-bit values
	begin
		-- Load 64 instructions into instr_array
		for i in 0 to 24 loop
			readline(instr_file, line_var);
			read(line_var, temp25);
			instr_array_sig(i) <= temp25;
		end loop;
	
		-- Load 64 expected results
		for i in 0 to 24 loop
		readline(expected_file, line_var);
		read(line_var, hexstr);
		expected_outputs(i) <= hex_to_slv(hexstr, 128);
		end loop;
		
		wait;
	end process;
	
	-- Stimulus and comparison
	stim_proc : process
	    variable instr_index : integer := 0;
	    variable cycle_count : integer := 0;
	begin
	    -- Apply reset
	    reset <= '1';
	    wait for 2 * clk_period;
	    reset <= '0';
	    wait for clk_period;
	
	    -- Run for total cycles = instructions + latency
	    for cycle_count in 0 to 63  loop
	        wait for clk_period;
	
	        -- Compare outputs only after the first 4 cycles
	        if cycle_count >= 4 then
	            instr_index := cycle_count - 4;
	
	            if pipeline_data_out /= expected_outputs(instr_index) then
	                report "Mismatch at index " & integer'image(instr_index) & ": Expected " &
	                    slv_to_string(expected_outputs(instr_index)) & ", Got " &
	                    slv_to_string(pipeline_data_out)
	                    severity error;
	            else
	                report "Match at index " & integer'image(instr_index) severity note;
	            end if;
	        end if;
	    end loop;
	
	    report "Simulation finished." severity note;
	    done <= true;
	    wait for clk_period;
	    std.env.finish;
	end process;
	
end sim;
