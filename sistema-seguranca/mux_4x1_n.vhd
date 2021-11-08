-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : mux_4x1_n.vhd
-- Projeto   : Experiencia 6 - Sistema de Sonar (Parte 2)
-------------------------------------------------------------------------
-- Descricao : 
--             multiplexador 4x1 com entradas de BITS bits (generic)
--
-- adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL" 
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity mux_4x1_n is
    generic (
        constant BITS: integer := 4
    );
    port ( 
        D0 :     in  std_logic_vector (BITS-1 downto 0);
        D1 :     in  std_logic_vector (BITS-1 downto 0);
        D2 :     in  std_logic_vector (BITS-1 downto 0);
        D3 :     in  std_logic_vector (BITS-1 downto 0);
        SEL:     in  std_logic_vector (1 downto 0);
        MUX_OUT: out std_logic_vector (BITS-1 downto 0)
    );
end entity;

architecture behav of mux_4x1_n is
begin
    MUX_OUT <= D3 when (SEL = "11") else
               D2 when (SEL = "10") else
               D1 when (SEL = "01") else
               D0 when (SEL = "00") else
               (others => '1');
end behav;
