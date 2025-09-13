library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
use work.instr_array.all;

entity tb_Pipelined_SIMD_multimedia_unit is
end tb_Pipelined_SIMD_multimedia_unit;

architecture behavior of tb_Pipelined_SIMD_multimedia_unit is

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
    file signal_debug_file : text open write_mode is "pipeline_debug.txt";	
	file comp_file : text open write_mode is "comparison.txt";
    
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
	
	function slv_to_hex(slv: std_logic_vector) return string is -- convert std to hex
        variable hexstr : string(1 to (slv'length+3)/4);
        variable nibble : std_logic_vector(3 downto 0);
        variable i_hex  : integer;
    begin
        i_hex := hexstr'low;
        
        for i in (slv'length-1)/4 downto 0 loop
            if (i = (slv'length-1)/4) and ((slv'length mod 4) /= 0) then
                nibble := (others => '0');
                for j in (slv'length mod 4)-1 downto 0 loop
                    nibble(j) := slv(i*4 + j);
                end loop;
            else
                nibble := slv(i*4 + 3 downto i*4);
            end if;
            
            case nibble is
                when "0000" => hexstr(i_hex) := '0';
                when "0001" => hexstr(i_hex) := '1';
                when "0010" => hexstr(i_hex) := '2';
                when "0011" => hexstr(i_hex) := '3';
                when "0100" => hexstr(i_hex) := '4';
                when "0101" => hexstr(i_hex) := '5';
                when "0110" => hexstr(i_hex) := '6';
                when "0111" => hexstr(i_hex) := '7';
                when "1000" => hexstr(i_hex) := '8';
                when "1001" => hexstr(i_hex) := '9';
                when "1010" => hexstr(i_hex) := 'A';
                when "1011" => hexstr(i_hex) := 'B';
                when "1100" => hexstr(i_hex) := 'C';
                when "1101" => hexstr(i_hex) := 'D';
                when "1110" => hexstr(i_hex) := 'E';
                when "1111" => hexstr(i_hex) := 'F';
                when others => hexstr(i_hex) := 'X';
            end case;
            
            i_hex := i_hex + 1;
        end loop;
        
        return hexstr;
    end function slv_to_hex;
    
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
		
		variable insCount: integer := 6;
    begin
        -- Load 64 instructions into instr_array
        for i in 0 to 13 loop 											-- change to # of actual instructions given !!!!!!
            readline(instr_file, line_var);
            read(line_var, temp25);
            instr_array_sig(i) <= temp25;
        end loop;
    
        -- Load 64 expected results	 
        for i in 0 to 27 loop				-- 27 because first 3 used for reg inputs
        	readline(expected_file, line_var);
        	read(line_var, hexstr);
        	expected_outputs(i) <= hex_to_slv(hexstr, 128);
        end loop;
        
        wait;
    end process;		
    
    -- Stimulus
    stim_proc : process
        variable index : integer := 0;
        variable cycle_count : integer := 0;
		
		variable outline : line;
		variable hexstr : string(1 to 32);
		variable hexstr2 : string(1 to 32);
		
		type reg_array_t is array (0 to 31) of std_logic_vector(127 downto 0);
    	variable reg_file : reg_array_t := (others => (others => '0')); 
    begin
        -- Apply reset
        reset <= '1';
        wait for 2 * clk_period;
        reset <= '0';
        wait for clk_period;
    
        -- Run for total cycles = instructions + latency
        for cycle_count in 0 to 63 loop
            wait for clk_period;  
			
			index := to_integer(unsigned(<<signal uut.wb_rd_addr : std_logic_vector>>));
			reg_file(index) := <<signal uut.wb_rd_data : std_logic_vector>>;  
			
        end loop;
    
        
        done <= true;
        wait for clk_period;
		
		for index in 3 to 27 loop
			hexstr := slv_to_hex(reg_file(index));
			hexstr2 := slv_to_hex(expected_outputs(index));	
			
			if reg_file(index) = expected_outputs(index) then 
				write(outline, string'("[Correct] Register: "));
			    write(outline, index);
				write(outline, string'(" Match Data: "));
			    write(outline, hexstr);
				write(outline, string'(" Expected Data: "));
			    write(outline, hexstr2);
			    writeline(comp_file, outline);
			else
				write(outline, string'("[Wrong] Miss Match Register: "));
			    write(outline, index);
				write(outline, string'(" Miss Match Data: "));
			    write(outline, hexstr);
				write(outline, string'(" Expected Data: "));
			    write(outline, hexstr2);
			    writeline(comp_file, outline);
			end if;
		end loop;
		
		std.env.finish;
    end process;
	

    -- Internal signal monitoring and debug file writing process
    debug_process: process
	variable outline : line; 
	variable L : line;
    begin
        -- Write header to the debug file
        write(outline, string'("Pipeline Internal Signals Debug Log"));
        writeline(signal_debug_file, outline);
        write(outline, string'("======================================================================================="));
        writeline(signal_debug_file, outline);
        
        wait until reset = '0';  -- Wait until reset is released
		
		-- when we print the cycle debug log, the pipeline_data_out value is written in the next cycle
		--eg: the first value is printed on cycle 4, because on cycle 3 its transitioning from undefined to the first value.
        -- Monitor cycles
        for cycle_count in 0 to 63 loop
            wait until rising_edge(clk);
            
            -- Write cycle number
            write(outline, string'("Cycle: "));
            write(outline, cycle_count);
            writeline(signal_debug_file, outline);	 
			
			write(outline, string'("---------------Output of Instr Buff----------------"));
        	writeline(signal_debug_file, outline);	 
            
            -- PC/IF Stage signals
            write(outline, string'("Fetched Instruction: "));
            hwrite(outline, <<signal uut.fetched_instr : std_logic_vector>>);
            writeline(signal_debug_file, outline);	 
			
			write(outline, string'("---------------Output of IF/ID Pipeline Reg----------------"));
        	writeline(signal_debug_file, outline);
            
            -- ID Stage signals
            write(outline, string'("Decoded Instruction: "));
            hwrite(outline, <<signal uut.decoded_instr : std_logic_vector>>);
            writeline(signal_debug_file, outline);
			

			write(outline, string'("---------------Input of Reg File----------------"));
        	writeline(signal_debug_file, outline);

			
            -- Register File Outputs
            write(outline, string'("RegFile Instruction: "));
            hwrite(outline, <<signal uut.regfile_instr_in : std_logic_vector>>);
            writeline(signal_debug_file, outline); 
			
			write(outline, string'("---------------Output of Reg File----------------"));
        	writeline(signal_debug_file, outline);
            
            write(outline, string'("RS1 Data: "));
            hwrite(outline, <<signal uut.regfile_rs1_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("RS2 Data: "));
            hwrite(outline, <<signal uut.regfile_rs2_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("RS3 Data: "));
            hwrite(outline, <<signal uut.regfile_rs3_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
			
			write(outline, string'("---------------Output of ID/EX Pipeline Reg----------------"));
        	writeline(signal_debug_file, outline);
            -- ID/EX Register Outputs
            write(outline, string'("ID/EX Instruction: "));
            hwrite(outline, <<signal uut.id_ex_instr : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("ID/EX RS1 Data: "));
            hwrite(outline, <<signal uut.id_ex_rs1_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("ID/EX RS2 Data: "));
            hwrite(outline, <<signal uut.id_ex_rs2_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("ID/EX RS3 Data: "));
            hwrite(outline, <<signal uut.id_ex_rs3_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
			
			write(outline, string'("---------------Output of Forwarding Unit----------------"));
        	writeline(signal_debug_file, outline);
            -- Forwarding Unit Outputs
            write(outline, string'("Forwarded Instruction: "));
            hwrite(outline, <<signal uut.forwarded_instr : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("Forwarded RS1 Data: "));
            hwrite(outline, <<signal uut.forwarded_rs1_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("Forwarded RS2 Data: "));
            hwrite(outline, <<signal uut.forwarded_rs2_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("Forwarded RS3 Data: "));
            hwrite(outline, <<signal uut.forwarded_rs3_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);	
			
			write(outline, string'("Forwarded RD Data for load: "));
            hwrite(outline, <<signal uut.forwarded_rd_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);	
			
			write(outline, string'("---------------Output of ALU----------------"));
        	writeline(signal_debug_file, outline);
            -- ALU Outputs
            write(outline, string'("ALU RegWrite: "));
            write(outline, <<signal uut.alu_regwrite : std_logic>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("ALU RD Address: "));
            hwrite(outline, <<signal uut.alu_rd_addr : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("ALU Result: "));
            hwrite(outline, <<signal uut.alu_result : std_logic_vector>>);
            writeline(signal_debug_file, outline);
			
			write(outline, string'("---------------Output of EX/WB Pipeline Reg----------------"));
        	writeline(signal_debug_file, outline);
            -- WB Stage signals
            write(outline, string'("WB RegWrite: "));
            write(outline, <<signal uut.wb_regwrite : std_logic>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("WB RD Address: "));
            hwrite(outline, <<signal uut.wb_rd_addr : std_logic_vector>>);
            writeline(signal_debug_file, outline);
            
            write(outline, string'("WB RD Data: "));
            hwrite(outline, <<signal uut.wb_rd_data : std_logic_vector>>);
            writeline(signal_debug_file, outline);
			
            -- Pipeline output
            write(outline, string'("Pipeline Output: "));
            hwrite(outline, pipeline_data_out);
            writeline(signal_debug_file, outline);
            
            -- Add a separator between cycles
            write(outline, string'("---------------------------------------"));
            writeline(signal_debug_file, outline);	  
			writeline(signal_debug_file, L);  -- L is empty, so this creates a blank line
			writeline(signal_debug_file, L);  -- L is empty, so this creates a blank line
			writeline(signal_debug_file, L);  -- L is empty, so this creates a blank line
			writeline(signal_debug_file, L);  -- L is empty, so this creates a blank line
        end loop;
        
        wait;
    end process;
    
end behavior;