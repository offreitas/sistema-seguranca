library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_uc is
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
end entity;

architecture hcsr04_uc_arch of interface_hcsr04_uc is

    type tipo_estado is (inicial, preparacao, pulso, espera, medicao, registro, final);
    signal Eatual : tipo_estado;
    signal Eprox  : tipo_estado;
    
begin

    -- Memoria de estado
    process (clock, reset)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif (clock'event and clock = '1') then
            Eatual <= Eprox;
        end if;
    end process;

    -- Logica de proximo estado
    process (medir, echo, fim_med, timer, Eatual)
    begin
        case Eatual is
            when inicial => 
                if medir = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= inicial;
                end if;

            when preparacao => Eprox <= pulso;

            when pulso => Eprox <= espera;

            when espera =>
                if echo = '1' then
                    Eprox <= medicao;
                else
                    Eprox <= espera;
                end if;

            when medicao =>
                if fim_med = '1' then
                    Eprox <= registro;
                elsif echo = '0' then
                    Eprox <= registro;
                else
                    Eprox <= medicao;
                end if;

            when registro => Eprox <= final;

            when final => Eprox <= inicial;

            when others => Eprox <= inicial;
        end case;
    end process;

    -- Logica de saida
    with Eatual select
        zera <= '1' when preparacao, '0' when others;
        
    with Eatual select
        gera <= '1' when pulso, '0' when others;

    with Eatual select
        registra <= '1' when registro, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    -- Saida de deuaracao
    with Eatual select
        db_estado <=
            "0000" when inicial,
            "0001" when preparacao,
            "0010" when pulso,
            "0011" when espera,
            "0100" when medicao,
            "0101" when registro,
            "0110" when final;

end architecture;