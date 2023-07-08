library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Comparator is
    Port(
	  comp_input_sig : in signed(15 downto 0);
	  comp_out_sig : out signed(15 downto 0)
    );
end entity;

architecture behavioral_Comparator of Comparator is
begin
    comp_out_sig <= comp_input_sig when comp_input_sig(15) = '0' else x"0000";
  
end behavioral_Comparator;