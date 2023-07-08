library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram is
	port(
    	clk: in std_logic;
        addr: in unsigned(15 downto 0);
        input: in signed(15 downto 0);
        output: out signed(15 downto 0);
        read_enable: in std_logic;
        write_enable: in std_logic
        );
end ram;

architecture behavioural of ram is
	type layer is array(1000 downto 0) of signed(15 downto 0);
    signal local: layer := (others => x"0000");
    
    begin
    	process(clk) 
        begin
        	if rising_edge(clk) then
            	if read_enable ='1' then
                	output <= local(to_integer(addr));
                end if;
                if write_enable ='1' then
                	local(to_integer(addr))<= input;
                end if;
            end if;  
    	end process;
    
end behavioural;