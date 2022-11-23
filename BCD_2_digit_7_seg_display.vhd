library ieee;
use ieee.std_logic_1164.ALL;
use ieee.STD_LOGIC_ARITH.all;

entity BCD_2_digit_7_seg_display is
		generic(N : integer := 5);
		Port ( 
				 A,B    : in std_logic_vector(N-1 downto 0) ;
				 clk_i  : in  std_logic;	-- system clock
             rst_i  : in  std_logic; 	-- synchronous reset, active-high
				 
				 Done   : in  std_logic;
				 
				 Operation 	: in  STD_LOGIC_VECTOR (1 downto 0);
				 
				 data_add 	: in  STD_LOGIC_VECTOR (2*N-1 downto 0) := (others => '0');
				 data_sub 	: in  STD_LOGIC_VECTOR (2*N-1 downto 0) := (others => '0');
				 data_mul 	: in  STD_LOGIC_VECTOR (2*N-1 downto 0) := (others => '0');
				 data_div 	: in  STD_LOGIC_VECTOR (2*N-1 downto 0) := (others => '0');
				 data_rem 	: in  STD_LOGIC_VECTOR (2*N-1 downto 0) := (others => '0');
				 
				 BCD_digit_1 : out STD_LOGIC_VECTOR (3 downto 0);
				 BCD_digit_2 : out STD_LOGIC_VECTOR (3 downto 0);
				 BCD_digit_3 : out STD_LOGIC_VECTOR (3 downto 0);
				 
				 BCD_digit_4 : out STD_LOGIC_VECTOR (3 downto 0);
				 BCD_digit_5 : out STD_LOGIC_VECTOR (3 downto 0);
				 BCD_digit_6 : out STD_LOGIC_VECTOR (3 downto 0)
		);
					  
end BCD_2_digit_7_seg_display;

architecture Behavioral of BCD_2_digit_7_seg_display is
signal data : STD_LOGIC_VECTOR (2*N-1 downto 0);
signal remain : STD_LOGIC_VECTOR (2*N-1 downto 0);

signal int_data_1 : integer := 0;
signal int_data_2 : integer := 0;
signal int_data_3 : integer := 0;

signal int_data_4 : integer := 0;
signal int_data_5 : integer := 0;
signal int_data_6 : integer := 0;

	begin
		process(clk_i, rst_i, data, Done)
			begin
			
				case Operation is
					-- ++++++++++
					when "11" => 
						data   <= data_add;
						remain <= (others => '0');
						
					-- ----------
					when "10" =>
						data   <= data_sub;
						remain <= (others => '0');
						
					-- xxxxxxxxxx
					when "01" =>
						data   <= data_mul;
						remain <= (others => '0');
						
					-- //////////
					when "00" =>
						data   <= data_div;
						remain <= data_rem;
				end case;
				
				if (rst_i='0' ) then  
					int_data_1 <= 0;
					int_data_2 <= 0;
					int_data_3 <= 0;
					int_data_4 <= 0;
					int_data_5 <= 0;
					int_data_6 <= 0;
					
				elsif ((clk_i'event and clk_i='1') and  (Done = '1')) then  
					
					int_data_1 <= conv_integer(unsigned(data)) mod 10;
					int_data_2 <= (conv_integer(unsigned(data))/ 10) mod 10;
					int_data_3 <= (conv_integer(unsigned(data))/ 100 );
					
					int_data_4 <= conv_integer(unsigned(remain)) mod 10;
					int_data_5 <= (conv_integer(unsigned(remain))/ 10) mod 10;
					int_data_6 <= (conv_integer(unsigned(remain))/ 100 );
					
				end if;
				
				
				
					BCD_digit_1 <= conv_std_logic_vector(int_data_1, 4);
					BCD_digit_2 <= conv_std_logic_vector(int_data_2, 4);
					BCD_digit_3 <= conv_std_logic_vector(int_data_3, 4);
					BCD_digit_4 <= conv_std_logic_vector(int_data_4, 4);
					BCD_digit_5 <= conv_std_logic_vector(int_data_5, 4);
					BCD_digit_6 <= conv_std_logic_vector(int_data_6, 4);
				
				
		end process;
end Behavioral;