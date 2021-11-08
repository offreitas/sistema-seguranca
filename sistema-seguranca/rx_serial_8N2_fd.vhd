library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity rx_serial_8N2_fd is
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
end entity;

architecture rx_serial_8N2_fd_arch of rx_serial_8N2_fd is

    component deslocador_n is
        generic (
            constant N: integer := 11
        );
        port (
            clock, reset:                     in  std_logic;
            carrega, desloca, entrada_serial: in  std_logic; 
            dados:                            in  std_logic_vector (N-1 downto 0);
            saida:                            out std_logic_vector (N-1 downto 0)
        );
    end component;

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

    component contadorg_m is
        generic (
            constant M: integer := 50 -- modulo do contador
        );
       port (
            clock, zera_as : in  std_logic;
            zera_s, conta  : in  std_logic;
            Q              : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            fim, meio      : out std_logic 
       );
    end component;

    signal s_zero, s_saida : std_logic_vector(7 downto 0) := (others => '0');

begin

    U1: deslocador_n  generic map (N => 8) port map (clock, reset, carrega, desloca, dado_serial, s_zero, s_saida);
    U2: contadorg_m   generic map (M => 10) port map (clock, reset, zera, conta, open, fim, open);
    U3: registrador_n generic map (N => 8) port map (clock, limpa, registra, s_saida, saida_serial);

    db_saida <= s_saida(0);

end architecture;