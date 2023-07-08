
library IEEE;
use IEEE.std_logic_1164.all;


entity stopwatch is
   Port (
     anode_input_signal: out STD_LOGIC_VECTOR (0 to 3);
     seven_segment_display : out STD_LOGIC_VECTOR (0 to 6);
     clk : in STD_LOGIC;
     reset_watch : in STD_LOGIC;
     start_continue : in STD_LOGIC;
     pause : in STD_LOGIC;
     decimal : out STD_LOGIC
     );
end stopwatch;

architecture Behavioral_stopwatch of stopwatch is

   signal enable_watch : STD_LOGIC := '0'; -- enables the stopwatch  
   signal display_number : integer := 0; --digit to be displayed in current cycle

   
   signal modulo4_counter : STD_LOGIC_VECTOR (0 to 1) := "00"; 
   signal display_binary : STD_LOGIC_VECTOR (0 to 3) :="0000";
   signal out_refresh_clk : STD_LOGIC := '0';
   signal out_clock : STD_LOGIC := '0';
    
-- Time signals: minute, seconds, tenth_seconds: Format = m:ss:t

   signal minute : integer := 0;
   signal second_tens : integer := 0;
   signal second_ones : integer := 0;
   signal tenth_second : integer := 0;
   
-- Temporary Time signals to update actual time signal values: minute, seconds, tenth_seconds: Format = m:ss:t

   signal temp_minute : integer := 0;
   signal temp_second_tens : integer := 0;
   signal temp_second_ones : integer := 0;
   signal temp_tenth_second : integer := 0;

-- digit displayed in current clock cycle

    signal reset_output : STD_LOGIC := '0';
    signal start_output : STD_LOGIC := '0';
    signal pause_output : STD_LOGIC := '0';

   begin

-- Calling the clock divider process
     clock_divider_call: entity work.clockdivider(Behavioral_clockdivider) port map (clk => clk, out_clock => out_clock);
     debounce_call_reset: entity work.debounce(Behavioral_debounce) port map(clk=>clk, input_signal=>reset_watch, output_signal=>reset_output);
     debounce_call_start: entity work.debounce(Behavioral_debounce) port map(clk=>clk, input_signal=>start_continue, output_signal=>start_output);
     debounce_call_pause: entity work.debounce(Behavioral_debounce) port map(clk=>clk, input_signal=>pause, output_signal=>pause_output);
          
----------------------------------------------------------------------------------
-- Process to output modulo counters for minutes, seconds (tens digit), seconds (ones digit), and tenth seconds

         process(out_clock)
             begin
               if rising_edge(out_clock) then

----------------------------------------
-- Working of the Push Buttons 

                 if (start_output = '1') then
                     enable_watch <= '1';

                 elsif (pause_output = '1') then
                     enable_watch <= '0';

                 elsif (reset_output = '1') then
                     enable_watch <= '0';
                     temp_minute <= 0;
                     temp_second_tens <= 0;
                     temp_second_ones <= 0;
                     temp_tenth_second <= 0;

                 end if;

----------------------------------------

                 if enable_watch = '1' then

-- Modulo counter for tenths of a second

                     if tenth_second<9 then
                         temp_tenth_second <= tenth_second + 1;
                     elsif tenth_second=9  then
                         temp_tenth_second <= 0;
                     end if;

-- Modulo counter for ones digit of seconds

                     if tenth_second=9 then
                         if second_ones<9 then
                             temp_second_ones <= second_ones + 1;
                         elsif second_ones=9 then
                             temp_second_ones <= 0;
                         end if;
                     end if;

-- Modulo counter for tens digit of seconds

                     if (tenth_second=9) and (second_ones=9) then
                         if second_tens<5 then
                             temp_second_tens <= second_tens + 1;
                         elsif second_tens=5  then
                             temp_second_tens <= 0;
                         end if;
                     end if;

-- Modulo counter for minutes

                     if (tenth_second=9) and (second_ones=9) and (second_tens=5) then
                         if minute<9 then
                             temp_minute <= minute + 1;
                         elsif minute=9  then
                             temp_minute <= 0;
                         end if;
                     end if;



                end if;

             end if;

             minute <= temp_minute;
             second_tens <= temp_second_tens;
             second_ones <= temp_second_ones;
             tenth_second <= temp_tenth_second;

         end process;

-- Calling the counter process 
     clock_refresh_call: entity work.clk_refresh(Behavioral_clock_refresh) port map (clk => clk, out_refresh_clk => out_refresh_clk);
     
----------------------------------------------------------------------------------

-- Process to drive 4 LED displays : 4:1 Multiplexer module and timing circuit

     process(out_refresh_clk)
       begin
         if rising_edge(out_refresh_clk) then

           if modulo4_counter = "00" then
             anode_input_signal <= "1011";
             modulo4_counter <= "01";
             decimal <= '1';
             display_number <= second_tens;

           elsif modulo4_counter = "01" then
             anode_input_signal <= "1101";
             modulo4_counter <= "10";
             decimal <= '0';
             display_number <= second_ones;

           elsif modulo4_counter = "10" then
             anode_input_signal <= "1110";
             modulo4_counter <= "11";
             decimal <= '1';
             display_number <= tenth_second;

           elsif modulo4_counter = "11" then
             anode_input_signal <= "0111";
             modulo4_counter <= "00";
             decimal <= '0';
             display_number <= minute;

           end if;
         end if;
     end process;


----------------------------------------------------------------------------------
-- input of seven segment

     process(display_number)
       begin
         case display_number is
           when 0 => display_binary <= "0000";
           when 1 => display_binary <= "0001";
           when 2 => display_binary <= "0010";
           when 3 => display_binary <= "0011";
           when 4 => display_binary <= "0100";
           when 5 => display_binary <= "0101";
           when 6 => display_binary <= "0110";
           when 7 => display_binary <= "0111";
           when 8 => display_binary <= "1000";
           when 9 => display_binary <= "1001";
           when others => display_binary <= "0000";
         end case;
     end process;
     
     ------------------------------------------------------------------------------------
-- Calling the seven segment display process
     seven_segment_display_call: entity work.seven_segment_decoder(Behavioral_seven_segment_decoder) port map(anode_signal => display_binary, cathode_signal => seven_segment_display);


end Behavioral_stopwatch;