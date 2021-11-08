library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_uc is
    port (
        -- Inputs
        clock      : in std_logic;
        reset      : in std_logic;
        ligar      : in std_logic;
        fim_2s     : in std_logic;
        meio_2s     : in std_logic;
        pronto_med : in std_logic;
        pronto_tx  : in std_logic;
        -- Outputs
        zera       : out std_logic;
        posiciona  : out std_logic;
        medir      : out std_logic;
        transmitir : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture sonar_uc_arch of sonar_uc is

    type tipo_estado is (idle, preparacao, medida, espera_med, transmissao, localizacao);
    signal Eatual : tipo_estado;
    signal Eprox  : tipo_estado;

begin

    -- Memoria de estado
    process(clock, reset)
    begin
        if (reset = '1' or ligar = '0') then
            Eatual <= idle;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    -- Logica de proximo estado
    process(ligar, fim_2s, pronto_med, pronto_tx, Eatual)
    begin
        case Eatual is
            when idle => if ligar = '1' then Eprox <= preparacao;
                         else                Eprox <= idle;
                         end if;

            when preparacao => Eprox <= medida;

            when medida => Eprox <= espera_med;
									
            when espera_med => if    pronto_med = '1' then Eprox <= transmissao;
                               elsif fim_2s     = '1' then Eprox <= medida;
                               else                        Eprox <= espera_med;
                               end if;

            when transmissao => if pronto_tx = '1' then Eprox <= localizacao;
                                else                    Eprox <= transmissao;
                                end if;

            when localizacao => if fim_2s = '1' then Eprox <= medida;
                                else                 Eprox <= localizacao;
                                end if;

            when others => Eprox <= idle;
        end case;
    end process;

    -- Logica de saida
    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        medir <= '1' when medida, '0' when others;

    with Eatual select
        transmitir <= '1' when transmissao, '0' when others;
    
    with Eatual select
        posiciona <= '1' when localizacao, '0' when others;

    -- Debug
    with Eatual select
        db_estado <= "0000" when idle,
                     "0001" when preparacao,
                     "0010" when medida,
                     "0011" when espera_med,
                     "0100" when transmissao,
                     "0101" when localizacao;

end architecture;