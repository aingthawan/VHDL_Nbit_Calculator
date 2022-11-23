 -- =================================================
 
 --  N - Bit Division 
 
 -- if ((A < B) or (B = 0))  ERROR
 
 -- Output is 1000 (DEC)  due to display range of 000 - 999 

 -- =================================================

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;	
use ieee.std_logic_unsigned.all;
use ieee.STD_LOGIC_ARITH.all;

entity division is 
	generic(N : integer := 5);
	port(clock  : in  std_logic;	-- system clock
        reset  : in  std_logic; 	-- synchronous reset, active-high
		  start	: in  std_logic;
		  A,B		: in  std_logic_vector(N-1 downto 0)   := (others => '0');
		  Q		: out std_logic_vector(2*N-1 downto 0) := (others => '0');  -- quotient
		  R		: out std_logic_vector(2*N-1 downto 0) := (others => '0');	-- remainer
		  DONE	: out std_logic;
		  Operation : std_logic_vector(1 downto 0)
		);
end division;

architecture divide of division is
	type state_type is (s0,s1);
	
	signal DATA_divisor	 : std_logic_vector(2*N-1 downto 0) := (others => '0');
	signal DATA_remainder : std_logic_vector(2*N-1 downto 0) := (others => '0');
	signal DATA_quotient  : std_logic_vector(2*N-1 downto 0) := (others => '0');

	signal bit_counter : integer := 0;
	signal state : state_type := s0;
	
	begin
	process(clock,reset,start)
		begin
			if (reset ='0') then
				DONE <= '0';
				DATA_divisor   <= (others => '0');
				DATA_remainder <= (others => '0');
				DATA_quotient  <= (others => '0');
				Q <= (others => '0');
				R <= (others => '0');
				bit_counter <= 0;
				state <= s0;
				
				
			elsif rising_edge(clock) then
				case state is
					when s0 =>
						if ((start ='0') and ( Operation = "00" )) then
							DATA_remainder(N-1 downto 0) <= A;
							DATA_divisor(2*N-1 downto N) <= B;
						
							--if ((A < B) or (B = 0)) then
							if ((B = 0) or (A < B))then
--								bit_counter <= 2*N;
--								DATA_remainder <= conv_std_logic_vector(1000, 2*N);								
--								DATA_quotient  <= conv_std_logic_vector(1000, 2*N);
--								DATA_remainder <= (others => '1');								
--								DATA_quotient  <= (others => '1');								
								
								bit_counter <= N+1;
								DATA_divisor   <= (others => '0');
								DATA_remainder <= (others => '0');
								DATA_quotient  <= (others => '0');

							end if;
						
							state <= s1;
						elsif (start ='0') then 
							Q <= (others => '0');
							R <= (others => '0');
							
						else
							DONE <= '0';
							state <= s0;
						end if;
						
						
					-- ========================================================
					when s1 =>
						if (bit_counter < (N+1)) then
							
							if (DATA_remainder >= DATA_divisor) then
								DATA_remainder <= DATA_remainder-DATA_divisor;
								DATA_quotient  <= DATA_quotient(2*N-2 downto 0) & '1'; -- shift LEFT
							else
								DATA_quotient <= DATA_quotient(2*N-2 downto 0) & '0'; -- shift LEFT
							end if;
							
							DATA_divisor  <= '0' & DATA_divisor(2*N-1 downto 1); -- shift RIGHT
							
							bit_counter   <= bit_counter + 1;
							state <= s1;
						else
							DONE <= '1';
							bit_counter <= 0;
							Q <= DATA_quotient;
							R <= DATA_remainder;
							DATA_divisor <= (others => '0');
							DATA_remainder <= (others => '0');
							DATA_divisor <= (others => '0');
							DATA_quotient <= (others => '0');
							
							state <= s0;
						end if;

					-- ========================================================
						
				end case;
			end if;
	end process;						
end divide;