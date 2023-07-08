library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--debouncer, input as clock and button signal, debounced output 

entity debounce is
    Port (
        clk : in STD_LOGIC;
        input_signal : in STD_LOGIC;
        output_signal : out STD_lOGIC
    );
    
end debounce;


architecture Behavioral_debounce of debounce is
    signal count : integer := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then 
            if count < 1000000 then
                count <= count + 1;
            else 
                count <= 0;
                output_signal <= input_signal;
            end if;
        end if;
    end process;
end Behavioral_debounce;

