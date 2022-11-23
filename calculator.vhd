library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity calculator is
	generic( N : integer := 5 );
	port(
		clock      : in std_logic;
		A, B       : in std_logic_vector(N-1 downto 0);
		Operation  : in std_logic_vector(1   downto 0);
		Start      : in std_logic;
		RST_N      : in std_logic;
		
		seven_seg_digit_1 : out STD_LOGIC_VECTOR (6 downto 0);
		seven_seg_digit_2 : out STD_LOGIC_VECTOR (6 downto 0);
		seven_seg_digit_3 : out STD_LOGIC_VECTOR (6 downto 0);
		
		seven_seg_digit_4 : out STD_LOGIC_VECTOR (6 downto 0);
		seven_seg_digit_5 : out STD_LOGIC_VECTOR (6 downto 0);
		seven_seg_digit_6 : out STD_LOGIC_VECTOR (6 downto 0);
		
		Done       : out std_logic
		
		-- temp : fur debug
--		Result_a     : out std_logic_vector(2*N-1 downto 0);
--		Result_s     : out std_logic_vector(2*N-1 downto 0);
--		Result_m     : out std_logic_vector(2*N-1 downto 0);
--		Result_d     : out std_logic_vector(2*N-1 downto 0);
--		Remain       : out std_logic_vector(2*N-1 downto 0)
	);
	
end calculator;
	
	

