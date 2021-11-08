--------------------------------------------------------------------
-- Arquivo   : contador_bcd_4digitos.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : contador bcd com 4 digitos (modulo 10.000) 
--             descricao VHDL comportamental
--             1) reset sincrono
--             2) saida de fim de contagem para 9999
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/09/2020  1.0     Edson Midorikawa  versao inicial
--     26/09/2020  1.1     Edson Midorikawa  revisao
--     19/09/2021  1.2     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_bcd_4digitos is 
    port ( clock, zera, conta:     in  std_logic;
           dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
           fim:                    out std_logic
    );
end contador_bcd_4digitos;

architecture comportamental of contador_bcd_4digitos is

    signal s_dig3, s_dig2, s_dig1, s_dig0 : unsigned(3 downto 0);

begin

    process (clock)
    begin
        if (clock'event and clock = '1') then
            if (zera = '1') then  -- reset sincrono
                s_dig0 <= "0000";
                s_dig1 <= "0000";
                s_dig2 <= "0000";
                s_dig3 <= "0000";
            elsif ( conta = '1' ) then
                if (s_dig0 = "1001") then
                    s_dig0 <= "0000";
                    if (s_dig1 = "1001") then
                        s_dig1 <= "0000";
                        if (s_dig2 = "1001") then
                            s_dig2 <= "0000";
                            if (s_dig3 = "1001") then
                                s_dig3 <= "0000";
                            else
                                s_dig3 <= s_dig3 + 1;
                            end if;
                        else
                            s_dig2 <= s_dig2 + 1;
                        end if;
                    else
                        s_dig1 <= s_dig1 + 1;
                    end if;
                else
                    s_dig0 <= s_dig0 + 1;
                end if;
            end if;
        end if;
    end process;

    -- fim de contagem (comando VHDL when else)
    fim <= '1' when s_dig3="1001" and s_dig2="1001" and 
                    s_dig1="1001" and s_dig0="1001" else 
           '0';

    -- saidas
    dig3 <= std_logic_vector(s_dig3);
    dig2 <= std_logic_vector(s_dig2);
    dig1 <= std_logic_vector(s_dig1);
    dig0 <= std_logic_vector(s_dig0);

end comportamental;
