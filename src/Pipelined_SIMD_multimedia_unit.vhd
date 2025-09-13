-------------------------------------------------------------------------------
--
-- Title       : Pipelined_SIMD_multimedia_unit
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : John Abraham
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/Pipelined_SIMD_multimedia_unit.vhd
-- Generated   : Fri Apr 18 00:22:07 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Top level entity connecting all the components of the pipeline together.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.all;
use work.instr_array.all;
use IEEE.numeric_std.all;

entity Pipelined_SIMD_multimedia_unit is
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		instr_array : in instr_array; 
		pipeline_data_out : out std_logic_vector(127 downto 0)
	);
end Pipelined_SIMD_multimedia_unit;

architecture structural of Pipelined_SIMD_multimedia_unit is

	-- PC and Instruction Fetch
	--signal pc : unsigned(5 downto 0);	 
	signal fetched_instr : std_logic_vector(24 downto 0); 
	signal decoded_instr : std_logic_vector(24 downto 0); 

	-- Register File Outputs
	signal regfile_instr_in : std_logic_vector(24 downto 0);
	signal regfile_rs1_data : std_logic_vector(127 downto 0);
	signal regfile_rs2_data : std_logic_vector(127 downto 0);
	signal regfile_rs3_data : std_logic_vector(127 downto 0);
	signal regfile_rd_as_source_data : std_logic_vector(127 downto 0);
	
	signal regfile_rs1_addr : std_logic_vector(4 downto 0);
	signal regfile_rs2_addr : std_logic_vector(4 downto 0);
	signal regfile_rs3_addr : std_logic_vector(4 downto 0);

	-- ID/EX Register Outputs
	signal id_ex_instr : std_logic_vector(24 downto 0);
	signal id_ex_rs1_data : std_logic_vector(127 downto 0);
	signal id_ex_rs2_data : std_logic_vector(127 downto 0);
	signal id_ex_rs3_data : std_logic_vector(127 downto 0);
	signal id_ex_rs1_addr : std_logic_vector(4 downto 0);
	signal id_ex_rs2_addr : std_logic_vector(4 downto 0);
	signal id_ex_rs3_addr : std_logic_vector(4 downto 0);
	signal ID_EX_rd_as_source_data : std_logic_vector(127 downto 0);

	-- Forwarding Unit Outputs
	signal forwarded_instr : std_logic_vector(24 downto 0);
	signal forwarded_rs1_data : std_logic_vector(127 downto 0);
	signal forwarded_rs2_data : std_logic_vector(127 downto 0);
	signal forwarded_rs3_data : std_logic_vector(127 downto 0);
	signal forwarded_rd_data : std_logic_vector(127 downto 0);

	-- ALU Outputs
	signal alu_regwrite : std_logic;
	signal alu_rd_addr : std_logic_vector(4 downto 0);
	signal alu_result : std_logic_vector(127 downto 0);

	-- EX/WB Register Outputs
	signal wb_regwrite : std_logic;
	signal wb_rd_addr : std_logic_vector(4 downto 0);
	signal wb_rd_data : std_logic_vector(127 downto 0);	
	
	signal forward : std_logic;

begin

	--u1: entity PC port map(clk => clk, reset => reset, PC => pc);

	--u2: entity instr_buff port map(clk=>clk, reset=> reset, PC => pc, instr_array => instr_array, instr_out => fetched_instr);
	u1: entity work.PC_with_instr_buff port map(clk => clk, reset => reset, instr_array => instr_array, instr_out => fetched_instr);

	u3: entity IF_ID_reg port map(clk => clk, instr_in => fetched_instr, instr_out => decoded_instr);

	u4: entity Register_File
		port map( 
			reset=> reset,
			clk => clk,
			instr_in => decoded_instr,
			write_reg_addr => wb_rd_addr,
			write_data => wb_rd_data,
			RegWrite => wb_regwrite,
			instr_out => regfile_instr_in,
			read_data_rs1 => regfile_rs1_data,
			read_data_rs2 => regfile_rs2_data,
			read_data_rs3 => regfile_rs3_data,
			rs1_addr => regfile_rs1_addr,
			rs2_addr => regfile_rs2_addr,
			rs3_addr => regfile_rs3_addr,
			read_rd_as_source => regfile_rd_as_source_data
		);

	u5: entity ID_EX_reg
		port map(
			clk => clk,
			instr_in => regfile_instr_in,
			rs1_in => regfile_rs1_data,
			rs2_in => regfile_rs2_data,
			rs3_in => regfile_rs3_data,
			rs1_addr_in => regfile_rs1_addr,
			rs2_addr_in => regfile_rs2_addr,
			rs3_addr_in => regfile_rs3_addr, 
			rd_as_source => regfile_rd_as_source_data,
			instr_out => id_ex_instr,
			rs1_out => id_ex_rs1_data,
			rs2_out => id_ex_rs2_data,
			rs3_out => id_ex_rs3_data,
			rs1_addr_out => id_ex_rs1_addr,
			rs2_addr_out => id_ex_rs2_addr,
			rs3_addr_out => id_ex_rs3_addr,
			rd_as_source_out => ID_EX_rd_as_source_data
		);

	u6: entity Forwarding_unit
		port map(
			EX_WB_RegWrite => wb_regwrite,
			EX_WB_rd_data => wb_rd_data,
			EX_WB_rd_addr => wb_rd_addr,
			ID_EX_instr => id_ex_instr,
			ID_EX_rs1 => id_ex_rs1_data,
			ID_EX_rs2 => id_ex_rs2_data,
			ID_EX_rs3 => id_ex_rs3_data,
			ID_EX_rs1_addr => id_ex_rs1_addr,
			ID_EX_rs2_addr => id_ex_rs2_addr,
			ID_EX_rs3_addr => id_ex_rs3_addr,
			instr_out => forwarded_instr,
			rs1_out => forwarded_rs1_data,
			rs2_out => forwarded_rs2_data,
			rs3_out => forwarded_rs3_data,
			rd_out => forwarded_rd_data,
			forward => forward
		);

	u7: entity multimedia_ALU
		port map(
			rs1 => forwarded_rs1_data,
			rs2 => forwarded_rs2_data,
			rs3 => forwarded_rs3_data,
			instr => forwarded_instr,
			RegWrite => alu_regwrite,
			rd_addr => alu_rd_addr,
			rd => alu_result, 
			rd_in => forwarded_rd_data,
			forward => forward,
			rd_as_source => ID_EX_rd_as_source_data
		);

	u8: entity EX_WB_reg
		port map(
			clk => clk,
			RegWrite => alu_regwrite,
			rd_addr => alu_rd_addr,
			rd_data => alu_result,
			RegWrite_out => wb_regwrite,
			rd_addr_out => wb_rd_addr,
			rd_data_out => wb_rd_data
		);

	pipeline_data_out <= wb_rd_data;

end structural;
																			
																									
																									
																									
																									