architecture Structural of calculator is

	component BDC_to_7_segmen is
     port(
			BCD_i 	 	: in std_logic_vector (3 downto 0);
			clk_i 			: in std_logic;
			seven_seg   :out std_logic_vector (6 downto 0));			
	end component;

	component BCD_2_digit_7_seg_display
		Port ( 
			 A,B       : in std_logic_vector(N-1 downto 0) ;
			 
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
	end component;
	
	component division is
		port(
		  clock  : in  std_logic;	-- system clock
        reset  : in  std_logic; 	-- synchronous reset, active-high
		  start	: in  std_logic;
		  A,B		: in  std_logic_vector(N-1 downto 0) := (others => '0');
		  Q		: out std_logic_vector(2*N-1 downto 0) := (others => '0');  -- quotient
		  R		: out std_logic_vector(2*N-1 downto 0) := (others => '0');	-- remainer
		  DONE	: out std_logic;
		  Operation : std_logic_vector(1 downto 0)
		);
	end component;
	
	component Multiplication is
		port (
			CLK   : in std_logic; 
			RST_N : in std_logic; 
			START : in std_logic;
			A, B  : in std_logic_vector(N - 1 downto 0) := (others => '0');
			R     : out std_logic_vector(2 * N - 1 downto 0) := (others => '0');
			DONE  : out std_logic := '0';
			Operation : std_logic_vector(1 downto 0)
			);
	end component;
	
	
	component add is
		port( START,CLK,RST_N : in std_logic ;
				A,B       : in std_logic_vector(N-1 downto 0) ;
				M				 : in std_logic := '0' ;
				R				 : out std_logic_vector(2*N-1 downto 0);
				DONE 			 : out std_logic;
				Operation    : in std_logic_vector(1 downto 0)
		);
	end component;
	
	component sub is
		port( START,CLK,RST_N : in std_logic ;
				A,B       : in std_logic_vector(N-1 downto 0) ;
				M				 : in std_logic := '0' ;
				R				 : out std_logic_vector(2*N-1 downto 0);
				DONE 			 : out std_logic;
				Operation    : in std_logic_vector(1 downto 0)
		);
	end component;
	
	
	
	-- SIGNALs	
	signal result_add    : std_logic_vector(2*N-1 downto 0);
	signal result_sub    : std_logic_vector(2*N-1 downto 0);
	signal done_add      : std_logic;
	signal done_sub      : std_logic;
	
	signal result_mul       : std_logic_vector(2*N-1 downto 0);
	signal done_mul         : std_logic;
	
	signal result_div       : std_logic_vector(2*N-1 downto 0);
	signal result_div_rem   : std_logic_vector(2*N-1 downto 0);
	signal done_div         : std_logic;
	
	signal global_done      : std_logic;
	
	signal add_sub_select   : std_logic;
	
	signal BCD_data_digit_1 : STD_LOGIC_VECTOR (3 downto 0);
	signal BCD_data_digit_2 : STD_LOGIC_VECTOR (3 downto 0);
	signal BCD_data_digit_3 : STD_LOGIC_VECTOR (3 downto 0);
	
	signal BCD_data_digit_4 : STD_LOGIC_VECTOR (3 downto 0);
	signal BCD_data_digit_5 : STD_LOGIC_VECTOR (3 downto 0);
	signal BCD_data_digit_6 : STD_LOGIC_VECTOR (3 downto 0);
		
	

	
	
	begin 
			
			-- ====================================================================
			-- Port Mapping + - x /
			
			Adder : add
				port map( 
						START  => Start,
						CLK    => clock,
						RST_N  => RST_N,
						A      => A,
						B      => B,      
						M		 => '0',		
						R		 => result_add,
						DONE 	 => done_add,	
						Operation => Operation    
				);
				
			Subtract : sub
				port map( 
						START  => Start,
						CLK    => clock,
						RST_N  => RST_N,
						A      => A,
						B      => B,      
						M		 => '1',		
						R		 => result_sub,
						DONE 	 => done_sub,	
						Operation => Operation    
				);
			
			Divide : division
				port map(
					clock      => clock,
					reset      => RST_N,
					start      => Start, 
					A          => A,
					B          => B,
					Q          => result_div,
					R          => result_div_rem,
					DONE       => done_div,
					Operation  => Operation
				);
				
			Multiply : Multiplication
				port map(
					CLK        => clock, 
					RST_N      => RST_N, 
					START      => Start,
					A          => A, 
					B          => B,
					R          => result_mul,
					DONE       => done_mul,
					Operation  => Operation
				);
			
			global_done <= ( done_add or done_sub or done_mul or done_div );
			Done        <= global_done;
			
			-- ====================================================================
			-- Result to 4-bit to each display
			
			bcd_to_seven_digit : BCD_2_digit_7_seg_display
				port map(
					 A          => A, 
					 B          => B,
					 
					 clk_i => clock,  
					 rst_i => RST_N, 
					 
					 Done  => global_done,
					 
					 Operation 	=> Operation,
					 
					 data_add 	=> result_add,
					 data_sub 	=> result_sub,
					 data_mul 	=> result_mul,
					 data_div 	=> result_div,
					 data_rem 	=> result_div_rem,
					 
					 BCD_digit_1 => BCD_data_digit_1,
					 BCD_digit_2 => BCD_data_digit_2,
					 BCD_digit_3 => BCD_data_digit_3,
					 
					 BCD_digit_4 => BCD_data_digit_4,
					 BCD_digit_5 => BCD_data_digit_5,
					 BCD_digit_6 => BCD_data_digit_6
				);
			
			
			-- ====================================================================
			-- 4-bit to 7-Segment
			
			seven_seg_1 : BDC_to_7_segmen 
			  port map(
						BCD_i 	 	=> BCD_data_digit_1,
						clk_i 		=> clock,
						seven_seg   => seven_seg_digit_1
			  );
			  
			seven_seg_2 : BDC_to_7_segmen 
			  port map(
						BCD_i 	 	=> BCD_data_digit_2,
						clk_i 		=> clock,
						seven_seg   => seven_seg_digit_2
			  );
			  
			seven_seg_3 : BDC_to_7_segmen 
			  port map(
						BCD_i 	 	=> BCD_data_digit_3,
						clk_i 		=> clock,
						seven_seg   => seven_seg_digit_3
			  );
			  
			  
			  
			  seven_seg_4 : BDC_to_7_segmen 
			  port map(
						BCD_i 	 	=> BCD_data_digit_4,
						clk_i 		=> clock,
						seven_seg   => seven_seg_digit_4
			  );
			  
			seven_seg_5 : BDC_to_7_segmen 
			  port map(
						BCD_i 	 	=> BCD_data_digit_5,
						clk_i 		=> clock,
						seven_seg   => seven_seg_digit_5
			  );
			  
			seven_seg_6 : BDC_to_7_segmen 
			  port map(
						BCD_i 	 	=> BCD_data_digit_6,
						clk_i 		=> clock,
						seven_seg   => seven_seg_digit_6
			  );
			  
			
			  
			-- ====================================================================
			-- Output for wfv debug
			
--			Result_a <=  result_add;
--			Result_s <=  result_sub;
--			Result_m <=  result_mul;
--			Result_d <=  result_div;
--			Remain   <=  result_div_rem;


end Structural;
