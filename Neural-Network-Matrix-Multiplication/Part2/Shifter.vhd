library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.NUMERIC_STD.ALL;

entity Shifter is
    port(
	  en : in STD_LOGIC;
      shift_input_sig : in signed(15 downto 0);
      shift_out_sig : out signed(15 downto 0)
    );
end Shifter;

architecture behavioral_Shifter of Shifter is
begin
shift_out_sig <= ("00000" & shift_input_sig(15 downto 5)) when (shift_input_sig(15)='0' and en='1') else ("11111" & shift_input_sig(15 downto 5)) when (en='1');

       
   
end behavioral_Shifter;