library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tx_dados is
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
end entity;

architecture tx_sonar_arch of tx_dados is

    -- Multiplexador 8x1
    component mux_8x1_n is
        generic (
            constant BITS: integer := 4
        );
        port ( 
            D0 :     in  std_logic_vector (BITS-1 downto 0);
            D1 :     in  std_logic_vector (BITS-1 downto 0);
            D2 :     in  std_logic_vector (BITS-1 downto 0);
            D3 :     in  std_logic_vector (BITS-1 downto 0);
            D4 :     in  std_logic_vector (BITS-1 downto 0);
            D5 :     in  std_logic_vector (BITS-1 downto 0);
            D6 :     in  std_logic_vector (BITS-1 downto 0);
            D7 :     in  std_logic_vector (BITS-1 downto 0);
            SEL:     in  std_logic_vector (2 downto 0);
            MUX_OUT: out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    -- Contador
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

    -- UART 8N2
    component uart_8N2 is
        port (
            -- Inputs
            clock          : in std_logic;
            reset          : in std_logic;
            transmite_dado : in std_logic;
            dado_serial    : in std_logic;
            recebe_dado    : in std_logic;
            dados_ascii    : in std_logic_vector(7 downto 0);
            -- Outputs
            saida_serial     : out std_logic;
            pronto_tx        : out std_logic;
            tem_dado         : out std_logic;
            pronto_rx        : out std_logic;
            dado_recebido_rx : out std_logic_vector(7 downto 0);
            -- Debug
            db_transmite_dado : out std_logic;
            db_saida_serial   : out std_logic;
            db_recebe_dado    : out std_logic;
            db_dado_serial    : out std_logic;
            db_estado_tx      : out std_logic_vector(3 downto 0);
            db_estado_rx      : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Sinais de angulo
    signal angulo2_ascii : std_logic_vector(7 downto 0);
    signal angulo1_ascii : std_logic_vector(7 downto 0);
    signal angulo0_ascii : std_logic_vector(7 downto 0);

    -- Sinais de distancia
    signal distancia2_ascii : std_logic_vector(7 downto 0);
    signal distancia1_ascii : std_logic_vector(7 downto 0);
    signal distancia0_ascii : std_logic_vector(7 downto 0);

    -- Prefixo ascii
    signal prefix_ascii : std_logic_vector(3 downto 0) := "0011";

    -- Sinais mux
    signal fim_tx        : std_logic;
    signal fim_mux       : std_logic;
    signal selmux        : std_logic_vector(2 downto 0);
    signal mux_out_ascii : std_logic_vector(7 downto 0);

    -- Sinais uart
    signal partida : std_logic;
	 signal recebe_s: std_logic;
	 signal fim_rx  : std_logic;

begin

    -- Conversao do angulo para ascii
    angulo2_ascii <= prefix_ascii & angulo2;
    angulo1_ascii <= prefix_ascii & angulo1;
    angulo0_ascii <= prefix_ascii & angulo0;

    -- Conversao da distancia para ascii
    distancia2_ascii <= prefix_ascii & distancia2;
    distancia1_ascii <= prefix_ascii & distancia1;
    distancia0_ascii <= prefix_ascii & distancia0;

    -- Logica de partida
    partida <= transmitir and (not fim_tx);
	 
    -- Logica recebe dado
    recebe_s <= fim_rx;

    -- Instancias
    U1: mux_8x1_n
        generic map(8)
        port map(
            -- Inputs
            D0      => B"0101_0001", -- Q
            D1      => B"1111_0101", -- u
            D2      => B"0110_0001", -- a
            D3      => B"0111_0010", -- r
            D4      => B"0111_0100", -- t
            D5      => B"0110_1111", -- o
            D6      => B"0000_0000", --
            D7      => B"0000_0000", --
            SEL     => selmux,
            -- Output
            MUX_OUT => mux_out_ascii
        );
    
    U2: contadorg_m
        generic map(8)
        port map(
            -- Inputs
            clock   => clock,
            zera_as => reset,
            zera_s  => '0',
            conta   => fim_tx,
            -- Outputs
            Q    => selmux,
            fim  => fim_mux,
            meio => open
        );

    U3: uart_8N2
        port map(
            -- Inputs
            clock          => clock,
            reset          => reset,
            transmite_dado => partida,
            dado_serial    => dado_serial,
            recebe_dado    => fim_rx,
            dados_ascii    => mux_out_ascii,
            -- Outputs
            saida_serial     => saida_serial,
            pronto_tx        => fim_tx,
            tem_dado         => open,
            pronto_rx        => fim_rx,
            dado_recebido_rx => dado_recebido,
            -- Debug
            db_transmite_dado => db_transmitir,
            db_saida_serial   => db_saida_serial,
            db_recebe_dado    => open,
            db_dado_serial    => open,
            db_estado_tx      => db_estado_tx,
            db_estado_rx      => db_estado_rx
        );

    -- Output
    pronto       <= fim_mux and fim_tx;
    contagem_mux <= selmux;
    pronto_rx    <= fim_rx;

end architecture;