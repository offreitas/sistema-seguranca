library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
	port (
		-- Inputs
		clock   : in  std_logic;
		reset   : in  std_logic;
		posicao : in  std_logic_vector(2 downto 0);
		-- Output
		pwm : out std_logic;
		-- Debug
		db_reset   : out std_logic;
		db_pwm     : out std_logic;
		db_posicao : out std_logic_vector(2 downto 0)
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
			when "000"  => motor_width <= 50000;  -- 20°
			when "001"  => motor_width <= 57143;  -- 40°
			when "010"  => motor_width <= 64286;  -- 60°
			when "011"  => motor_width <= 71429;  -- 80°
			when "100"  => motor_width <= 78572;  -- 100°
			when "101"  => motor_width <= 85715;  -- 120°
			when "110"  => motor_width <= 92858;  -- 140°
			when "111"  => motor_width <= 100000; -- 160°
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