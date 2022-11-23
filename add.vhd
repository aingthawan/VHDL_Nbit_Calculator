
-- ADDER 
-- M = '0'

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity add is 
generic (N : integer := 5);
port( START,CLK,RST_N : in std_logic ;
		A,B       : in std_logic_vector(N-1 downto 0) ;
		M				 : in std_logic := '0' ;
		R				 : out std_logic_vector(2*N-1 downto 0);
		DONE 			 : out std_logic;
		Operation    : in std_logic_vector(1 downto 0) 
);

end add;



architecture behave of add is


type statetype is (s0,s1);
signal data_A,data_B,data_R : std_logic_vector(2*N-1 downto 0) := (others => '0');
signal state : statetype := s0 ;
signal S_start : std_logic := '0' ;
signal c : STD_LOGIC_VECTOR(2*N downto 0);
signal i : integer := 0;



begin
	S_start <= START ; 
	
	
	
	process (START,CLK,RST_N)
	begin
		
		if RST_N = '0' then --async reset
			-- set data to zero
			data_A <= (others => '0');
			data_B <= (others => '0');
			data_R <= (others => '0');
			R      <= (others => '0');
			c      <= (others => '0');
			i      <= 0;
			DONE   <= '0';
			state  <= s0 ;
			
		elsif rising_edge(CLK) then
			
			case state is
			
			
				when s0 =>
					DONE <= '0';
					
					if ((S_start = '0') and (Operation = "11")) then
						R <= (others => '0');
						c(0) <= M ;
						data_A(N-1 downto 0) <= A ;
						data_B(N-1 downto 0) <= B ;
						state <= s1 ; --Add state
						
					
					end if ;
					
					
				when s1 =>
				
						if i < 2*N+1 then
						

							data_R(i) <= (data_A(i) xor (data_B(i) xor M)) xor c(i);  -- SUB m=1 / ADD m=0
							c(i+1) <= ((data_A(i) xor(data_B(i) xor M)) and c(i)) or (data_A(i) and (data_B(i) xor M));
							

							i <= i + 1 ; 
							
							state <= s1 ;
						
						else 
				
							R <= data_R ; --Result 
							DONE <= '1' ;
							data_A <= (others => '0');
							data_B <= (others => '0');
							data_R <= (others => '0');
							c      <= (others => '0');
							i      <= 0;
							state  <= s0 ;
						
						end if ;
						

				end case ;
			end if ;
		end process ;
end behave ;