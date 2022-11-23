library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Multiplication is
	generic (N : integer := 5);
	port (
		CLK, RST_N, START : in std_logic;
		A, B : in std_logic_vector(N - 1 downto 0) := (others => '0');
		R : out std_logic_vector(2 * N - 1 downto 0) := (others => '0');
		DONE : out std_logic := '0';
		Operation : std_logic_vector(1 downto 0)
		);
	end Multiplication;

	-- =========================================================================================
	-- =========================================================================================

	architecture Behave of Multiplication is

		type state_type is (s0, s1);
		signal Data_A : std_logic_vector(2 * N - 1 downto 0) := (others => '0');
		signal Data_B : std_logic_vector(N - 1 downto 0) := (others => '0');
		signal Data_Product : std_logic_vector(2 * N - 1 downto 0) := (others => '0');
		signal bit_counter : integer := 0;
		signal state : state_type := s0;
		signal P_done : std_logic := '0';
		signal S_Start : std_logic := '0';
	begin
		S_Start <= START;

		process (RST_N, CLK, START)

		begin
			if RST_N = '0' then -- async, rest (active low)
				state <= s0;
				Data_A <= (others => '0');
				Data_B <= (others => '0');
				Data_Product <= (others => '0');
				R <= (others => '0');
			elsif rising_edge(CLK) then
				case state is

					when s0 => -- check start for multiple process
						if ((S_Start = '0') and (Operation = "01")) then
							Data_A (N - 1 downto 0) <= A;
							Data_B <= B;
							state <= s1;
						elsif (S_Start = '0') then
							R <= (others => '0');
						else
							state <= s0;
							DONE <= '0';
						end if;

					when s1 => -- Multiply Process
						if (bit_counter < (N + 1)) then
							state <= s1;
							if Data_B(bit_counter) = '1' then
								-- Addup (Do multiply when B is 1)
								Data_Product <= Data_Product + Data_A;
								Data_A <= std_logic_vector(shift_left(unsigned(Data_A), 1));
								-- Data A SHIFT LEFT 1 BIT
								R <= Data_Product;
								bit_counter <= (bit_counter + 1);
							else
								Data_a <= std_logic_vector(shift_left(unsigned(Data_A), 1));
								R <= Data_Product;
								bit_counter <= (bit_counter + 1);
							end if;

						else
							bit_counter <= 0;
							Data_Product <= (others => '0');
							Data_A <= (others => '0');
							Data_B <= (others => '0');
							state <= s0;
							DONE <= '1';

						end if;

				end case;

			end if;

		end process;

end behave;