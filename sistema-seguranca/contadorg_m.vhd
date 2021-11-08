-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : contadorg_m.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
-------------------------------------------------------------------------
-- Descricao : contador binario, modulo m, com parametro M generic,
--             sinais para clear assincrono (zera_as) e sincrono (zera_s)
--             e saidas de fim e meio de contagem
-- 
--             calculo do numero de bits do contador em funcao do modulo:
--             N = natural(ceil(log2(real(M))))
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao
--     08/06/2020  1.1     Edson Midorikawa  revisao e melhoria de codigo 
--     09/09/2020  1.2     Edson Midorikawa  revisao 
-------------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity contadorg_m is
    generic (
        constant M: integer := 50 -- modulo do contador
    );
   port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic 
   );
end entity contadorg_m;

architecture comportamental of contadorg_m is
    signal IQ: integer range 0 to M-1;
begin
  
    process (clock,zera_as,zera_s,conta,IQ)
    begin
        if zera_as='1' then IQ <= 0;   
        elsif rising_edge(clock) then
            if zera_s='1' then IQ <= 0;
            elsif conta='1' then 
                if IQ=M-1 then IQ <= 0; 
                else IQ <= IQ + 1; 
                end if;
            else IQ <= IQ;
            end if;
        end if;

        -- fim de contagem    
        if IQ=M-1 then fim <= '1'; 
        else fim <= '0'; 
        end if;

        -- meio da contagem
        if IQ=M/2-1 then meio <= '1'; 
        else meio <= '0'; 
        end if;

        Q <= std_logic_vector(to_unsigned(IQ, Q'length));

    end process;

end comportamental;
