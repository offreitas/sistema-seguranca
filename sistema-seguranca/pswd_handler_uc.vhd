library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pswd_handler_uc is 
    port (
        -- Input
        clock    : in std_logic;
        reset    : in std_logic;
        event    : in std_logic;
        pswd_ok  : in std_logic;
        timeover : in std_logic;
        -- Output
        wait_pswd : out std_logic;
        auth      : out std_logic;
        -- Debug
        db_state : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of pswd_handler_uc is
    type type_state is
        (
            idle, waiting, authorized
        );

    signal Ecurr : type_state;
    signal Enext : type_state;
begin
    -- State memory
    process (clock)
    begin
        if clock'event and clock = '1' then
            Ecurr <= Enext;
        end if;
    end process;

    -- Next state logic
    process (event, timeover, Ecurr)
    begin
        case Ecurr is
            when idle =>
                if event = '1' then
                    Enext <= waiting;
                else
                    Enext <= idle;
                end if;

            when waiting =>
                if pswd_ok = '1' then
                    Enext <= authorized;
                elsif timeover = '1' then
                    Enext <= idle;
                else
                    Enext <= waiting;
                end if;

            when authorized => Enext <= idle;
        end case;
    end process;

    -- Output logic
    with Ecurr select
        wait_pswd <= '1' when waiting, '0' when others;

    with Ecurr select
        auth <= '1' when authorized, '0' when others;

    -- Debug
    with Ecurr select
        db_state <=
            "0000" when idle,
            "0001" when waiting,
            "0010" when authorized;
end architecture;