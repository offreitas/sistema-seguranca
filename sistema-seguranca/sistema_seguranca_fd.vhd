library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sistema_seguranca_fd is
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
		clear_sig   : in std_logic;
		mode        : in std_logic;
		auth        : in std_logic;
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
		ligar_reg                   : out std_logic;
		mode_reg                    : out std_logic;
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
end entity;

architecture sistema_seguranca_fd_arch of sistema_seguranca_fd is

	-- Controle da movimentação do servo motor
	component movimentacao_servomotor is
		port (
			-- Inputs
			clock : in std_logic;
			reset : in std_logic;
			ligar : in std_logic;
			-- Outputs
			pwm      : out std_logic;
			fim_1s   : out std_logic;
			meio_1s  : out std_logic;
			last_pos : out std_logic;
			posicao  : out std_logic_vector(3 downto 0)
		);
	end component;

	-- Transmissao Dados sistema_seguranca
    component tx_dados is
        port (
			-- Inputs
			clock      : in std_logic;
			reset      : in std_logic;
			transmitir : in std_logic;
			dado_serial: in std_logic;
			angulo2    : in std_logic_vector(3 downto 0);
			angulo1    : in std_logic_vector(3 downto 0);
			angulo0    : in std_logic_vector(3 downto 0);
			distancia2 : in std_logic_vector(3 downto 0);
			distancia1 : in std_logic_vector(3 downto 0);
			distancia0 : in std_logic_vector(3 downto 0);
			-- Outputs
			saida_serial : out std_logic;
			pronto       : out std_logic;
			pronto_rx    : out std_logic;
			contagem_mux : out std_logic_vector(2 downto 0);
			dado_recebido: out std_logic_vector(7 downto 0);
			-- Debug
			db_transmitir   : out std_logic;
			db_saida_serial : out std_logic;
			db_estado_tx    : out std_logic_vector(3 downto 0);
			db_estado_rx    : out std_logic_vector(3 downto 0)
		);
    end component;

    -- Detetor de Borda
    component edge_detector is
        port (
            -- Inputs
            clk       : in   std_logic;
            signal_in : in   std_logic;
            -- Output
            output : out  std_logic
        );
    end component;
	
	-- Interface HCSR04
	component interface_hcsr04
		port (
			-- Inputs
			clock : in std_logic;
			reset : in std_logic;
			medir : in std_logic;
			echo  : in std_logic;
			timer : in std_logic;
			-- Outputs
			trigger : out std_logic;
			pronto  : out std_logic;
			erro    : out std_logic;
			medida  : out std_logic_vector(11 downto 0); -- 3 digitos BCD
			-- Debug
			db_estado : out std_logic_vector(3 downto 0)
		);
	end component;
	
	component comparador_85 is
		port (
			i_A3   : in  std_logic; -- i_A3, i_A2, i_A1 e i_A0
									-- sao os bits que formam a palavra A
			i_B3   : in  std_logic; -- i_B3, i_B2, i_B1 e i_B0 
									-- sao os bits que formam a palavra B
			i_A2   : in  std_logic;
			i_B2   : in  std_logic;
			i_A1   : in  std_logic;
			i_B1   : in  std_logic;
			i_A0   : in  std_logic;
			i_B0   : in  std_logic;
			i_AGTB : in  std_logic; -- i_AGTB, i_ALTB e i_AEQB sao inputs
									-- de cascateamento
			i_ALTB : in  std_logic;
			i_AEQB : in  std_logic;
			o_AGTB : out std_logic; -- Saida em alto se A>B
			o_ALTB : out std_logic; -- Saida em alto se A<B
			o_AEQB : out std_logic  -- Saida em alto se A=B
		);
	end component;

	-- RAM com distancias
	component ram_dist is
		port (
			-- Inputs
			clock : in std_logic;
			wr    : in std_logic;
			addr  : in std_logic_vector(3 downto 0);
			din   : in std_logic_vector(11 downto 0);
			-- Output
			dout : out std_logic_vector(11 downto 0)
		);
	end component;
	
	-- Registrador generico
	component registrador_n is
		generic (
			constant N: integer := 8 
		);
		port (
			clock:  in  std_logic;
			clear:  in  std_logic;
			enable: in  std_logic;
			D:      in  std_logic_vector (N-1 downto 0);
			Q:      out std_logic_vector (N-1 downto 0) 
		);
	end component;

	-- Contador Generico
    component contadorg_m is
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            -- Inputs
            clock   : in std_logic;
            zera_as : in std_logic;
            zera_s  : in std_logic;
            conta   : in std_logic;
            -- Outputs
            Q    : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            fim  : out std_logic;
            meio : out std_logic 
        );
    end component;

	-- Full Adder
	component fullAdder is
		port(
			-- Inputs
			a, b, cin : in std_logic;
			-- Outputs
			s, cout   : out std_logic
		);
	end component;

	-- Sinais
	signal clear_reg_s      : std_logic;
	signal pronto_med_s     : std_logic;
	signal trigger_s        : std_logic;
	signal write_stop       : std_logic;
	signal write_enable     : std_logic;
	signal last_pos         : std_logic;
	signal last_pos_ed      : std_logic;
	signal calibra          : std_logic;
	signal ligar_servo      : std_logic;
	signal fim_1s_s         : std_logic;
	signal rst_hcsr         : std_logic;
	signal clear_ligar      : std_logic;
	signal reset_hcsr       : std_logic;
	signal ligar_vec        : std_logic_vector(0 downto 0);
	signal ligar_reg_s      : std_logic_vector(0 downto 0);
	signal mode_vec         : std_logic_vector(0 downto 0);
	signal mode_reg_s       : std_logic_vector(0 downto 0);
	signal agtb_vector      : std_logic_vector(3 downto 0);
	signal altb_vector      : std_logic_vector(3 downto 0);
	signal aeqb_vector      : std_logic_vector(3 downto 0);
	signal altb_vector_reg  : std_logic_vector(3 downto 0);
	signal posicao_s        : std_logic_vector(3 downto 0);
	signal dado_recebido_s  : std_logic_vector(7 downto 0);
	signal distancia_hcsr   : std_logic_vector(11 downto 0);
	signal distancia_ram    : std_logic_vector(11 downto 0);
	signal distancia_reg    : std_logic_vector(11 downto 0);
	signal sensibilidade    : std_logic_vector(11 downto 0);
	signal dist_sens        : std_logic_vector(11 downto 0);
	signal carry            : std_logic_vector(12 downto 0);
	signal angulo_rom       : std_logic_vector(23 downto 0);

