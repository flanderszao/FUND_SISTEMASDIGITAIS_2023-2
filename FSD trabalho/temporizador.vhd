    library IEEE;
    use ieee.std_logic_1164.all;
    library work;

    entity temporizador is
        port (
            clock, reset, load, en: in std_logic;
            init_time: in std_logic_vector(7 downto 0);
            cont: out std_logic_vector(15 downto 0)
        );
    end temporizador;

    architecture a1 of temporizador is
        signal segL, segH, minL, minH: std_logic_vector(3 downto 0);
        signal en1, en2, en3, en4: std_logic;
        signal cont_t: std_logic_vector(15 downto 0); --contador interno
    begin
        process (load, clock)
        begin
            if load = '1' then --início do contador
                cont_t <= init_time(7 downto 4) & init_time(3 downto 0) & "0000" & "0000";
            elsif rising_edge(clock) then
                if (cont_t = "0000000000000000") then --garantia de funcionamento, caso de borda
                    cont_t <= cont_t; --pois estava ocorrendo 99:59 após o 00:00, me pergunto se efetivamente isso torna o limite 99:58 ou algo assim
                else --funcionamento padrão do contador
                    cont_t <= minH & minL & segH & segL;
                end if;
            end if;
        end process;

        --enablers baseado nas instruções do pdf
        en1 <= '0' when ((cont_t = "0000000000000000") or (en = '0')) else '1' when (en = '1');
        en2 <= '1' when (segL = "0000" and en1 = '1') else '0';
        en3 <= '1' when (segH = "0000" and en2 = '1') else '0';
        en4 <= '1' when (minL = "0000" and en3 = '1') else '0';

        sL: entity work.dec_counter port map ( --port baseado nas instruções do PDF
            clock => clock,
            reset => reset,
            load => load,
            en => en1,
            first_value => x"0",
            limit => x"9",
            cont => segL
        );
        sH: entity work.dec_counter port map (
            clock => clock,
            reset => reset,
            load => load,
            en => en2,
            first_value => x"0",
            limit => x"5",
            cont => segH
        );
        mL: entity work.dec_counter port map (
            clock => clock,
            reset => reset,
            load => load,
            en => en3,
            first_value => init_time(3 downto 0),
            limit => x"9",
            cont => minL
        );
        mH: entity work.dec_counter port map (
            clock => clock,
            reset => reset,
            load => load,
            en => en4,
            first_value => init_time(7 downto 4),
            limit => x"9",
            cont => minH
        );
        
        cont <= cont_t;
    end a1;