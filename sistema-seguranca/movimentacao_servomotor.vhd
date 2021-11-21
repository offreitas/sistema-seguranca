library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity movimentacao_servomotor is
    port (
        -- Inputs
        clock     : in std_logic;
        reset     : in std_logic;
        posiciona : in std_logic;
        -- Outputs
        pwm      : out std_logic;
        fim_1s   : out std_logic;
        meio_1s  : out std_logic;
        last_pos : out std_logic;
        posicao  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture mov_servo_arch of movimentacao_servomotor is

    -- Contador Up Down Generico
    component contadorg_updown_m is
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            clock:   in  std_logic;
            zera_as: in  std_logic;
            zera_s:  in  std_logic;
            conta:   in  std_logic;
            Q:       out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            inicio:  out std_logic;
            fim:     out std_logic;
            meio:    out std_logic 
        );
    end component;

    -- Controle Servo Revisado
    component controle_servo_3 is
        port (
            -- Inputs
            clock   : in  std_logic;
            reset   : in  std_logic;
            posicao : in  std_logic_vector(3 downto 0);
            -- Output
            pwm : out std_logic;
            -- Debug
            db_reset   : out std_logic;
            db_pwm     : out std_logic;
            db_posicao : out std_logic_vector(3 downto 0)
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

    -- Sinais
    signal conta_updown   : std_logic;
    signal tick, off_tick : std_logic;
    signal pwm_s          : std_logic;
    signal posicao_s      : std_logic_vector(3 downto 0);

begin
    -- Instancias
    U1: contadorg_updown_m
        generic map(11)
        port map(
            -- Inputs
            clock   => clock,
            zera_as => reset,
            zera_s  => '0',
            conta   => off_tick,
            -- Outputs
            Q      => posicao_s,
            inicio => open,
            fim    => last_pos,
            meio   => open
        );
    
    U2: controle_servo_3
        port map(
            -- Inputs
            clock   => clock,
            reset   => reset,
            posicao => posicao_s,
            -- Output
            pwm => pwm,
            -- Debug
            db_reset   => open,
            db_pwm     => open,
            db_posicao => open
        );

    U3: contadorg_m
        generic map(100000000) -- 1s = 50000000; 2s = 100000000
        port map(
            -- Inputs
            clock   => clock,
            zera_as => reset,
            zera_s  => '0',
            conta   => posiciona,
            -- Outputs
            Q    => open,
            fim  => tick,
            meio => off_tick
        );

    -- Output
    posicao <= posicao_s;
    fim_1s  <= tick;
    meio_1s <= off_tick;

end architecture;