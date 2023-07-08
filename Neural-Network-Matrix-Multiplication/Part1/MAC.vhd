library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.NUMERIC_STD.ALL;


entity MAC is
  Port (
    clk : in STD_LOGIC;
    cntrl : in STD_LOGIC;
    mac_input_1 : in signed(7 downto 0);
    mac_input_2 : in signed(15 downto 0);
    accumulator : inout signed(15 downto 0) 
  );
end MAC;

architecture Behavioral_MAC of MAC is
  
    signal product_vec : signed(23 downto 0);
    
    begin
    
    process(clk) 
    begin
        if(rising_edge(clk)) then
            product_vec <= (mac_input_1*mac_input_2);
            if(cntrl = '1') then
                accumulator <= product_vec(23 downto 8);
            else
                accumulator <= accumulator + product_vec(23 downto 8);
            end if;
        end if;
    end process;
end Behavioral_MAC;