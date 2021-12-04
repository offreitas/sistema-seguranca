library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity interface_hcsr04 is
    port (
        -- Entradas
        clock : in std_logic;
        reset : in std_logic;
        medir : in std_logic;
        echo  : in std_logic;
        timer : in std_logic;
        -- Saidas
        trigger   : out std_logic;
        pronto    : out std_logic;
        erro      : out std_logic;
        medida    : out std_logic_vector(11 downto 0);
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture hcsr04_arch of interface_hcsr04 is

    -- UNIDADE DE CONTROLE
    component interface_hcsr04_uc is
        port (
            -- Entradas
            clock   : in std_logic;
            reset   : in std_logic;
            medir   : in std_logic;
            echo    : in std_logic;
            fim_med : in std_logic;
            timer   : in std_logic;
            -- Saidas
            zera     : out std_logic;
            gera     : out std_logic;
            registra : out std_logic;
            pronto   : out std_logic;
            erro     : out std_logic;
            -- Debug
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    -- FLUXO DE DADOS
    component interface_hcsr04_fd is 
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
    end component;

    -- CONTADOR GENERICO
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

    -- SINAIS
    signal fim_med_s, tick            : std_logic;
    signal zera_s, gera_s, registra_s : std_logic;
    signal reset_uc, reset_fd, erro_s : std_logic;

begin
    -- Logica de sinais
    reset_uc <= reset or erro_s;
    reset_fd <= reset or zera_s or erro_s;

    -- INSTANCIAS
    U1: interface_hcsr04_uc 
        port map(
            -- Entradas
            clock    => clock,
            reset    => reset_uc,
            medir    => medir,
            echo     => echo,
            fim_med  => fim_med_s,
            timer    => timer,
            -- Saidas
            zera      => zera_s,
            gera      => gera_s,
            registra  => registra_s,
            pronto    => pronto,
            erro      => erro_s,
            db_estado => db_estado
        );

    U2: interface_hcsr04_fd
        port map(
            --Entradas
            clock    => clock,
            zera     => reset_fd,
            conta    => tick,
            registra => registra_s,
            gera     => gera_s,
            -- Saidas
            trigger   => trigger,
            fim       => fim_med_s,
            distancia => medida
        );

    U3: contadorg_m
        generic map(2941)
        port map(
            -- Entradas
            clock   => clock,
            zera_as => zera_s,
            zera_s  => reset,
            conta   => echo,
            -- Saidas
            Q    => open,
            fim  => tick,
            meio => open
        );

    erro <= erro_s;

end architecture;