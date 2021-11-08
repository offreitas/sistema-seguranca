library ieee;
use ieee.std_logic_1164.all;

entity tx_serial_tick_uc is 
    port (
        -- Inputs
        clock   : in std_logic;
        reset   : in std_logic;
        partida : in std_logic;
        tick    : in std_logic;
        fim     : in std_logic;
        -- Outputs
        zera    : out std_logic;
        conta   : out std_logic;
        carrega : out std_logic; 
        desloca : out std_logic; 
        pronto  : out std_logic;
        -- Debug
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture tx_serial_tick_uc_arch of tx_serial_tick_uc is

    type tipo_estado is (inicial, preparacao, espera, transmissao, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (partida, tick, fim, Eatual) 
    begin

      case Eatual is

        when inicial => if partida = '1' then Eprox <= preparacao;
                        else                  Eprox <= inicial;
                        end if;

        when preparacao => Eprox <= espera;

        when espera => if    (tick = '1' and fim = '0') then Eprox <= transmissao;
                       elsif (tick = '0' and fim = '0') then Eprox <= espera;
                       else                                  Eprox <= final;
                       end if;

        when transmissao => if fim = '0' then Eprox <= espera;
                            else              Eprox <= final;
                            end if;
 
        when final => Eprox <= inicial;

        when others => Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        carrega <= '1' when preparacao, '0' when others;

    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        desloca <= '1' when transmissao, '0' when others;

    with Eatual select
        conta <= '1' when transmissao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    -- Debug
    with Eatual select
        db_estado <= "0000" when inicial,
                     "0001" when preparacao,
                     "0010" when espera,
                     "0011" when transmissao,
                     "0100" when final;

end tx_serial_tick_uc_arch;
