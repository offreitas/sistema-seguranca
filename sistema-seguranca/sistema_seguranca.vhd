library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sistema_seguranca is
	port(
		-- Inputs
		clock       : in std_logic;
		reset       : in std_logic;
		ligar       : in std_logic;
		echo        : in std_logic;
		dado_serial : in std_logic;
		mode        : in std_logic;
		senha_ok    : in std_logic;
		desarmar    : in std_logic;
		sel_mux     : in std_logic_vector(1 downto 0);
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
		calibrando         : out std_logic;
		alerta_mov         : out std_logic;
		db_mode            : out std_logic;
		db_fim_2s          : out std_logic;
		db_erro            : out std_logic;
		display0           : out std_logic_vector(6 downto 0);
		display1           : out std_logic_vector(6 downto 0);
		display2           : out std_logic_vector(6 downto 0);
		display3           : out std_logic_vector(6 downto 0);
		display4           : out std_logic_vector(6 downto 0);
		display5           : out std_logic_vector(6 downto 0)
	);
end entity;

architecture sistema_seguranca_arch of sistema_seguranca is

	-- Unidade de Controle
	component sistema_seguranca_uc is
		port (
			-- Inputs
			clock      : in std_logic;
			reset      : in std_logic;
			ligar      : in std_logic;
			fim_1s     : in std_logic;
			pronto_med : in std_logic;
			pronto_tx  : in std_logic;
			fim_cal    : in std_logic;
			alerta     : in std_logic;
			mode       : in std_logic;
			senha_ok   : in std_logic;
			desarmar   : in std_logic;
			erro       : in std_logic;
			-- Outputs
			zera       : out std_logic;
			posiciona  : out std_logic;
			medir      : out std_logic;
			transmitir : out std_logic;
			calibrando : out std_logic;
			write_en   : out std_logic;
			alerta_out : out std_logic;
			clear_reg  : out std_logic;
			db_estado  : out std_logic_vector(3 downto 0)
		);
	end component;

	-- Fluxo de Dados
	component sistema_seguranca_fd is
		port (
			-- Inputs
			clock       : in std_logic;
			reset       : in std_logic;
			zera        : in std_logic;
			ligar       : in std_logic;
			medir       : in std_logic;
			posiciona   : in std_logic;
			transmitir  : in std_logic;
			echo        : in std_logic;
			dado_serial : in std_logic;
			calibrando  : in std_logic;
			write_en    : in std_logic;
			clear_reg   : in std_logic;
			-- Outputs
			pwm                         : out std_logic;
			trigger                     : out std_logic;
			saida_serial                : out std_logic;
			pronto_tx                   : out std_logic;
			alerta_proximidade          : out std_logic;
			fim_1s                      : out std_logic;
			meio_1s                     : out std_logic;
			pronto_med                  : out std_logic;
			fim_cal                     : out std_logic;
			erro                        : out std_logic;
			contagem_mux                : out std_logic_vector(2 downto 0);
			estado_hcsr                 : out std_logic_vector(3 downto 0);
			estado_tx_sistema_seguranca : out std_logic_vector(3 downto 0);
			estado_rx                   : out std_logic_vector(3 downto 0);
			estado_tx                   : out std_logic_vector(3 downto 0);
			posicao_servo               : out std_logic_vector(3 downto 0);
			dado_recebido               : out std_logic_vector(7 downto 0);
			distancia                   : out std_logic_vector(11 downto 0);
			dist_mem                    : out std_logic_vector(11 downto 0);
			dist_mais_sens              : out std_logic_vector(11 downto 0);
			angulo                      : out std_logic_vector(23 downto 0)
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
	signal pronto_tx_s                              : std_logic;
	signal fim_1s_s, zera_s, reset_fd               : std_logic;
	signal meio_1s_s						        : std_logic;
	signal posiciona_s, medir_s                     : std_logic;
	signal saida_serial_s, pwm_s                    : std_logic;
	signal alerta_proximidade_s                     : std_logic;
	signal transmitir_s, pronto_med_s               : std_logic;
	signal fim_cal_s, calibrando_s, write_en_s      : std_logic;
	signal trigger_s, mode_s, alerta_s              : std_logic;
	signal erro_s, clear_reg_s                      : std_logic;
	signal contagem_mux_3bits                       : std_logic_vector(2 downto 0);
	signal contagem_mux_4bits                       : std_logic_vector(3 downto 0);
	signal sistema_seguranca_estado, posicao_4bits  : std_logic_vector(3 downto 0);
	signal estado_hcsr, estado_tx_sistema_seguranca : std_logic_vector(3 downto 0);
	signal estado_rx, estado_tx                     : std_logic_vector(3 downto 0);
	signal dado_recebido_s                          : std_logic_vector(7 downto 0);
	signal distancia_bcd                            : std_logic_vector(11 downto 0);
	signal dist_mem                                 : std_logic_vector(11 downto 0);
	signal dist_sens                                : std_logic_vector(11 downto 0);
	signal angulo_bcd_hex                           : std_logic_vector(23 downto 0);

	-- Saidas dos multiplexadores
	signal m0_out, m1_out, m2_out, m3_out, m4_out, m5_out : std_logic_vector(3 downto 0);

begin

	-- Logica de sinais
	reset_fd           <= reset or zera_s;
	mode_s             <= mode;
	contagem_mux_4bits <= '0' & contagem_mux_3bits;

	-- Instancias
	U1_UC: sistema_seguranca_uc
		port map(
			-- Inputs
			clock      => clock,
			reset      => reset,
			ligar      => ligar,
			fim_1s     => fim_1s_s,
			pronto_med => pronto_med_s,
			pronto_tx  => pronto_tx_s,
			fim_cal    => fim_cal_s,
			alerta     => alerta_proximidade_s,
			mode       => mode_s,
			senha_ok   => senha_ok,
			desarmar   => desarmar,
			erro       => erro_s,
			-- Outputs
			zera       => zera_s,
			posiciona  => posiciona_s,
			medir      => medir_s,
			transmitir => transmitir_s,
			calibrando => calibrando_s,
			write_en   => write_en_s,
			alerta_out => alerta_s,
			clear_reg  => clear_reg_s,
			db_estado  => sistema_seguranca_estado
		);

	U2_FD: sistema_seguranca_fd
		port map(
			-- Inputs
			clock       => clock,
			reset       => reset_fd,
			zera        => zera_s,
			ligar       => ligar,
			medir       => medir_s,
			posiciona   => posiciona_s,
			transmitir  => transmitir_s,
			echo        => echo,
			dado_serial => dado_serial,
			calibrando  => calibrando_s,
			write_en    => write_en_s,
			clear_reg   => clear_reg_s,
			-- Outputs
			pwm                         => pwm_s,
			trigger                     => trigger_s,
			saida_serial                => saida_serial_s,
			pronto_tx                   => pronto_tx_s,
			alerta_proximidade          => alerta_proximidade_s,
			fim_1s                      => fim_1s_s,
			meio_1s                     => meio_1s_s,
			pronto_med                  => pronto_med_s,
			fim_cal                     => fim_cal_s,
			erro                        => erro_s,
			contagem_mux                => contagem_mux_3bits,
			estado_hcsr                 => estado_hcsr,
			estado_tx_sistema_seguranca => estado_tx_sistema_seguranca,
			estado_rx                   => estado_rx,
			estado_tx                   => estado_tx,
			posicao_servo               => posicao_4bits,
			dado_recebido               => dado_recebido_s,
			distancia                   => distancia_bcd,
			dist_mem                    => dist_mem,
			dist_mais_sens              => dist_sens,
			angulo                      => angulo_bcd_hex
		);
	
	M0: mux_4x1_n --VALOR DO DISPLAY HEX0
		generic map(4)
		port map(
			-- Inputs
			D0  => distancia_bcd(3 downto 0), --SEL_MUX=00 (distancia0)
			D1  => dado_recebido_s(3 downto 0), --SEL_MUX=01 (DADO_RX1)
			D2  => dist_mem(3 downto 0), --SEL_MUX=10 (dist_mem0)
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
			D2  => dist_mem(7 downto 4), --SEL_MUX=10 (dist_mem1)
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
			D2  => dist_mem(11 downto 8), -- --SEL_MUX=10 (dist_mem2)
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
			D1  => dist_sens(3 downto 0), --SEL_MUX=00 (DADO_TX0)
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
			D1  => dist_sens(7 downto 4), -- DADO_TX1
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
			D0  => X"0",
			D1  => dist_sens(11 downto 8),
			D2  => estado_tx_sistema_seguranca,
			D3  => sistema_seguranca_estado,
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

	trigger <= trigger_s;

	calibrando <= calibrando_s;

	alerta_mov <= alerta_s;
	
	saida_serial      <= saida_serial_s;
	saida_serial_ch   <= saida_serial_s;
	saida_serial_mqtt <= saida_serial_s;
	
	alerta_proximidade <= alerta_proximidade_s;
	alerta_prox_mqtt   <= alerta_proximidade_s;

	db_medir   <= medir_s;
	db_trigger <= trigger_s;
	db_echo    <= echo;
	db_mode    <= mode_s;
	db_fim_2s  <= fim_1s_s;
	db_erro    <= erro_s;

end architecture;