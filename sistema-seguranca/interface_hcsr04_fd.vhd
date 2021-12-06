library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity interface_hcsr04_fd is 
    port (
        -- Entradas
        clock    : in std_logic;
        zera     : in std_logic;
        conta    : in std_logic;
        registra : in std_logic;
        gera     : in std_logic;
        -- Saidas
        trigger   : out std_logic;
        fim       : out std_logic;
        distancia : out std_logic_vector(11 downto 0)
    );
end entity;

architecture hcsr04_fd_arch of interface_hcsr04_fd is 

    -- GERADOR DE PULSO
    component gerador_pulso is
        generic (
            largura: integer:= 25
        );
        port(
            clock:  in  std_logic;
            reset:  in  std_logic;
            gera:   in  std_logic;
            para:   in  std_logic;
            pulso:  out std_logic;
            pronto: out std_logic
        );
    end component;

    -- CONTADOR BCD DE 4 DIGITOS
    component contador_bcd_4digitos is 
        port (clock, zera, conta:     in  std_logic;
              dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
              fim:                    out std_logic
        );
    end component;
    
    --CONTADOR BINARIO
    component contadorg_m
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            clock, zera_as, zera_s, conta: in std_logic;
            Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            fim, meio: out std_logic 
        );
    end component;

    -- REGISTRADOR
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

    -- SINAIS
    signal dist_s : std_logic_vector(11 downto 0);

begin

    -- INSTANCIAS
    U1: gerador_pulso
        generic map(500)
        port map(
            -- Entradas
            clock  => clock,
            reset  => zera,
            gera   => gera,
            para   => '0',
            -- Saidas
            pulso  => trigger,
            pronto => open
        );
    
    U2: contadorg_m
        generic map(M=>4096)
        port map(
            clock => clock,
            zera_as => zera,
            zera_s => '0',
            conta => conta,
            Q => dist_s,
            fim => fim,
            meio => open
        );

    U3: registrador_n
        generic map(12)
        port map(
            -- Entradas
            clock  => clock,
            clear  => zera,
            enable => registra,
            D      => dist_s,
            -- Saidas
            Q => distancia
        );

end architecture;