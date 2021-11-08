library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_tb is
end entity;

architecture tb of sonar_tb is
    -- Inputs
    signal clock_in   : std_logic := '0';
    signal reset_in   : std_logic := '0';
    signal ligar_in   : std_logic := '0';
    signal echo_in    : std_logic := '0';
    signal sel_mux_in : std_logic_vector(1 downto 0) := "00";

    -- Outputs
    signal trigger_out      : std_logic := '0';
    signal pwm_out          : std_logic := '0';
    signal saida_serial_out : std_logic := '0';
    signal alerta_prox_out  : std_logic := '0';

    -- Controle do clock
    signal keep_simulating : std_logic := '0';
    constant clockPeriod   : time      := 20 ns;

    -- Array de casos de teste
	type caso_teste_type is record
		id    : natural; 
		tempo : integer;     
	end record;

	type casos_teste_array is array (natural range <>) of caso_teste_type;
	constant casos_teste : casos_teste_array :=
		(
			(1, 100),
			(2, 231),
            (3, 300),
            (4, 392),
            (5, 492),
            (6, 543),
            (7, 638)
			-- inserir aqui outros casos de teste (inserir "," na linha anterior)
		);

	signal larguraPulso: time := 1 ns;

begin

    -- Gerador de clock
    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

    -- Instancia
    DUT: entity work.sonar (sonar_arch)
        port map(
            -- Inputs
            clock   => clock_in,
            reset   => reset_in,
            ligar   => ligar_in,
            echo    => echo_in,
            sel_mux => sel_mux_in,
            -- Outputs
            trigger            => trigger_out,
            pwm                => pwm_out,
            saida_serial       => saida_serial_out,
            saida_serial_ch    => open,
            saida_serial_mqtt  => open,
            pwm_ch             => open,
            alerta_proximidade => alerta_prox_out,
            alerta_prox_mqtt   => open,
            db_transmitir      => open,
            db_medir           => open,
            display0           => open,
            display1           => open,
            display2           => open,
            display3           => open,
            display4           => open,
            display5           => open
        );

    -- Estimulo
    stim: process is
    begin
        assert false report "Inicio das simulacoes" severity note;
		keep_simulating <= '1';
		
		---- valores iniciais ----------------
		echo_in  <= '0';

		---- inicio: reset ----------------
		wait for 2*clockPeriod;
		reset_in <= '1'; 
		wait for 2 us;
		reset_in <= '0';
		wait until falling_edge(clock_in);

		---- espera de 100us
		wait for 100 us;

        wait until falling_edge(clock_in);
        ligar_in <= '1';

		---- loop pelos casos de teste
		for i in casos_teste'range loop
			-- 1) determina largura do pulso echo
			assert false report "Caso de teste " & integer'image(casos_teste(i).id) & ": " &
				integer'image(casos_teste(i).tempo) & "us" severity note;
			larguraPulso <= casos_teste(i).tempo * 1 us; -- caso de teste "i"
		
			-- 2) espera por 400us (tempo entre trigger e echo)
			wait for 400 us;
		
			-- 3) gera pulso de echo (largura = larguraPulso)
			echo_in <= '1';
			wait for larguraPulso;
			echo_in <= '0';
		
			-- 4) espera entre casos de tese
			wait for 20 ms;

		end loop;

		---- final dos casos de teste da simulacao
		assert false report "Fim das simulacoes" severity note;
		keep_simulating <= '0';
		
		wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)

    end process;

end architecture;