library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pswd_handler is
    port (
        -- Input
        clock    : in std_logic;
        reset    : in std_logic;
        ligar    : in std_logic;
        mode     : in std_logic;
        desarmar : in std_logic;
        pswd_ok  : in std_logic;
        -- Output
        wait_pswd : out std_logic;
        auth      : out std_logic;
        -- Debug
        db_event : out std_logic;
        db_state : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of pswd_handler is
    -- Sinais
    signal reset_uc       : std_logic;
    signal wait_pswd_s    : std_logic;
    signal auth_s         : std_logic;
    signal event_edge     : std_logic;
    signal timeover_s     : std_logic;
    signal signal_in_vec  : std_logic_vector(5 downto 0);
    signal event_edge_vec : std_logic_vector(5 downto 0);
begin
    signal_in_vec(0) <= reset;
    signal_in_vec(1) <= ligar;
    signal_in_vec(2) <= not ligar;
    signal_in_vec(3) <= mode;
    signal_in_vec(4) <= not mode;
    signal_in_vec(5) <= desarmar;

    event_edge <= event_edge_vec(5) or event_edge_vec(4) or event_edge_vec(3) or event_edge_vec(2) or event_edge_vec(1) or event_edge_vec(0);

    GEN_EDGE: for i in 0 to 5 generate
        UX_ED: entity work.edge_detector (Behavioral)
            port map(
                -- Inputs
                clk       => clock,
                signal_in => signal_in_vec(i),
                -- Output
                output => event_edge_vec(i)
            );
    end generate;

    U5_CTR: entity work.contadorg_m (comportamental)
        generic map(500000000) -- 10 s = 500000000
        port map(
            -- Inputs
            clock   => clock,
            zera_as => auth_s,
            zera_s  => reset,
            conta   => wait_pswd_s,
            -- Outputs
            Q    => open,
            fim  => timeover_s,
            meio => open
       );

    U6_UC: entity work.pswd_handler_uc (rtl)
        port map(
            -- Input
            clock    => clock,
            reset    => reset,
            event    => event_edge,
            pswd_ok  => pswd_ok,
            timeover => timeover_s,
            -- Output
            wait_pswd => wait_pswd_s,
            auth      => auth_s,
            -- Debug
            db_state => db_state
        );

    auth      <= auth_s;
    wait_pswd <= wait_pswd_s;

    db_event <= event_edge;
    
end architecture;