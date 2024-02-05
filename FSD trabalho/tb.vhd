--------------------------------------------------------------------------------
-- TB do cronometro de xadrez
-- Fernando Moraes - 25/out/2023
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity tb is
end tb;

architecture arch of tb is
    signal init_time                             : std_logic_vector(7 downto 0);
    signal contj1, contj2                        : std_logic_vector(15 downto 0);
    signal reset, load, j1, j2, winJ1, winJ2, ck : std_logic := '0' ;
    signal conta_tempo, tempo_anterior, vetor    : integer   := 0;

    type test_record is record
        t    : integer;
        load : std_logic;
        init : std_logic_vector(7 downto 0);
        j1   : std_logic;
        j2   : std_logic;
    end record;


    type padroes is array(natural range <>) of test_record;

    constant padrao_de_teste: padroes := (
            (t => 4,  load=>'1', init=>x"10", j1=>'0', j2 =>'0'), -- partida de 10 minutos
            (t => 10,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 começa a partida
            (t => 30,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 30 ciclos (30 seg)
            (t => 30,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 30 ciclos (30 seg)
            (t => 40,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 40 ciclos (40 seg)
            (t => 20,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 20 ciclos (20 seg)
            (t => 50,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 50 ciclos (50 seg)
            (t => 120,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 120 ciclos (2 min)
            (t => 80,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 80 ciclos (1 min e 20 seg)
            (t => 30,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 30 ciclos (30 seg)
            (t => 120,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 120 ciclos (2 min)
            (t => 60,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 60 ciclos (1 min)
            (t => 40,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 40 ciclos (40 segs)
            (t => 90,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 90 ciclos (1 min e 30 seg)
            (t => 100,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 100 ciclos (1 min e 40 seg)
            (t => 180,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 180 ciclos (3 min)
            (t => 60,  load=>'0', init=>x"00", j1=>'0', j2 =>'1'), -- jogador 2 joga por 60 ciclos (1 min)
            (t => 65,  load=>'0', init=>x"00", j1=>'1', j2 =>'0'), -- jogador 1 joga por 65 ciclos (1min e 5 seg)
            (t => 80,  load=>'0', init=>x"00", j1=>'0', j2 =>'0'), -- jogador 2 perde por tempo
            (t => 10000,  load=>'0', init=>x"00", j1=>'0', j2 =>'0') );  -- ultimo comando – coloca todos os valores em zero

begin

    reset <= '1', '0' after 5 ns;

    ck <= not ck after 5 ns;

    UUT : entity work.relogio_xadrez
        port map ( reset => reset, clock => ck,
            load      => load,
            init_time => init_time,
            j1        => j1,
            j2        => j2,
            contj2    => contj2,
            contj1    => contj1,
            winJ1     => winJ1,
            winJ2     => winJ2 );


    -- injeta a programação e o padrões 
    process(ck, reset)
    begin
        if reset = '1' then
            conta_tempo <= 0;
        elsif rising_edge(ck) then
            conta_tempo <= conta_tempo + 1;

            if (vetor<=padrao_de_teste'high) and padrao_de_teste(vetor).t + tempo_anterior = conta_tempo then
                    load      <= padrao_de_teste(vetor).load;
                    init_time <= padrao_de_teste(vetor).init;
                    j1        <= padrao_de_teste(vetor).j1;
                    j2        <= padrao_de_teste(vetor).j2;
                    vetor     <= vetor + 1;
                    tempo_anterior <= conta_tempo;
                else
                    load      <= '0';
                    j1        <= '0';
                    j2        <= '0';                
                end if;

        end if;
    end process;

end arch;




