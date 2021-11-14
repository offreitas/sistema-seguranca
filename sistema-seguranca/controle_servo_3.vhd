library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
	port (
		-- Inputs
		clock   : in  std_logic;
		reset   : in  std_logic;
		posicao : in  std_logic_vector(4 downto 0);
		-- Output
		pwm : out std_logic;
		-- Debug
		db_reset   : out std_logic;
		db_pwm     : out std_logic;
		db_posicao : out std_logic_vector(4 downto 0)
	);
end entity;

architecture rtl of controle_servo_3 is

	constant MAX_COUNT : integer := 1000000;
	
	signal count       : integer range 0 to (MAX_COUNT - 1);
	signal pwm_width   : integer range 0 to (MAX_COUNT - 1);
	signal motor_width : integer range 0 to (MAX_COUNT - 1);

	signal pwm_s : std_logic;

begin

	process (clock, reset, posicao)
	begin
		if (reset = '1') then
			count     <= 0;
			pwm_s     <= '0';
			pwm_width <= motor_width;
		elsif (rising_edge(clock)) then
			if (count < pwm_width) then
				pwm_s <= '1';
			else
				pwm_s <= '0';
			end if;

			if (count = MAX_COUNT - 1) then
				count     <= 0;
				pwm_width <= motor_width;
			else
				count <= count + 1;
			end if;
		end if;
	end process;

	process (posicao)
	begin
		case posicao is
			when "00000"  => motor_width <= 50000; 
			when "00001"  => motor_width <= 52000; 
			when "00010"  => motor_width <= 54000; 
			when "00011"  => motor_width <= 56000; 
			when "00100"  => motor_width <= 58000; 
			when "00101"  => motor_width <= 60000; 
			when "00110"  => motor_width <= 62000; 
			when "00111"  => motor_width <= 64000; 
			when "01000"  => motor_width <= 66000; 
			when "01001"  => motor_width <= 68000; 
			when "01010"  => motor_width <= 70000; 
			when "01011"  => motor_width <= 72000; 
			when "01100"  => motor_width <= 74000; 
			when "01101"  => motor_width <= 76000; 
			when "01110"  => motor_width <= 78000; 
			when "01111"  => motor_width <= 80000; 
			when "10000"  => motor_width <= 82000; 
			when "10001"  => motor_width <= 84000; 
			when "10010"  => motor_width <= 86000; 
			when "10011"  => motor_width <= 88000; 
			when "10100"  => motor_width <= 90000; 
			when "10101"  => motor_width <= 92000; 
			when "10110"  => motor_width <= 94000; 
			when "10111"  => motor_width <= 96000; 
			when "11000"  => motor_width <= 98000; 
			when "11001"  => motor_width <= 100000; 
			when others => motor_width <= 0; 
		end case;
	end process;

	-- Output
	pwm <= pwm_s;
	
	-- Debug
	db_reset   <= reset;	
	db_pwm     <= pwm_s;
	db_posicao <= posicao;

end architecture;