library ieee;
use ieee.std_logic_1164.all;

entity fullAdder is
    port(
        -- Inputs
        a, b, cin : in std_logic;
        -- Outputs
        s, cout   : out std_logic
    );
end entity;

architecture fa_arch of fullAdder is

begin
    s    <= (a xor b) xor cin;
    cout <= (a and b) or (cin and a) or (cin and b);
end architecture;