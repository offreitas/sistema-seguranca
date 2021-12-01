-- Entidade extraída do Projeto 6 de Sistemas Digitais 2
entity reg is
	generic(wordSize: natural:= 4);
	port(clock : in bit;
		 reset: in bit;
		 load: in bit;
		 d: in bit_vector(wordSize-1 downto 0);
		 q: out bit_vector(wordSize-1 downto 0));
end reg;

architecture arch_reg of reg is
    begin
        atividade1 : process(clock, reset)
            variable indice : integer;
        begin
                if(reset = '1')then
                    indice := wordSize - 1;
                    while(indice /= -1) loop
                        q(indice) <= '0';
                        indice := indice - 1;
                    end loop;
                elsif clock='1' and clock'event then
                    if(load = '1') then
                        q <= d;
                    end if;
                end if;
        end process;
    end architecture;