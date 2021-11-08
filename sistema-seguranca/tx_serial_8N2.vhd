library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_8N2 is
    port (
        -- Inputs
        clock       : in std_logic;
        reset       : in std_logic;
        partida     : in std_logic;
        dados_ascii : in std_logic_vector (7 downto 0);
        -- Outputs
        saida_serial : out std_logic;
        pronto_tx    : out std_logic;
        -- Debug
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
    );
end entity;


architecture tx_serial_8N2_arch of tx_serial_8N2 is
     
    component tx_serial_tick_uc
        port (
            -- Inputs
            clock   : in std_logic;
            reset   : in std_logic;
            partida : in std_logic;
            tick    : in std_logic;
            fim     : in std_logic;
            -- Outputs
            zera    : out std_logic;
            conta   : out std_logic;
            carrega : out std_logic; 
            desloca : out std_logic; 
            pronto  : out std_logic;
            -- Debug
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    component tx_serial_8N2_fd
        port (
            -- Inputs
            clock       : in std_logic;
            reset       : in std_logic;
            zera        : in std_logic;
            conta       : in std_logic;
            carrega     : in std_logic;
            desloca     : in std_logic;
            dados_ascii : in std_logic_vector (7 downto 0);
            -- Outputs
            saida_serial : out std_logic;
            fim          : out std_logic
        );
    end component;
    
    component contador_m
    generic (
        constant M: integer; 
        constant N: integer 
    );
    port (
        clock, zera, conta: in std_logic;
        Q: out std_logic_vector (N-1 downto 0);
        fim: out std_logic
    );
    end component;
    
    component edge_detector is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;
    
    signal s_reset, s_partida, s_partida_ed: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim, copia_saida: std_logic;

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;
    s_partida <= partida;

    -- unidade de controle
    U1_UC: tx_serial_tick_uc port map (clock, s_reset, s_partida_ed, s_tick, s_fim,
                                       s_zera, s_conta, s_carrega, s_desloca, pronto_tx, db_estado);

    -- fluxo de dados
    U2_FD: tx_serial_8N2_fd port map (clock, s_reset, s_zera, s_conta, s_carrega, s_desloca, 
                                      dados_ascii, copia_saida, s_fim);
												  
    saida_serial <= copia_saida;

    -- gerador de tick
    -- fator de divisao 50MHz para 9600 bauds = 5208 (13 bits)
    U3_TICK: contador_m generic map (M => 5208, N => 13) port map (clock, s_zera, '1', open, s_tick);
 
    -- detetor de borda para tratar pulsos largos
    U4_ED: edge_detector port map (clock, s_partida, s_partida_ed);
	 
    --sinais de depuracao
    db_partida      <= partida;
    db_saida_serial <= copia_saida;
    
end architecture;