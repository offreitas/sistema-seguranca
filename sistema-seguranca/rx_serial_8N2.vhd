library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_serial_8N2 is
	port (
		-- Entradas
		clock, reset : in  std_logic;
		dado_serial  : in  std_logic;
		recebe_dado  : in  std_logic;
		-- Saidas
		pronto_rx     : out std_logic;
		tem_dado      : out std_logic;
		dado_recebido : out std_logic_vector(7 downto 0);
		-- Debug
		db_recebe_dado : out std_logic;
		db_dado_serial : out std_logic;
		db_estado      : out std_logic_vector(3 downto 0)
	);
end entity;

architecture rx_serial_8N2_arch of rx_serial_8N2 is
	component rx_serial_tick_uc is
		port (
			-- Entradas
			clock, reset     : in std_logic;
			dado, tick, fim  : in std_logic;
			recebe_dado      : in std_logic;
			-- Saidas
			zera, conta      : out std_logic;
			limpa            : out std_logic;
			carrega, desloca : out std_logic;
			registra         : out std_logic;
			pronto, tem_dado : out std_logic;
			db_estado        : out std_logic_vector(3 downto 0)
		);
	end component;

	component rx_serial_8N2_fd is
		port (
			-- Entradas
			clock, reset : in std_logic;
			zera, conta  : in std_logic;
			limpa        : in std_logic;
			carrega      : in std_logic;
			desloca      : in std_logic;
			registra     : in std_logic;
			dado_serial  : in std_logic;
			-- Saidas
			fim          : out std_logic;
			saida_serial : out std_logic_vector(7 downto 0);
			-- Debug
			db_saida : out std_logic
		);
	end component;

	component contadorg_m is
		generic (
			constant M: integer := 50 -- modulo do contador
		);
	   port (
			clock, zera_as, zera_s, conta: in std_logic;
			Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
			fim, meio: out std_logic 
	   );
	end component;

	signal s_reset, s_limpa, s_registra, s_tem_dado, s_dado : std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim : std_logic;
	signal copia_saida : std_logic_vector(7 downto 0);

begin

	-- sinal reset mapeado na GPIO (ativo em alto)
	s_reset <= reset;
	s_dado  <= dado_serial;

	-- unidade de controle
    U1_UC: rx_serial_tick_uc port map (clock, s_reset, s_dado, s_tick, s_fim, recebe_dado,
									   s_zera, s_conta, s_limpa, s_carrega, s_desloca,
									   s_registra, pronto_rx, s_tem_dado, db_estado);

	-- fluxo de dados
	U2_FD: rx_serial_8N2_fd port map (clock, s_reset, s_zera, s_conta, s_limpa, s_carrega,
									  s_desloca, s_registra, s_dado, s_fim, copia_saida,
									  open);

	-- gerador de tick
	-- fator de divisao 50MHz para 9600 bauds = 5208 (13 bits)
	U3_TICK: contadorg_m generic map (M => 5208) port map (clock, s_reset, s_zera, '1', open, open, s_tick);

	-- Saidas
	dado_recebido <= copia_saida;
	tem_dado      <= s_tem_dado;
	
	-- debug
	db_recebe_dado <= recebe_dado;
	db_dado_serial <= s_dado;

end architecture;
