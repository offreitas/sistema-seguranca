library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar is
	port(
		-- Inputs
		clock   : in std_logic;
		reset   : in std_logic;
		ligar   : in std_logic;
		echo    : in std_logic;
		dado_serial : in std_logic;
		sel_mux : in std_logic_vector(1 downto 0);
		-- Outputs
		trigger            : out std_logic;
		db_trigger         : out std_logic;
		db_echo            : out std_logic;
		pwm                : out std_logic;
		saida_serial       : out std_logic;
		saida_serial_ch    : out std_logic;
		saida_serial_mqtt  : out std_logic;
		pwm_ch             : out std_logic;
		alerta_proximidade : out std_logic;
		alerta_prox_mqtt   : out std_logic;
		db_transmitir      : out std_logic;
		db_medir           : out std_logic;
		display0           : out std_logic_vector(6 downto 0);
		display1           : out std_logic_vector(6 downto 0);
		display2           : out std_logic_vector(6 downto 0);
		display3           : out std_logic_vector(6 downto 0);
		display4           : out std_logic_vector(6 downto 0);
		display5           : out std_logic_vector(6 downto 0)
	);
end entity;

architecture sonar_arch of sonar is

	-- Unidade de Controle
	component sonar_uc is
		port (
			-- Inputs
			clock      : in std_logic;
			reset      : in std_logic;
			ligar      : in std_logic;
			fim_2s     : in std_logic;
			meio_2s    : in std_logic;
			pronto_med : in std_logic;
			pronto_tx  : in std_logic;
			-- Outputs
			zera       : out std_logic;
			posiciona  : out std_logic;
			medir      : out std_logic;
			transmitir : out std_logic;
			db_estado  : out std_logic_vector(3 downto 0)
		);
	end component;

	-- Fluxo de Dados
	component sonar_fd is
		port (
			-- Inputs
			clock      : in std_logic;
			reset      : in std_logic;
			ligar      : in std_logic;
			medir      : in std_logic;
			posiciona  : in std_logic;
			transmitir : in std_logic;
			echo       : in std_logic;
			dado_serial: in std_logic;
			-- Outputs
			pwm                : out std_logic;
			trigger            : out std_logic;
			saida_serial       : out std_logic;
			pronto_tx          : out std_logic;
			alerta_proximidade : out std_logic;
			fim_2s             : out std_logic;
			meio_2s            : out std_logic;
			pronto_med         : out std_logic;
			posicao_servo      : out std_logic_vector(2 downto 0);
			contagem_mux       : out std_logic_vector(2 downto 0);
			estado_hcsr        : out std_logic_vector(3 downto 0);
			estado_tx_sonar    : out std_logic_vector(3 downto 0);
			estado_rx          : out std_logic_vector(3 downto 0);
			estado_tx          : out std_logic_vector(3 downto 0);
			dado_recebido      : out std_logic_vector(7 downto 0);
			distancia          : out std_logic_vector(11 downto 0);
			angulo             : out std_logic_vector(23 downto 0)
		);
	end component;

	-- Multiplexador 4x1
	component mux_4x1_n is
		generic (
			constant BITS: integer := 4
		);
		port ( 
			D0 :     in  std_logic_vector (BITS-1 downto 0);
			D1 :     in  std_logic_vector (BITS-1 downto 0);
			D2 :     in  std_logic_vector (BITS-1 downto 0);
			D3 :     in  std_logic_vector (BITS-1 downto 0);
			SEL:     in  std_logic_vector (1 downto 0);
			MUX_OUT: out std_logic_vector (BITS-1 downto 0)
		);
	end component;

	-- Display de 7 segmentos
	component hex7seg is
		port (
			hexa : in  std_logic_vector(3 downto 0);
			sseg : out std_logic_vector(6 downto 0)
		);
	end component;

	-- Sinais
	signal pronto_tx_s                  : std_logic;
	signal fim_2s_s, zera_s, reset_fd   : std_logic;
	signal meio_2s_s						   : std_logic;
	signal posiciona_s, medir_s         : std_logic;
	signal saida_serial_s, pwm_s        : std_logic;
	signal alerta_proximidade_s         : std_logic;
	signal transmitir_s, pronto_med_s   : std_logic;
	signal posicao_3bits                : std_logic_vector(2 downto 0);
	signal contagem_mux_3bits           : std_logic_vector(2 downto 0);
	signal contagem_mux_4bits           : std_logic_vector(3 downto 0);
	signal sonar_estado, posicao_4bits  : std_logic_vector(3 downto 0);
	signal estado_hcsr, estado_tx_sonar : std_logic_vector(3 downto 0);
	signal estado_rx, estado_tx         : std_logic_vector(3 downto 0);
	signal dado_recebido_s              : std_logic_vector(7 downto 0);
	signal distancia_bcd                : std_logic_vector(11 downto 0);
	signal angulo_bcd_hex               : std_logic_vector(23 downto 0);
	signal trigger_s							: std_logic;

	-- Saidas dos multiplexadores
	signal m0_out, m1_out, m2_out, m3_out, m4_out, m5_out : std_logic_vector(3 downto 0);

