library IEEE;
use ieee.std_logic_1164.all;
library work;

entity relogio_xadrez is
    port (
        j1, j2, load, clock, reset: in std_logic;
        init_time: in std_logic_vector(7 downto 0);
        contj1, contj2: out std_logic_vector(15 downto 0);
        winj1, winj2: out std_logic := '0' --valor genérico padrão sendo 0
    );
end relogio_xadrez;

architecture relogio_xadrez of relogio_xadrez is
    -- DECLARAÇÃO DOS ESTADOS
    type states is (idle, timestart, j1turn, j2turn, timeend);
    signal EA, PE : states;
    -- ADICIONE AQUI OS SINAIS INTERNOS NECESSÁRIOS, COMO CONTADORES E SINAIS DE CONTROLE
    signal contj1_t, contj2_t : std_logic_vector(15 downto 0); --contador interno
    signal en1, en2 : std_logic; --enabler interno
begin
    -- INSTANCIAÇÃO DOS CONTADORES
    contador1 : entity work.temporizador port map (
        clock => clock,
        reset => reset,
        en => en1,
        load => load,
        init_time => init_time,
        cont => contj1_t
    );
    
    contador2 : entity work.temporizador port map (
        clock => clock,
        reset => reset,
        en => en2,
        load => load,
        init_time => init_time,
        cont => contj2_t
    );

    -- PROCESSO DE TROCA DE ESTADOS
    process (clock, reset)
    begin
        if reset = '1' then
            EA <= idle;
        elsif rising_edge(clock) then
            EA <= PE;
        end if;
    end process;

    -- PROCESSO PARA DEFINIR O PRÓXIMO ESTADO
    process (EA, j1, j2, contj1_t, contj2_t)
    begin
        case EA is
            when idle =>
                if load = '1' then --caso começe a partida vai para o time start
                    PE <= timestart;
                else --caso contrário continua em idle
                    PE <= idle;
                end if;
            when timestart =>
                if j1 = '1' then --o jogador que apertar primeiro iniciará no seu turno
                    PE <= j1turn;
                elsif j2 = '1' then
                    PE <= j2turn;
                else
                    PE <= timestart;
                end if;
            when j1turn => --durante o turno do jogador 1
                if contj1_t = "0000000000000000" then 
                    PE <= timeend; --se seu contador acabar irá para o final do jogo
                    winj2 <= '1';
                elsif j1 = '1' then
                    PE <= j2turn; --se j1 pressionar botão irá para turno do jogador 2
                else
                    PE <= j1turn; --nenhum dos dois casos acima leva então à repetição
                end if;
            when j2turn => --durante turno do jogador 2
                if contj2_t = "0000000000000000" then
                    PE <= timeend; --se seu contador acabar irá para o final do jogo
                    winj1 <= '1';
                elsif j2 = '1' then
                    PE <= j1turn; --se j2 pressionar botão irá para turno do jogador 1
                else
                    PE <= j2turn; --nenhum dos dois casos acima leva então à repetição
                end if;
            when others =>
                PE <= idle;
                winj1 <= '0';
                winj2 <= '0';
        end case;
    end process;

    -- ATRIBUIÇÃO COMBINACIONAL DOS SINAIS INTERNOS E SAÍDAS
    process (EA)
    begin
        case EA is
            when j1turn => --durante turno do jogador 1 o relógio ativa seu contador1
                en2 <= '0';
                en1 <= '1';
            when j2turn => --durante turno do jogador 2 o relógio ativa seu contador2
                en1 <= '0';
                en2 <= '1';
            when others => --caso contrário nenhum contador estará ativo
                en1 <= '0';
                en2 <= '0';
        end case;
    end process;
    contj1 <= contj1_t;
    contj2 <= contj2_t;

end relogio_xadrez;
