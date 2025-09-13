-------------------------------------------------------------------------------
--
-- Title       : multimedia_ALU
-- Design      : Pipelined_SIMD_multimedia_unit
-- Author      : john
-- Company     : stony brook university
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/jobif/OneDrive/Documents/John College/ese 345/345_proj/src/multimedia_ALU_funcs.vhd
-- Generated   : Wed Mar 19 20:13:02 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

entity multimedia_ALU is
	port(
		rs1 : in std_logic_vector(127 downto 0);
		rs2 : in std_logic_vector(127 downto 0);	 
		rs3 : in std_logic_vector(127 downto 0); 
		instr : in std_logic_vector(24 downto 0); 
		rd_in: in std_logic_vector(127 downto 0); --forwarded data for load if rd is read before its written.
		rd_as_source: in std_logic_vector(127 downto 0);
		forward : in std_logic;
		RegWrite : out std_logic;
		rd_addr: out std_logic_vector(4 downto 0);
		rd : out std_logic_vector(127 downto 0) 		--data to be sent to Reg file.
		
	); 		
	constant MAX_16BIT : signed(15 downto 0) := X"7FFF";
	constant MIN_16BIT : signed(15 downto 0) := X"8000";
	constant MAX_32BIT : signed(31 downto 0) := X"7FFFFFFF"; 
	constant MIN_32BIT : signed(31 downto 0) := X"80000000"; 
	constant MAX_64BIT : signed(63 downto 0) := X"7FFFFFFFFFFFFFFF";
	constant MIN_64BIT : signed(63 downto 0) := X"8000000000000000";

end multimedia_ALU;