begin

	-- Logica de sinais
	reset_fd           <= reset or zera_s;
	posicao_4bits      <= '0' & posicao_3bits;
	contagem_mux_4bits <= '0' & contagem_mux_3bits;

	-- Instancias
	U1: sonar_uc
		port map(
			-- Inputs
			clock      => clock,
			reset      => reset,
			ligar      => ligar,
			fim_2s     => fim_2s_s,
			meio_2s    => meio_2s_s,
			pronto_med => pronto_med_s,
			pronto_tx  => pronto_tx_s,
			-- Outputs
			zera       => zera_s,
			posiciona  => posiciona_s,
			medir      => medir_s,
			transmitir => transmitir_s,
			db_estado  => sonar_estado
		);

	U2: sonar_fd
		port map(
			-- Inputs
			clock      => clock,
			reset      => reset_fd,
			ligar      => ligar,
			medir      => medir_s,
			posiciona  => posiciona_s,
			transmitir => transmitir_s,
			echo       => echo,
			dado_serial=> dado_serial,
			-- Outputs
			pwm                => pwm_s,
			trigger            => trigger_s,
			saida_serial       => saida_serial_s,
			pronto_tx          => pronto_tx_s,
			alerta_proximidade => alerta_proximidade_s,
			fim_2s             => fim_2s_s,
			meio_2s            => meio_2s_s,
			pronto_med         => pronto_med_s,
			posicao_servo      => posicao_3bits,
			contagem_mux       => contagem_mux_3bits,
			estado_hcsr        => estado_hcsr,
			estado_tx_sonar    => estado_tx_sonar,
			estado_rx          => estado_rx,
			estado_tx          => estado_tx,
			dado_recebido      => dado_recebido_s,
			distancia          => distancia_bcd,
			angulo             => angulo_bcd_hex
		);
	
	trigger <= trigger_s;
	db_trigger <= trigger_s;
	db_echo <= echo;
	
	M0: mux_4x1_n --VALOR DO DISPLAY HEX0
		generic map(4)
		port map(
			-- Inputs
			D0  => distancia_bcd(3 downto 0), --SEL_MUX=00 (distancia0)
			D1  => dado_recebido_s(3 downto 0), --SEL_MUX=01 (DADO_RX1)
			D2  => "0000", --SEL_MUX=10 a definir ...
			D3  => angulo_bcd_hex(3 downto 0),--SEL_MUX=11 (angulo0)
			SEL => sel_mux,
			-- Output
			MUX_OUT => m0_out
		);
	
	M1: mux_4x1_n --VALOR DO DISPLAY HEX1
		generic map(4)
		port map(
			-- Inputs
			D0  => distancia_bcd(7 downto 4),--SEL_MUX=00 (distancia1)
			D1  => dado_recebido_s(7 downto 4), --SEL_MUX=01 (dado_RX1)
			D2  => "0000", --SEL_MUX=10 a definir...
			D3  => angulo_bcd_hex(11 downto 8),--SEL_MUX=11 (angulo1)
			SEL => sel_mux,
			-- Output
			MUX_OUT => m1_out
		);
	
	M2: mux_4x1_n --VALOR DO DISPLAY HEX2
		generic map(4)
		port map(
			-- Inputs
			D0  => distancia_bcd(11 downto 8),--SEL_MUX=00 (distancia2)
			D1  => estado_rx, --SEL_MUX=01 (estado_rx)
			D2  => "0000", -- --SEL_MUX=10 (dado_tx2)
			D3  => angulo_bcd_hex(19 downto 16),--SEL_MUX=11 (angulo2)
			SEL => sel_mux,
			-- Output
			MUX_OUT => m2_out
		);
	
	M3: mux_4x1_n --VALOR DO DISPLAY HEX3
		generic map(4)
		port map(
			-- Inputs
			D0  => "0000",--SEL_MUX=00 a definir...
			D1  => "0000", --SEL_MUX=00 (DADO_TX0)
			D2  => "0000", --SEL_MUX=00 (dado_tx1)
			D3  => "0000",--SEL_MUX=11 a definir...
			SEL => sel_mux,
			-- Output
			MUX_OUT => m3_out
		);
	
	M4: mux_4x1_n --VALOR DO DISPLAY HEX4
		generic map(4)
		port map(
			-- Inputs
			D0  => estado_hcsr,
			D1  => "0000", -- DADO_TX1
			D2  => contagem_mux_4bits,
			D3  => "0000",
			SEL => sel_mux,
			-- Output
			MUX_OUT => m4_out
		);
	
	M5: mux_4x1_n --VALOR DO DISPLAY HEX5
		generic map(4)
		port map(
			-- Inputs
			D0  => posicao_4bits,
			D1  => estado_tx,
			D2  => estado_tx_sonar,
			D3  => sonar_estado,
			SEL => sel_mux,
			-- Output
			MUX_OUT => m5_out
		);

	H0: hex7seg port map(hexa => m0_out, sseg => display0);
	H1: hex7seg port map(hexa => m1_out, sseg => display1);
	H2: hex7seg port map(hexa => m2_out, sseg => display2);
	H3: hex7seg port map(hexa => m3_out, sseg => display3);
	H4: hex7seg port map(hexa => m4_out, sseg => display4);
	H5: hex7seg port map(hexa => m5_out, sseg => display5);
	
	-- Outputs
	pwm    <= pwm_s;
	pwm_ch <= pwm_s;
	
	saida_serial      <= saida_serial_s;
	saida_serial_ch   <= saida_serial_s;
	saida_serial_mqtt <= saida_serial_s;
	
	alerta_proximidade <= alerta_proximidade_s;
	alerta_prox_mqtt   <= alerta_proximidade_s;

	db_medir <= medir_s;

end architecture;