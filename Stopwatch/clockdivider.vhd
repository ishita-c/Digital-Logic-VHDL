-- Process to divide clock 100 Mhz to 10 Hz
-- 10^8/10^7 => 10Hz

library IEEE;
use IEEE.std_logic_1164.all;

entity clockdivider is
     Port (
         clk : in STD_LOGIC;
         out_clock: out STD_LOGIC
     );
end clockdivider;

architecture Behavioral_clockdivider of clockdivider is

   signal clock_counter: integer := 1;
   signal temp_clock_signal: STD_LOGIC := '0';
   

   begin
     process(clk)
       begin
         if rising_edge(clk) then
             clock_counter <= clock_counter + 1;
         end if;

         if (clock_counter = 10000000) then
             clock_counter <= 0;
             temp_clock_signal <= not(temp_clock_signal);
         end if;

         out_clock <= temp_clock_signal;
     end process;

end Behavioral_clockdivider;
