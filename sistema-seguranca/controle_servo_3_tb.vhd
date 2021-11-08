--------------------------------------------------------------------
-- Arquivo   : controle_servo_3_tb.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar (Parte 1)
--------------------------------------------------------------------
-- Descricao : testbench para circuito de controle do servomotor 
--
--             1) 8 posicoes
--
--             2) array de casos de teste contém valores de  
--                largura de pulso pwm
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     24/09/2021  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity controle_servo_3_tb is
end entity;

architecture tb of controle_servo_3_tb is
	
	-- Declaração de sinais para conectar o componente a ser testado (DUT)
	--   valores iniciais para fins de simulacao (GHDL ou ModelSim)
	signal clock_in: std_logic := '0';
	signal reset_in: std_logic := '0';
	signal posicao_in: std_logic_vector (2 downto 0) := "000";
	signal pwm_out: std_logic := '0';


	-- Configurações do clock
	signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
	constant clockPeriod: time := 20 ns;
	
	-- Array de casos de teste
	type caso_teste_type is record
		id     : natural; 
		posicao: std_logic_vector (2 downto 0);
		largura: integer;     
	end record;

	type casos_teste_array is array (natural range <>) of caso_teste_type;
	constant casos_teste : casos_teste_array :=
		(
			(1, "000", 1000),  -- pulso de 1ms
			(2, "001", 1143),  -- pulso de 1,143ms
			(3, "010", 1286),  -- pulso de 1,286ms
			(4, "011", 1429),  -- pulso de 1,429ms
			(5, "100", 1571),  -- pulso de 1.571ms
			(6, "101", 1719),  -- pulso de 1,719ms
			(7, "110", 1857),  -- pulso de 1,857ms
			(8, "111", 2000)   -- pulso de 2ms
		);

begin
	-- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
	-- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
	-- simulação de eventos
	clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

	
	-- Conecta DUT (Device Under Test)
	dut: entity work.controle_servo_3 (rtl) 
		port map (
			-- Inputs
			clock   => clock_in,
			reset   => reset_in,
			posicao => posicao_in,
			-- Outputs
			pwm        => pwm_out,
			db_reset   => open,
			db_pwm     => open,
			db_posicao => open 
		);

	-- geracao dos sinais de entrada (estimulos)
	stimulus: process is
	begin
	
		assert false report "Inicio da simulacao" & LF & "... Simulacao ate 1600 ms. Aguarde o final da simulacao..." severity note;
		keep_simulating <= '1';
		
		---- inicio: reset ----------------
		reset_in <= '1'; 
		wait for 2*clockPeriod;
		reset_in <= '0';
		wait for 2*clockPeriod;

		---- loop pelos casos de teste
		for i in casos_teste'range loop
			-- imprime caso e largura do pulso em us
			assert false report "Caso de teste " & integer'image(casos_teste(i).id) & ": " &
				integer'image(casos_teste(i).largura) & "us" severity note;
			-- seleciona posicao
			posicao_in <= casos_teste(i).posicao; -- caso de teste "i"
			-- duracao do caso de teste
			wait for 200 ms;
			-- reset
			reset_in <= '1'; 
			wait for 2*clockPeriod;
			reset_in <= '0';
			wait for 2*clockPeriod;
		end loop;

		---- final dos casos de teste  da simulacao
		assert false report "Fim da simulacao" severity note;
		keep_simulating <= '0';
		
		wait; -- fim da simulação: aguarda indefinidamente
	end process;

end architecture;
