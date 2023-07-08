-- refresh period 4 ms
-- digit period=1 ms
-- 10^8/10^5 = 1000 Hz => 1/1000 = 1 ms


library IEEE;
use IEEE.std_logic_1164.all;

entity clk_refresh is
     Port (
         clk : in STD_LOGIC;
         out_refresh_clk: out STD_LOGIC
     );
end clk_refresh;

architecture Behavioral_clock_refresh of clk_refresh is

   signal temp_counter: STD_LOGIC := '0';
   signal counter: integer := 1;

   begin
     process(clk)
        begin
         if rising_edge(clk) then
             counter <= counter + 1;
         end if;

         if (counter = 100000) then
             counter <= 0;
             temp_counter <= not temp_counter;
         end if;

         out_refresh_clk <= temp_counter;
     end process;

end Behavioral_clock_refresh;