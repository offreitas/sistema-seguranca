library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ram_dist is
    port (
        -- Inputs
        clock : in std_logic;
        wr    : in std_logic;
        addr  : in std_logic_vector(4 downto 0);
        din   : in std_logic_vector(11 downto 0);
        -- Output
        dout : out std_logic_vector(11 downto 0)
    );
end entity;

architecture ram_dist_arch of ram_dist is

    type ram_array is array (0 to 25) of std_logic_vector(11 downto 0);
    signal ram_block : ram_array;

begin

    process(clock)
    begin
        if (clock'event and clock = '1') then
            if wr = '1' then
                ram_block(to_integer(unsigned(addr))) <= din;
            end if;

            dout <= ram_block(to_integer(unsigned(addr)));
        end if;
    end process;

end architecture;