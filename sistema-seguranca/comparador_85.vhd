library ieee;
use ieee.std_logic_1164.all;

entity comparador_85 is
    port (
        i_A3   : in  std_logic; -- i_A3, i_A2, i_A1 e i_A0
                                -- sao os bits que formam a palavra A
        i_B3   : in  std_logic; -- i_B3, i_B2, i_B1 e i_B0 
                                -- sao os bits que formam a palavra B
        i_A2   : in  std_logic;
        i_B2   : in  std_logic;
        i_A1   : in  std_logic;
        i_B1   : in  std_logic;
        i_A0   : in  std_logic;
        i_B0   : in  std_logic;
        i_AGTB : in  std_logic; -- i_AGTB, i_ALTB e i_AEQB sao inputs
                                -- de cascateamento
        i_ALTB : in  std_logic;
        i_AEQB : in  std_logic;
        o_AGTB : out std_logic; -- Saida em alto se A>B
        o_ALTB : out std_logic; -- Saida em alto se A<B
        o_AEQB : out std_logic  -- Saida em alto se A=B
    );
end entity comparador_85;

architecture dataflow of comparador_85 is
    signal agtb : std_logic;
    signal aeqb : std_logic;
    signal altb : std_logic;
begin
    -- equacoes dos sinais: pagina 462, capitulo 6 do livro-texto
    -- Wakerly, J.F. Digital Design - Principles and Practice,
    --                                                  4th Edition
    -- veja tambem datasheet do CI SN7485 (Function Table) 
    agtb <= (i_A3 and not(i_B3)) or
            (not(i_A3 xor i_B3) and i_A2 and not(i_B2)) or
            (not(i_A3 xor i_B3) and not(i_A2 xor i_B2) and i_A1 
            and not(i_B1)) or (not(i_A3 xor i_B3) and 
            not(i_A2 xor i_B2) and not(i_A1 xor i_B1) and i_A0 
            and not(i_B0));
    aeqb <= not((i_A3 xor i_B3) or (i_A2 xor i_B2) or 
            (i_A1 xor i_B1) or (i_A0 xor i_B0));
    altb <= not(agtb or aeqb);
    -- saidas
    o_AGTB <= agtb or (aeqb and (not(i_AEQB) and not(i_ALTB)));
    o_ALTB <= altb or (aeqb and (not(i_AEQB) and not(i_AGTB)));
    o_AEQB <= aeqb and i_AEQB;
  
end architecture dataflow;
