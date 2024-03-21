library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity uart_tx is 
	generic (
		CLOCK_FREQ  	: integer := 100_000_000;
		BAUD_RATE 		: integer := 115_200;
		STOP_COUNT		: integer := 1;
		DATA_WIDTH		: integer := 8		
	);
	port (
		clk 		: in std_logic;
		rst			: in std_logic;
		start	 	: in std_logic;
		data 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		busy		: out std_logic;
		tx			: out std_logic;
		done		: out std_logic

	);
end uart_tx;

architecture rtl of uart_tx is
constant c_clock_per_bit : integer := CLOCK_FREQ/BAUD_RATE;
type t_state is (idle, start_bit, send_bit, stop_bit);
signal s_state : t_state := idle; 
signal s_clk_counter : integer range 0 to c_clock_per_bit-1 := 0;
signal s_data_in  :std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin
UART_TX_P: process(clk, rst)
variable v_tx_count: integer range 0 to DATA_WIDTH-1 := 0;
begin
	if(rst = '0') then
		done <= '0';
		tx <=	'1';
		s_state <= idle;
		s_clk_counter <= 0;
		s_data_in <= (others=>'0');
		busy <= '0';
	else
		if(rising_edge(clk)) then 
			case s_state is                
                when idle =>
					done <= '0';
					tx <=	'1';
					v_tx_count := 0;
					
					s_clk_counter <= 0;
					if(start = '1') then
						busy <= '1';
						s_state <= start_bit;
						tx <= '0';
						s_data_in <= data;
					else
						busy <= '0';
						s_state <= idle;
					end if;

					
				when start_bit =>
					
					if(s_clk_counter = c_clock_per_bit-1) then
						s_clk_counter <= 0;					
						tx <= s_data_in(0);
						s_data_in <= '1' & s_data_in(DATA_WIDTH-1 downto 1);
						s_state <= send_bit;
					else
						s_clk_counter <= s_clk_counter + 1;
						s_state <= start_bit;
					end if;
					
					
				when send_bit =>
				
					if(s_clk_counter = c_clock_per_bit-1) then
						if(v_tx_count = 7) then
							s_state <= stop_bit;
							tx <= '1';
						else
							v_tx_count := v_tx_count + 1;
							tx <= s_data_in(0);
							s_data_in <= '1' & s_data_in(DATA_WIDTH-1 downto 1);
						end if;
						s_clk_counter <= 0;
					else
						s_clk_counter <= s_clk_counter + 1;
					end if;
					
				when stop_bit =>
				
					if(s_clk_counter = STOP_COUNT*c_clock_per_bit-1) then
						s_state <= idle;
						done <= '1';
						busy <= '0';
					else
						s_clk_counter <= s_clk_counter + 1;
						s_state <= stop_bit;
					end if;

				
				when others =>
                    s_state <= idle;  
			end case;


		end if;
	end if;

end process;

end rtl;