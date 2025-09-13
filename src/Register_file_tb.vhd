library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_File_tb is
end entity;

architecture tb of Register_File_tb is

    -- Testbench signals
    signal clk            : std_logic := '0'; 
	signal loadImmEn      : std_logic := '0';
	signal reset          : std_logic := '0';
    signal instr_in       : std_logic_vector(24 downto 0) := (others => '0');
    signal write_reg_addr : std_logic_vector(4 downto 0) := (others => '0');
    signal write_data     : std_logic_vector(127 downto 0) := (others => '0');
    signal RegWrite       : std_logic := '0';
    signal instr_out      : std_logic_vector(24 downto 0);
    signal read_data_rs1  : std_logic_vector(127 downto 0);
    signal read_data_rs2  : std_logic_vector(127 downto 0);
    signal read_data_rs3  : std_logic_vector(127 downto 0);
    signal rs1_addr       : std_logic_vector(4 downto 0);
    signal rs2_addr       : std_logic_vector(4 downto 0);
    signal rs3_addr       : std_logic_vector(4 downto 0);

    constant clk_period   : time := 10 ns;
    constant test_val     : std_logic_vector(127 downto 0) := x"DEADBEEFCAFEBABE1234567890ABCDEF";

begin

    -- Instantiate DUT directly (no component block needed in VHDL-2008)
    uut: entity work.Register_File
        port map (
			clk            => clk,
			reset 		   => reset,
            instr_in       => instr_in,
            write_reg_addr => write_reg_addr,
            write_data     => write_data,
            RegWrite       => RegWrite,
            instr_out      => instr_out,
            read_data_rs1  => read_data_rs1,
            read_data_rs2  => read_data_rs2,
            read_data_rs3  => read_data_rs3,
            rs1_addr       => rs1_addr,
            rs2_addr       => rs2_addr,
            rs3_addr       => rs3_addr
        );

    -- Clock generator
    clk_process : process
    begin
        while now < 200 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus
    stim_proc : process
    begin
        wait for clk_period;

        -- Write to reg[1]
        write_reg_addr <= "00001";
        write_data     <= test_val;
        RegWrite       <= '1';
        wait for clk_period;

        -- Disable write
        RegWrite <= '0';

       -- rs3 = 00000, rs2 = 00000, rs1 = 00001
		instr_in <= "00000" & "00000" & "00001" & "00000" & "00000";	


        wait for clk_period;

        -- Check
        assert read_data_rs1 = test_val
            report "? ERROR: read_data_rs1 does not match written value!" severity error;
        report "? SUCCESS: read_data_rs1 matches written value!" severity note;

        wait;
    end process;

end architecture;
