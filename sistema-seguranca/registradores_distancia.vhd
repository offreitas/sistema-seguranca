-- Entidade extraída do Projeto 6 de Sistemas Digitais 2
library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
entity registradores_distancia is
	generic(regn: natural := 8; --numero de distancias
			wordSize: natural := 14); --numero de bits por distancia
	port(clock: in bit;
		 reset: in bit;
		 regWrite: in bit; -- habilita escrita no registrador wr
		 rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
		 d: in bit_vector(wordSize-1 downto 0);
		 q1, q2: out bit_vector(wordSize-1 downto 0)); -- dados lidos dos registradores rr1 e rr2
end entity;

architecture arch_regfile of registradores_distancia is

	component reg
		generic(wordSize: natural:= 4);
		port(clock : in bit;
			 reset: in bit;
			 load: in bit;
			 d: in bit_vector(wordSize-1 downto 0);
			 q: out bit_vector(wordSize-1 downto 0));
	end component;
	
	type dados is array (0 to regn-1) of bit_vector (wordSize-1 downto 0);
	signal load_reg: bit_vector(0 to regn-1);
	signal clock_tb: bit := '0';
	signal d_reg: dados;
	signal q_reg: dados;
	
begin
	--vamos criar nosso banco de registradores
	G1: for i in 0 to regn-1 generate
		reg_i: reg generic map(wordSize=>wordSize) port map(clock=>clock_tb, reset=>reset, load=>load_reg(i), d=>d_reg(i), q=>q_reg(i));
	end generate;
	
	atividade2: process(clock, rr1, rr2, q_reg)
	variable potencia_2: natural;
	variable indice: natural;
	variable i: natural;
	begin
		if(clock='0' and clock'event) then
			clock_tb <= '0';
			for j in 0 to regn-1 loop
				load_reg(j) <= '0';--nao sei em quem eu escrevi
				--entao vou zerar todo mundo
			end loop;
		elsif(clock='1' and clock'event and regWrite='1')then
			indice := 0;
			potencia_2 := 1;
			i := 0;
			while(i /= natural(ceil(log2(real(regn))))) loop
				if(i /= 0) then
					potencia_2 := 2*potencia_2;
				end if;
				if(wr(i) = '1')then
					indice := indice + potencia_2;
				end if;
				i := i+1;
			end loop;
			--preparo os sinais para escritar
			--os registrador faz a operacao
			if(indice /= regn-1) then 
				--escrita tem efeito
				d_reg(indice) <= d;
				load_reg(indice) <= '1';
				clock_tb <= '1';
			end if;
		end if;
		--vamos atualizar as saidas q1 e q2
		indice := 0;
		potencia_2 := 1;
		i := 0;
		while(i /= natural(ceil(log2(real(regn))))) loop
			if(i /= 0) then
				potencia_2 := 2*potencia_2;
			end if;
			if(rr1(i) = '1')then
				indice := indice + potencia_2;
			end if;
			i := i+1;
		end loop;
		q1 <= q_reg(indice);
		
		indice := 0;
		potencia_2 := 1;
		i := 0;
		while(i /= natural(ceil(log2(real(regn))))) loop
			if(i /= 0) then
				potencia_2 := 2*potencia_2;
			end if;
			if(rr2(i) = '1')then
				indice := indice + potencia_2;
			end if;
			i := i+1;
		end loop;
		q2 <= q_reg(indice);
	end process;
	
end architecture;