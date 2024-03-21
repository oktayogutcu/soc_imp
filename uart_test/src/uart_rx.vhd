library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity uart_rx is 
	generic (
		CLOCK_FREQ  	: integer := 100_000_000; 
		BAUD_RATE 		: integer := 115_200;
		STOP_COUNT		: integer := 1;
		DATA_WIDTH		: integer := 8	
	);
	port (
		clk 		: in std_logic;
		rst			: in std_logic;
		rx			: in std_logic;
		busy		: out std_logic;
		data_valid 	: out std_logic;
		data 		: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end uart_rx;

architecture rtl of uart_rx is 
constant c_clock_per_bit : integer := CLOCK_FREQ/BAUD_RATE;
type t_state is (idle, start_bit, receive_bit, stop_bit);
signal s_state : t_state := idle; 
signal s_rx : std_logic := '0';
signal s_rx_d : std_logic := '0';
signal s_clk_counter : integer range 0 to c_clock_per_bit-1 := 0;
signal s_bit_counter : integer range 0 to DATA_WIDTH-1 := 0;
signal s_rx_byte  :std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	
begin
UART_RX_P: process(clk,rst)
begin
	if(rst = '0') then
        s_state <= idle;
        s_clk_counter <= 0;
        s_bit_counter <= 0;
        s_rx_byte <= (others=>'0');
		data <= (others=>'0');
        data_valid <= '0';
		busy <= '0';
		
	else
		if(rising_edge(clk)) then        
            case s_state is                
                when idle =>
					s_rx_byte <= (others =>'0');
                    data_valid <= '0';
                    s_clk_counter <= 0;
                    s_bit_counter <= 0;
					if(rx = '0') then
						s_state <= start_bit;
						busy <= '1';
					else
					s_state <= idle;		
					end if;
					
				when start_bit =>
					
					if(s_clk_counter = c_clock_per_bit/2) then
						if(rx = '0') then
							s_state <= receive_bit;						
						else
							s_state <= idle;
						end if;
						s_clk_counter <= 0;
					else
						s_clk_counter <= s_clk_counter + 1;
						s_state <= start_bit;
					end if;
					
					
				when receive_bit =>
				
					if(s_clk_counter = c_clock_per_bit-1) then
						s_rx_byte <= rx & s_rx_byte(DATA_WIDTH-1 DOWNTO 1);
						if(s_bit_counter = 7) then		
							s_bit_counter <= 0;
							s_state <= stop_bit;
						else
							s_bit_counter <= s_bit_counter + 1;
							s_state <= receive_bit;	
						end if;
						s_clk_counter <= 0;
					else
						s_clk_counter <= s_clk_counter + 1;
					end if;
					
				when stop_bit =>
				
					if(s_clk_counter = STOP_COUNT*c_clock_per_bit-1) then
						s_state <= idle;
						data_valid <= '1';
						data <= s_rx_byte;
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