architecture behavioral of multimedia_ALU is	 
begin
	process(instr)	 
	variable instr_unsigned : unsigned(24 downto 0);
	
	variable rs1_unsigned : unsigned(127 downto 0); 
	variable rs2_unsigned : unsigned(127 downto 0);
	variable rs3_unsigned : unsigned(127 downto 0);
	variable rd_unsigned : unsigned(127 downto 0) ; 	
	
	variable rs1_signed : signed(127 downto 0); 
	variable rs2_signed : signed(127 downto 0);
	variable rs3_signed : signed(127 downto 0);
	variable rd_signed : signed(127 downto 0);	 
	
	--holds the product values for R4 instr.
	variable temp1 : signed(32 downto 0);	   --33 bits because we need to check overflow
	variable temp2 : signed(64 downto 0);	   --65 bits because we need to check overflow
	variable temp3 : signed(16 downto 0);	   --17 bits because we need to check overflow 
	
	--temporary variables for some R3 instr
	variable temp4 : signed(31 downto 0);	
	variable temp5 : unsigned(31 downto 0);	   
	
	variable tmp :  std_logic_vector(15 downto 0); 
	 
	variable shift : integer;	   
	variable count : integer;
	variable temp_int : integer;

	variable index : unsigned(2 downto 0);
	variable startVal : integer;
	variable endVal : integer;	
	
	variable mult_temp : signed(31 downto 0); --for storing the products of R3 instr: 000,001,010,011
	variable mult_temp1 : signed(63 downto 0); --for storing the products of R3 instr: 100,101,110,111
	 
	function sanitize(slv : std_logic_vector) return std_logic_vector is
	    variable result : std_logic_vector(slv'range) := slv;
	begin
	    for i in slv'range loop
	        if slv(i) = 'U' then
	            result := (others => '0');
	            return result;
	        end if;
	    end loop;
	    return result;
	end function;

	begin		   
		rs1_unsigned := unsigned(sanitize(rs1));	  --if rs1 is undefined, set it to 0.
        rs2_unsigned := unsigned(sanitize(rs2));
        rs3_unsigned := unsigned(sanitize(rs3));
        rs1_signed := signed(sanitize(rs1));
        rs2_signed := signed(sanitize(rs2));
        rs3_signed := signed(sanitize(rs3));
		instr_unsigned := unsigned(instr);	
		
		rd_addr <= instr(4 downto 0);
		
		--we only initialize rd for testing purposes of the LOAD and NOP instr. we HAVE to REMOVE this instr when we combine other parts of the project.
			
		

		if instr(24) = '0' then  --code for load immediate instr, doesn't change any other bits than indicated by load index  
			
			index := instr_unsigned(23 downto 21); 	
			startVal :=	 16 * to_integer(index) + 15;																											 
			endVal := 16 * to_integer(index);
			
			--rd  <= X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
			--rd  <= X"00000000000000000000000000000000";
			rd <= rd_as_source;
			
			if forward ='1' then
				rd <= rd_in; 
			end if;
			
			tmp := std_logic_vector(instr_unsigned(20 downto 5));
			rd(startVal downto endVal) <= tmp;
			RegWrite <= '1'; 
			
				
		else
			if instr(23) = '0' then				   --SIMALS
				case instr(22 downto 20) is
					when "000" =>	 
						for i in 0 to 3 loop --in each 32-bit field, find product of LOW 16-bits b/w rs3 and rs2. Add the product to 32-bit field of rs1
					        mult_temp := signed(rs3_signed((i*32+15) downto (i*32))) * signed(rs2_signed((i*32+15) downto (i*32)));
							temp1 := resize(signed(mult_temp),33) + resize(signed(rs1_signed((i*32+31) downto (i*32))), 33); 
							
							-- Apply saturation logic
						    if temp1 > MAX_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MAX_32BIT;
						    elsif temp1 < MIN_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MIN_32BIT;
						    else
						        rd_signed((i*32+31) downto (i*32)) := temp1(31 downto 0);
						    end if;
					    end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
					
					when "001" => 	  --in each 32-bit field, find product of HIGH 16-bits b/w rs3 and rs2. Add the product to 32-bit field of rs1
						for i in 0 to 3 loop
					        mult_temp := signed(rs3_signed((i*32+31) downto (i*32+16))) * signed(rs2_signed((i*32+31) downto (i*32+16)));
					        temp1 := resize(signed(mult_temp),33) + resize(signed(rs1_signed((i*32+31) downto (i*32))), 33); 
							
							-- Apply saturation logic
						    if temp1 > MAX_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MAX_32BIT;
						    elsif temp1 < MIN_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MIN_32BIT;
						    else
						        rd_signed((i*32+31) downto (i*32)) := temp1(31 downto 0);
						    end if;
					    end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
					
					when "010" =>	   --in each 32-bit field, find product of LOW 16-bits b/w rs3 and rs2. Subtract the product from each 32-bit field of rs1
						for i in 0 to 3 loop
					        mult_temp := signed(rs3_signed((i*32+15) downto (i*32))) * signed(rs2_signed((i*32+15) downto (i*32)));
					        temp1 := resize(signed(rs1_signed((i*32+31) downto (i*32))), 33) - resize(signed(mult_temp),33);	 
							
							-- Apply saturation logic
						    if temp1 > MAX_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MAX_32BIT;
						    elsif temp1 < MIN_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MIN_32BIT;
						    else
						        rd_signed((i*32+31) downto (i*32)) := temp1(31 downto 0);
						    end if;
					    end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
					
					when "011" =>		--in each 32-bit field, find product of HIGH 16-bits b/w rs3 and rs2. Subtract the product from each 32-bit field of rs1
						for i in 0 to 3 loop
					        mult_temp := signed(rs3_signed((i*32+31) downto (i*32+16))) * signed(rs2_signed((i*32+31) downto (i*32+16)));
					        temp1 := resize(signed(rs1_signed((i*32+31) downto (i*32))),33) - resize(signed(mult_temp),33);
							
							-- Apply saturation logic
						    if temp1 > MAX_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MAX_32BIT;
						    elsif temp1 < MIN_32BIT then
						        rd_signed((i*32+31) downto (i*32)) := MIN_32BIT;
						    else
						        rd_signed((i*32+31) downto (i*32)) := temp1(31 downto 0);
						    end if;
					    end loop;  
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
						
					when "100" =>	
						for i in 0 to 1 loop
					        mult_temp1 := signed(rs3_signed((i*64+31) downto (i*64))) * signed(rs2_signed((i*64+31) downto (i*64)));
					        temp2 := resize(signed(mult_temp1), 65) + resize(signed(rs1_signed((i*64+63) downto (i*64))), 65); 
							
							-- Apply saturation logic
						    if temp2 > MAX_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MAX_64BIT;
						    elsif temp2 < MIN_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MIN_64BIT;
						    else
						        rd_signed((i*64+63) downto (i*64)) := temp2(63 downto 0);
						    end if;
					    end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
						
					when "101" =>
						for i in 0 to 1 loop
					        mult_temp1 := signed(rs3_signed((i*64+63) downto (i*64+32))) * signed(rs2_signed((i*64+63) downto (i*64+32)));
					        temp2 := resize(signed(mult_temp1), 65) + resize(signed(rs1_signed((i*64+63) downto (i*64))), 65);
							
							-- Apply saturation logic
						    if temp2 > MAX_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MAX_64BIT;
						    elsif temp2 < MIN_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MIN_64BIT;
						    else
						        rd_signed((i*64+63) downto (i*64)) := temp2(63 downto 0);
						    end if;
					    end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
						
					when "110" => 	 
						for i in 0 to 1 loop
					        mult_temp1 := signed(rs3_signed((i*64+31) downto (i*64))) * signed(rs2_signed((i*64+31) downto (i*64)));
					        temp2 := resize(signed(rs1_signed((i*64+63) downto (i*64))), 65) - resize(signed(mult_temp1), 65);	
							
							-- Apply saturation logic
						    if temp2 > MAX_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MAX_64BIT;
						    elsif temp2 < MIN_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MIN_64BIT;
						    else
						        rd_signed((i*64+63) downto (i*64)) := temp2(63 downto 0);
						    end if;
					    end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
						
					when "111" => 
						for i in 0 to 1 loop
					        mult_temp1 := signed(rs3_signed((i*64+63) downto (i*64+32))) * signed(rs2_signed((i*64+63) downto (i*64+32)));
					        temp2 := resize(signed(rs1_signed((i*64+63) downto (i*64))), 65) - resize(signed(mult_temp1), 65);	  
							
							-- Apply saturation logic
						    if temp2 > MAX_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MAX_64BIT;
						    elsif temp2 < MIN_64BIT then
						        rd_signed((i*64+63) downto (i*64)) := MIN_64BIT;
						    else
						        rd_signed((i*64+63) downto (i*64)) := temp2(63 downto 0);
						    end if;
					    end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';  
						
					when others => null;
				end case;  
			else
				case instr(18 downto 15) is
					when "0000" =>			 --NOP
						null; --this is the only case where we dont write back to reg file. 
						RegWrite <= '0'; 
						
					when "0001" =>           --SHRHI   
						shift := to_integer(instr_unsigned(13 downto 10));
					    for i in 0 to 7 loop
					        startVal := 16 * i + 15;    
					        endVal := 16 * i;
					        rd_unsigned(startVal downto endVal) := shift_right(rs1_unsigned(startVal downto endVal), shift);
					    end loop;    
					    rd <= std_logic_vector(rd_unsigned);
					    RegWrite <= '1';
						
					when "0010" =>			 -- AU
						for i in 0 to 3 loop		 --we dont care about the carry
							startVal :=	 32*i+31;	
							endVal := 32*i;
							rd_unsigned(startVal downto endVal) := rs1_unsigned(startVal downto endVal) + rs2_unsigned(startVal downto endVal);
						end loop;
						rd <= std_logic_vector(rd_unsigned);
						RegWrite <= '1';
						
					when "0011" =>			--CNT1W	  
						count:=0;
						for i in 0 to 31 loop
							if rs1_unsigned(i) = '1' then count := count+1;	 
							end if;
						end loop;
						rd_unsigned(31 downto 0) := to_unsigned(count,32);
						
						count:=0;
						for i in 32 to 63 loop
							if rs1_unsigned(i) = '1' then count := count+1;
							end if;
						end loop;
						rd_unsigned(63 downto 32) := to_unsigned(count,32);   
						
						count:=0;
						for i in 64 to 95 loop
							if rs1_unsigned(i) = '1' then count := count+1;
							end if;
						end loop;
						rd_unsigned(95 downto 64) := to_unsigned(count,32); 
						
						count:=0; 
						for i in 96 to 127 loop
							if rs1_unsigned(i) = '1' then count := count+1;
							end if;
						end loop;
						rd_unsigned(127 downto 96) := to_unsigned(count,32);	 
						
						rd <= std_logic_vector(rd_unsigned);
						RegWrite <= '1';
						
					when "0100" =>			--AHS 	   
						for i in 0 to 7 loop
							temp3 := resize(signed(rs2_signed((16*i+15) downto (16*i))), 17) + resize(signed(rs1_signed((16*i+15) downto (16*i))), 17);
							
							-- Apply saturation logic
						    if temp3 > MAX_16BIT then
						        rd_signed((16*i+15) downto (16*i)) := MAX_16BIT;
						    elsif temp3 < MIN_16BIT then
						        rd_signed((16*i+15) downto (16*i)) := MIN_16BIT;
						    else
						        rd_signed((16*i+15) downto (16*i)) := temp3(15 downto 0);
						    end if;
						end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
						
					when "0101" =>			--NOR
						rd <= rs1 nor rs2;
						RegWrite <= '1';
						
					when "0110" =>			--BCW
						temp5 := rs1_unsigned(31 downto 0) ;
						for i in 0 to 3 loop
							rd_unsigned((32*i+31) downto (32*i)) := temp5;
						end loop;
						rd <= std_logic_vector(rd_unsigned); 
						RegWrite <= '1';
						
					when "0111" =>			--MAXWS	    
					for i in 0 to 3 loop 
						  	startVal :=	 32*i+31;	
							endVal := 32*i; 
							
							if (rs1_signed(startVal downto endVal) >= rs2_signed(startVal downto endVal) ) then	
								rd_signed(startVal downto endVal) := rs1_signed(startVal downto endVal);
							else 
								rd_signed(startVal downto endVal) := rs2_signed(startVal downto endVal); 
							end if;					
						end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
					
					when "1000" =>			--MINWS
						for i in 0 to 3 loop
							startVal :=	 32*i+31;	
							endVal := 32*i;
							if (rs1_signed(startVal downto endVal) <= rs2_signed(startVal downto endVal) ) then	
								rd_signed(startVal downto endVal) := rs1_signed(startVal downto endVal);
							else 
								rd_signed(startVal downto endVal) := rs2_signed(startVal downto endVal);  
							end if;					
						end loop;
						rd <= std_logic_vector(rd_signed);  
						RegWrite <= '1';
						
					when "1001" =>			--MLHU
					for i in 0 to 3 loop  
					        temp5 := rs1_unsigned((i*32+15) downto (i*32)) * rs2_unsigned((i*32+15) downto (i*32));
							rd_unsigned((i*32+31) downto (i*32)) := temp5;
					    end loop;
						rd <= std_logic_vector(rd_unsigned); 
						RegWrite <= '1';
						
					when "1010" =>			--MLHCU
						for i in 0 to 3 loop
					        temp5 := rs1_unsigned((i*32+15) downto (i*32)) * resize(instr_unsigned(14 downto 10),16);
							rd_unsigned((i*32+31) downto (i*32)) := temp5;
					    end loop;
						rd <= std_logic_vector(rd_unsigned); 
						RegWrite <= '1';
						
					when "1011" =>			--AND
					rd <= rs1 and rs2;
					RegWrite <= '1';
					
					when "1100" =>			--CLZH
						for i in 0 to 7 loop
							temp_int := 16*i+15;  
							count := 0;
							while temp_int >= 0 loop   
								if rs1_unsigned(temp_int) = '1' then exit; 
								end if;
								count := count + 1;
								temp_int := temp_int - 1;  
							end loop;  
							rd_unsigned((16*i+15) downto (16*i)) := to_unsigned(count,16);
						end loop;
						rd <= std_logic_vector(rd_unsigned); 
						RegWrite <= '1';
						
					when "1101" =>			--ROTW
						for i in 0 to 3 loop
							temp_int := to_integer(rs2_unsigned((32*i+4) downto 32*i));
							--use concatenation. concatenation works only on signals.	
							rd((32*i+31) downto 32*i) <= rs1((32*i+temp_int-1) downto (32*i)) & rs1((32*i+31) downto (32*i+temp_int));
						end loop; 
						RegWrite <= '1';
						
					when "1110" =>			--SFWU
						for i in 0 to 3 loop
							rd_unsigned((32*i+31) downto (32*i)) := rs2_unsigned((32*i+31) downto (32*i)) - rs1_unsigned((32*i+31) downto (32*i));
						end loop; 
						rd <= std_logic_vector(rd_unsigned);  
						RegWrite <= '1';
					
					when "1111" =>			--SFHS
						for i in 0 to 7 loop
							temp3 := resize(signed(rs2_signed((16*i+15) downto (16*i))), 17) - resize(signed(rs1_signed((16*i+15) downto (16*i))), 17);
							
							-- Apply saturation logic
						    if temp3 > MAX_16BIT then
						        rd_signed((16*i+15) downto (16*i)) := MAX_16BIT;
								count := 1;
						    elsif temp3 < MIN_16BIT then
						        rd_signed((16*i+15) downto (16*i)) := MIN_16BIT;
								count := 2;
						    else
						        rd_signed((16*i+15) downto (16*i)) := temp3(15 downto 0);
								count := 3;
						    end if;
							
						end loop;
						rd <= std_logic_vector(rd_signed);
						RegWrite <= '1';
						
					
				    when others =>  null; 
				end case;
			end if;
		end if;	
	end process;
	

end behavioral;