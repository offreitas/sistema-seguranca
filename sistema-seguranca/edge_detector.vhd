-----------------------------------------------------------------------
-- Arquivo   : edge_detector.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
-----------------------------------------------------------------------
-- Descricao : detetor de borda
--             >
--             > baseado no codigo disponivel em
--             > http://fpgacenter.com/examples/basic/edge_detector.php
--             >
-----------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
-----------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.ALL;

entity edge_detector is
    port ( clk         : in   std_logic;
           signal_in   : in   std_logic;
           output      : out  std_logic
    );
end edge_detector;

architecture Behavioral of edge_detector is
     signal signal_d: std_logic;
begin
    process(clk)
    begin
        if clk= '1' and clk'event then
           signal_d <= signal_in;
        end if;
    end process;

    output<= (not signal_d) and signal_in; 

end Behavioral;
