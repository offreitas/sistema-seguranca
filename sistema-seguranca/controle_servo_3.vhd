library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
	port (
		-- Inputs
		clock   : in  std_logic;
		reset   : in  std_logic;
		posicao : in  std_logic_vector(3 downto 0);
		-- Output
		pwm : out std_logic;
		-- Debug
		db_reset   : out std_logic;
		db_pwm     : out std_logic;
		db_posicao : out std_logic_vector(3 downto 0)
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
			when "0000"  => motor_width <= 50000; 
			when "0001"  => motor_width <= 52000; 
			when "0010"  => motor_width <= 54000; 
			when "0011"  => motor_width <= 56000; 
			when "0100"  => motor_width <= 58000; 
			when "0101"  => motor_width <= 60000; 
			when "0110"  => motor_width <= 62000; 
			when "0111"  => motor_width <= 64000; 
			when "1000"  => motor_width <= 66000; 
			when "1001"  => motor_width <= 68000;
			when "1010"  => motor_width <= 70000; 
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