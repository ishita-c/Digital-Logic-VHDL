library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity regstr is
	port(
    	clk: in std_logic;
        read_enable: in std_logic;
        write_enable: in std_logic;
        input: in unsigned(15 downto 0);
        output: out unsigned(15 downto 0)
        );
end regstr;

architecture behavioural of regstr is
    signal regstr: unsigned(15 downto 0);
    
    begin
    	process(clk) 
        begin
        	if rising_edge(clk) then
        	    if write_enable ='1' then
                	regstr<= input;
                end if;
            	if read_enable ='1' then
                	output <= regstr;
                end if;
                
            end if;  
    	end process;
    
end behavioural;