begin

	-- Logica de sinais
	calibra      <= calibrando and last_pos_ed;
	write_enable <= (calibrando and (not write_stop)) or write_en;
	ligar_servo  <= posiciona;
	reset_hcsr   <= reset or clear_reg or auth;

	-- Inicializacao
	agtb_vector(0) <= '0';
	altb_vector(0) <= '0';
	aeqb_vector(0) <= '1';

	carry(0) <= '1';

	sensibilidade <= not B"0000_0000_0010";

	ligar_vec(0) <= ligar;
	mode_vec(0)  <= mode;

	-- Instancias
    U1_TX: tx_dados
        port map(
            -- Inputs
            clock       => clock,
            reset       => reset, 
            transmitir  => transmitir,
			dado_serial => dado_serial,
            angulo2     => angulo_rom(19 downto 16),
            angulo1     => angulo_rom(11 downto 8),
            angulo0     => angulo_rom(3 downto 0),
            distancia2  => distancia_hcsr(11 downto 8),
            distancia1  => distancia_hcsr(7 downto 4),
            distancia0  => distancia_hcsr(3 downto 0),
            -- Outputs
            saida_serial  => saida_serial,
            pronto        => pronto_tx,
			pronto_rx     => open,
			contagem_mux  => contagem_mux,
			dado_recebido => dado_recebido_s,
            -- Debug
            db_transmitir   => open,
            db_saida_serial => open,
            db_estado_tx    => estado_tx,
			db_estado_rx    => estado_rx
        );

	U2_MOV: movimentacao_servomotor 
		port map(
			-- Inputs
			clock => clock,
			reset => reset,
			ligar => ligar_servo,
			-- Outputs
			pwm      => pwm,
			fim_1s   => fim_1s_s,
			meio_1s  => meio_1s,
			last_pos => last_pos,
			posicao  => posicao_s
		);

	U3_HCS: interface_hcsr04 
		port map(
			-- Entradas
			clock => clock,
			reset => reset_hcsr,
			medir => medir,
			echo  => echo,
			timer => fim_1s_s,
			-- Saidas
			trigger => trigger,
			pronto  => pronto_med_s,
			erro    => erro,
			medida  => distancia_hcsr, -- 3 digitos BCD
			-- Debug
			db_estado => estado_hcsr
		);										 

	GEN_COMP: for i in 0 to 2 generate
		UX_CPX: comparador_85
			port map(
				-- Inputs
				i_A3 => distancia_hcsr(4*i + 3),
				i_B3 => dist_sens(4*i + 3),
				i_A2 => distancia_hcsr(4*i + 2),
				i_B2 => dist_sens(4*i + 2),
				i_A1 => distancia_hcsr(4*i + 1),
				i_B1 => dist_sens(4*i + 1),
				i_A0 => distancia_hcsr(4*i),
				i_B0 => dist_sens(4*i),
				-- Cascateamento
				i_AGTB => agtb_vector(i),
				i_ALTB => altb_vector(i),
				i_AEQB => aeqb_vector(i),
				-- Outputs
				o_AGTB => agtb_vector(i + 1),
				o_ALTB => altb_vector(i + 1),
				o_AEQB => aeqb_vector(i + 1)
			);
	end generate;

	GEN_ADD: for i in 0 to 11 generate
		UX_ADX: fullAdder
			port map(
				-- Inputs
				a   => distancia_ram(i),
				b   => sensibilidade(i),
				cin => carry(i),
				-- Outputs
				s    => dist_sens(i),
				cout => carry(i + 1)
			);
	end generate;

	U7_REG: registrador_n
		generic map(4)
		port map(
			clock  => clock,
			clear  => clear_reg_s,
			enable => pronto_med_s,
			D      => altb_vector,
			Q      => altb_vector_reg
		);

	U8_RAM: ram_dist
		port map(
			-- Inputs
			clock => clock,
			wr    => write_enable,
			addr  => posicao_s,
			din   => distancia_hcsr,
			-- Output
			dout => distancia_ram
		);
	
	-- Conta numero de varreduras: n + 1
	-- Sendo 2, varre 2 + 1 = 3 vezes
	U9_CONT: contadorg_m
		generic map(2)
		port map(
			-- Inputs
			clock   => clock,
			zera_as => reset,
			zera_s  => '0',
			conta   => calibra,
			-- Outputs
			Q    => open,
			fim  => write_stop,
			meio => open
		);

	U10_ED: edge_detector
		port map(
			-- Inputs
            clk       => clock,
            signal_in => last_pos,
            -- Output
            output => last_pos_ed
		);

	U11_RL: registrador_n
		generic map(1)
		port map(
			-- Inputs
			clock  => clock,
			clear  => clear_sig,
			enable => auth,
			D      => ligar_vec,
			-- Output
			Q => ligar_reg_s
		);

	U12_RM: registrador_n
		generic map(1)
		port map(
			-- Inputs
			clock  => clock,
			clear  => clear_sig,
			enable => auth,
			D      => mode_vec,
			-- Output
			Q => mode_reg_s
		);

	U13_RD: registrador_n
		generic map(12)
		port map(
			-- Inputs
			clock  => clock,
			clear  => reset,
			enable => pronto_med_s,
			D      => distancia_hcsr,
			-- Output
			Q => distancia_reg
		);

	-- Outputs
	fim_1s             <= fim_1s_s;
	dado_recebido      <= dado_recebido_s;
	pronto_med         <= pronto_med_s;
	posicao_servo      <= posicao_s;
	distancia          <= distancia_reg;
	dist_mem           <= distancia_ram;
	angulo             <= angulo_rom;
	fim_cal            <= write_stop;
	alerta_proximidade <= altb_vector_reg(3);
	dist_mais_sens     <= dist_sens;
	ligar_reg          <= ligar_reg_s(0);
	mode_reg           <= mode_reg_s(0);

end architecture;