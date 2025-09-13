library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library Pipelined_SIMD_multimedia_unit;
use Pipelined_SIMD_multimedia_unit.all;

entity multimedia_ALU_tb is
end multimedia_ALU_tb;

architecture behavior of multimedia_ALU_tb is

    signal rs1_tb  : std_logic_vector(127 downto 0);
    signal rs2_tb  : std_logic_vector(127 downto 0);	 
    signal rs3_tb  : std_logic_vector(127 downto 0); 
    signal instr_tb : std_logic_vector(24 downto 0);
    signal rd_tb   : std_logic_vector(127 downto 0);
	signal rd_in:  std_logic_vector(127 downto 0); --forwarded data for load if rd is read before its written.
	signal forward :  std_logic;

begin		   
   
    uut : entity multimedia_ALU
    port map (
        rs1   => rs1_tb,
        rs2   => rs2_tb,
        rs3   => rs3_tb,
        instr => instr_tb,
        rd    => rd_tb, 
		rd_in => rd_in, 
		forward => forward
    );	   
	
	
		rs3_tb <= X"00000000000000020000000000007fff";
		rs2_tb <= X"0000000080000000acbdadcd00000004";
		rs1_tb <= X"00000000abcd1110000000007fffffff";   
		
	
    sendData: process	 
		
    begin	 
--		--load_immediate
	      instr_tb <= "0001000000000000000100000";  -- 0 001 0000 0000 0000 0001 00000 
	    	wait for 20 ns;  
	    	assert (rd_tb = X"00000000000000000000000000010000")
	    report "Load Immediate instruction wrong"
	    	severity error;
--	
--	--R4 INSTRUCTIONS
--	
--		--SIMALS
--		instr_tb <= "1000000000000000000000000";   
--	    wait for 20 ns;  
--	    assert (rd_tb = X"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF")
--	    report "SIMALS instruction wrong"
--	    severity error;
--				
--		--SIMAHS
--		instr_tb <= "1000100000000000000000000";   
--	    wait for 20 ns;  
--	    assert (rd_tb = X"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF")
--	    report "SIMAHS instruction wrong"
--	    severity error;	
--		
--		--SIMSLS
--		instr_tb <= "1001000000000000000000000";   
--	    wait for 20 ns;  
--	    assert (rd_tb = X"4000FFFE4000FFFE4000FFFE4000FFFE")
--	    report "SIMSLS instruction wrong"
--	    severity error;	
--		
--		--SIMSHS
--		instr_tb <= "1001100000000000000000000";   
--	    wait for 20 ns;  
--	    assert (rd_tb = X"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF")
--	    report "SIMSLS instruction wrong"
--	    severity error;
--		
--		--SIMSLS
--		instr_tb <= "1010000000000000000000000";   
--	    wait for 20 ns;  
--	    assert (rd_tb = X"7FFFFFFFBFFF00007FFFFFFFBFFF0000")
--	    report "SIMSLS instruction wrong"
--	    severity error;	
--	
--		--SLIMALS
--	  	instr_tb <= "1010100000000000000000000";   
--        wait for 20 ns;  
--        assert (rd_tb = X"7FFFFFFFBFFF00007FFFFFFFBFFF0000")
--        report "SLIMALS instruction wrong"
--        severity error;
--	
--		--SLIMAHS
--		instr_tb <= "1011000000000000000000000";   
--        wait for 20 ns;  
--        assert (rd_tb = X"7FFFFFFF4000FFFE7FFFFFFF4000FFFE")
--        report "SLIMAHS instruction wrong"
--        severity error;
--		
--		--SLIMSLS
--		instr_tb <= "1011100000000000000000000";   
--	    wait for 20 ns;  
--	    assert (rd_tb = X"7FFFFFFF4000FFFE7FFFFFFF4000FFFE")
--	    report "SLIMSLS instruction wrong"
--	    severity error;
--
--		
--	--R3 INSTRUCTIONS
--	
--		--NOP  
--		instr_tb <= "1111100000000000000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"00000000000000000000000000000000")  
--    	report "NOP instruction wrong"
--    	severity error;
--		
--		--SHRHI  
--		instr_tb <= "1100000001011110000000000";
--		wait for 20 ns;										 
--		assert (rd_tb = X"00000001000000010000000100000001")  
--    	report "SHRHI instruction wrong"
--    	severity error;	
--	
--	--AU  
--		instr_tb <= "1100000010000000000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"80007FFE80007FFE80007FFE80007FFE")  
--    	report "AU instruction wrong"
--    	severity error;	
	
	--CNT1W  
		instr_tb <= "1100000011000000000000000";
		wait for 20 ns;
		assert (rd_tb = X"0000001F0000001F0000001F0000001F")  
    	report "CNT1W instruction wrong"
    	severity error;

--	--AHS 
--		instr_tb <= "1100000100000000000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"7FFF7FFE7FFF7FFE7FFF7FFE7FFF7FFE")  
--    	report "AHS instruction wrong"
--    	severity error;	
--
--	--NOR
--		instr_tb <= "1100000101000000000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"80000000800000008000000080000000")  
--    	report "NOR instruction wrong"
--    	severity error;
--
	--BCW
		instr_tb <= "1100000110000000000000000";
		wait for 20 ns;
		assert (rd_tb = X"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF")  
	  	report "BCW instruction wrong"
	  	severity error;	  
--
--	--MAXWS
--		instr_tb <= "1100000111000000000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF")  
--    	report "MAXWS instruction wrong"
--    	severity error;
----
--	--MINWS
		instr_tb <= "1100001000000000000000000";
		wait for 20 ns;
		assert (rd_tb = X"00007FFF00007FFF00007FFF00007FFF")  
    	report "MINWS instruction wrong"
    	severity error;	
--	
--	--MLHU
--		instr_tb <= "1100001001000000000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"7FFE80017FFE80017FFE80017FFE8001")  
--    	report "MLHU instruction wrong"
--    	severity error;
--	
--	--MLHCU
--		instr_tb <= "1100001010000010000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"0000FFFF0000FFFF0000FFFF0000FFFF")  
--    	report "MLHCU instruction wrong"
--    	severity error;	   
--
--	--AND
--		instr_tb <= "1100001011000000000000000";
--		wait for 20 ns;
--		assert (rd_tb = X"00007FFF00007FFF00007FFF00007FFF")  
--	  	report "And instruction wrong"
--	  	severity error;	 
--
	--CLZH
		instr_tb <= "1100001100000000000000000";
		wait for 20 ns;
		assert (rd_tb = X"00010000000100000001000000010000")  
    	report "CLZH instruction wrong"
    	severity error;
	
   	--ROTW
		instr_tb <= "1100001101000000000000000";
		wait for 20 ns;
		assert (rd_tb = X"FFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFE")  
    	report "ROTW instruction wrong"
    	severity error;
	
	--SFWU
		instr_tb <= "1100001110000000000000000";
		wait for 20 ns;
		assert (rd_tb = X"80008000800080008000800080008000")  
    	report "SFWU instruction wrong"
    	severity error;	 
	
	--SFHS
		instr_tb <= "1100001111000000000000000";
		wait for 20 ns;
		assert (rd_tb = X"80017FFF80017FFF80017FFF80017FFF")  
    	report "SFHS instruction wrong"
    	severity error;
		

        -- End simulation
        std.env.finish;	
    end process;
    
end;