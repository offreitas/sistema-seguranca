library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_8N2 is
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
end entity;

architecture uart_8N2_arch of uart_8N2 is

    -- Circuito de transmissao serial 8N2
    component tx_serial_8N2 is
        port (
            -- Inputs
            clock       : in std_logic;
            reset       : in std_logic;
            partida     : in std_logic;
            dados_ascii : in std_logic_vector (7 downto 0);
            -- Outputs
            saida_serial : out std_logic;
            pronto_tx    : out std_logic;
            -- Debug
            db_partida      : out std_logic;
            db_saida_serial : out std_logic;
            db_estado       : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Circuito de recepcao serial 8N2
    component rx_serial_8N2 is
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
    end component;

begin

    -- Instancias
    U1: tx_serial_8N2
        port map(
            -- Inputs
            clock       => clock,
            reset       => reset,
            partida     => transmite_dado,
            dados_ascii => dados_ascii,
            -- Outputs
            saida_serial => saida_serial,
            pronto_tx    => pronto_tx,
            -- Debug
            db_partida      => db_transmite_dado,
            db_saida_serial => db_saida_serial,
            db_estado       => db_estado_tx
        );

    U2: rx_serial_8N2
        port map(
            -- Entradas
            clock       => clock,
            reset       => reset,
            dado_serial => dado_serial,
            recebe_dado => recebe_dado,
            -- Saidas
            pronto_rx     => pronto_rx,
            tem_dado      => tem_dado,
            dado_recebido => dado_recebido_rx,
            -- Debug
            db_recebe_dado => db_recebe_dado,
            db_dado_serial => db_dado_serial,
            db_estado      => db_estado_rx
        );

end architecture;