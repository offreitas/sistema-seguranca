library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sistema_seguranca_uc is
    port (
        -- Inputs
        clock      : in std_logic;
        reset      : in std_logic;
        ligar      : in std_logic;
        fim_1s     : in std_logic;
        pronto_med : in std_logic;
        pronto_tx  : in std_logic;
        fim_cal    : in std_logic;
        alerta     : in std_logic;
        mode       : in std_logic;
        senha_ok   : in std_logic;
        desarmar   : in std_logic;
        -- Outputs
        zera       : out std_logic;
        posiciona  : out std_logic;
        medir      : out std_logic;
        transmitir : out std_logic;
        calibrando : out std_logic;
        write_en   : out std_logic;
        alerta_out : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture sistema_seguranca_uc_arch of sistema_seguranca_uc is

    type tipo_estado is
        (
            idle, preparacao, cal_medida,
            cal_espera, cal_localizacao, cal_ultima_med,
            cal_armazena_ultima, medida, espera_med,
            transmissao, localizacao, analise, detectado
            -- ligar_auth, desarmar_auth
        );

    signal Eatual : tipo_estado;
    signal Eprox  : tipo_estado;

begin

    -- Memoria de estado
    process(clock, reset)
    begin
        if (reset = '1' or ligar = '0') then
            Eatual <= idle;
        -- elsif ligar'event and event = '0' then
        --     Eatual <= desarmar_auth;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    -- Logica de proximo estado
    process(ligar, fim_1s, pronto_med, pronto_tx, fim_cal, alerta, mode, senha_ok, desarmar, Eatual)
    begin
        case Eatual is
            when idle => 
                if ligar = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= idle;
                end if;

            when preparacao => Eprox <= cal_medida;

            -- when preparacao => Eprox <= ligar_auth;

            -- -- Armar
            -- when ligar_auth =>
            --     if senha_ok = '1' then
            --         Eprox <= cal_medida;
            --     else
            --         Eprox <= ligar_auth;
            --     end if;

            -- Calibracao
            when cal_medida => Eprox <= cal_espera;

            when cal_espera =>
                if fim_cal = '1' then
                    Eprox <= cal_ultima_med;
                elsif fim_1s = '1' then
                    Eprox <= cal_localizacao;
                elsif pronto_med = '1' then
                    Eprox <= cal_localizacao;
                else
                    Eprox <= cal_espera;
                end if;

            when cal_localizacao =>
                if fim_1s = '1' then
                    Eprox <= cal_medida;
                else
                    Eprox <= cal_localizacao;
                end if;

            when cal_ultima_med =>
                if pronto_med = '1' then
                    Eprox <= cal_armazena_ultima;
                elsif fim_1s = '1' then
                    Eprox <= cal_armazena_ultima;
                else
                    Eprox <= cal_ultima_med;
                end if;

            when cal_armazena_ultima => Eprox <= localizacao;

            -- Deteccao de movimento
            when medida => Eprox <= espera_med;
			
            when espera_med => 
                if fim_1s = '1' then
                    Eprox <= localizacao;
                elsif pronto_med = '1' then
                    Eprox <= analise;
                else
                    Eprox <= espera_med;
                end if;
					 
            when analise =>
                if alerta = '1' then
                    Eprox <= transmissao;
                else 
                    Eprox <= localizacao;
                end if;

            when transmissao =>
                if pronto_tx = '1' and mode = '1' then
                    Eprox <= detectado;
                elsif pronto_tx = '1' and mode = '0' then
                    Eprox <= localizacao;
                else
                    Eprox <= transmissao;
                end if;
					 
            when detectado => Eprox <= detectado;

            -- when detectado =>
            --     if desarmar = '1' then
            --         Eprox <= desarmar_auth;
            --     else
            --         Eprox <= detectado;
            --     end if;

            when localizacao => 
                if fim_1s = '1' then
                    Eprox <= medida;
                else
                    Eprox <= localizacao;
                end if;

            -- -- Desarmar
            -- when desarmar_auth =>
            --     if senha_ok = '1' then
            --         Eprox <= idle;
            --     else
            --         Eprox <= desarmar_auth;
            --     end if;

            when others => Eprox <= idle;
        end case;
    end process;

    -- Logica de saida
    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        medir <= 
            '1' when medida,
            '1' when cal_medida,
            '0' when others;

    with Eatual select
        transmitir <= '1' when transmissao, '0' when others;
    
    with Eatual select
        posiciona <= 
            '1' when localizacao,
            '1' when cal_localizacao,
            '0' when others;

    with Eatual select
        calibrando <= 
            '1' when cal_medida,
            '1' when cal_espera,
            '1' when cal_localizacao,
            '1' when cal_ultima_med,
            '1' when cal_armazena_ultima,
            '0' when others;

    with Eatual select
        write_en <= '1' when cal_armazena_ultima, '0' when others;
		  
	 with Eatual select
        alerta_out <= '1' when detectado, '0' when others;
            
    -- Debug
    with Eatual select
        db_estado <= 
            "0000" when idle,
            "0001" when preparacao,
            "0010" when medida,
            "0011" when espera_med,
            "0100" when transmissao,
            "0101" when localizacao,
            "0110" when cal_medida,
            "0111" when cal_espera,
            "1000" when cal_localizacao,
            "1001" when cal_ultima_med,
            "1010" when cal_armazena_ultima,
            "1011" when analise,
            "1101" when detectado;
            -- "1110" when armar_auth,
            -- "1111" when desarmar_auth;

end architecture;