library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.STD_LOGIC_UNSIGNED.ALL;
Use IEEE.STD_LOGIC_ARITH.ALL;
Use IEEE.NUMERIC_STD.ALL;

entity Shifter is
    port(
	  clk : in STD_LOGIC;
	  en : in STD_LOGIC;
      shift_input_sig : in STD_LOGIC_VECTOR(15 downto 0);
      shift_out_sig : out STD_LOGIC_VECTOR(15 downto 0)
    );
end Shifter;

architecture behavioral_Shifter of Shifter is
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(en = '1') then
                shift_out_sig <= ("00000" & shift_input_sig(15 downto 5));
            end if;
        end if;
    end process;
end behavioral_Shifter;