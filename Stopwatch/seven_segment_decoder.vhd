library IEEE;
use IEEE.std_logic_1164.all;

entity seven_segment_decoder is
   Port (
     anode_signal : in STD_LOGIC_VECTOR (0 to 3);
     cathode_signal : out STD_LOGIC_VECTOR (0 to 6)
     );
end seven_segment_decoder;

architecture Behavioral_seven_segment_decoder of seven_segment_decoder is
   begin

     cathode_signal(0) <= not((not anode_signal(1) and not anode_signal(3)) or (not anode_signal(0) and anode_signal(2)) or (not
   anode_signal(0) and anode_signal(1) and anode_signal(3)) or (anode_signal(0) and not anode_signal(1) and not anode_signal(2)) or (anode_signal(0) and not anode_signal(3)) or (anode_signal(1)
   and anode_signal(2)));
        cathode_signal(1) <= not((not anode_signal(0) and not anode_signal(2) and not anode_signal(3)) or (not anode_signal(0) and
   anode_signal(2) and anode_signal(3)) or (not anode_signal(1)
        and not anode_signal(3)) or (anode_signal(0) and not anode_signal(2) and anode_signal(3)) or (not anode_signal(0) and not
   anode_signal(1)));
        cathode_signal(2) <= not((not anode_signal(0) and anode_signal(1)) or (anode_signal(0) and not anode_signal(1)) or (not anode_signal(2)
   and anode_signal(3))
        or (not anode_signal(0) and not anode_signal(2)) or (not anode_signal(0) and anode_signal(3)));
        cathode_signal(3) <= not((anode_signal(1) and not anode_signal(2) and anode_signal(3)) or (not anode_signal(0) and not anode_signal(1)
   and not anode_signal(3)) or (not anode_signal(1)
        and anode_signal(2) and anode_signal(3)) or (anode_signal(1) and anode_signal(2) and not anode_signal(3)) or (anode_signal(0) and not
   anode_signal(2)));
        cathode_signal(4) <= not((not anode_signal(1) and not anode_signal(3)) or (anode_signal(2) and not anode_signal(3)) or (anode_signal(0)
   and anode_signal(2)) or (anode_signal(0) and anode_signal(1)));
        cathode_signal(5) <= not((not anode_signal(2) and not anode_signal(3)) or (not anode_signal(0) and anode_signal(1) and not
   anode_signal(2)) or (anode_signal(1)
        and not anode_signal(3)) or (anode_signal(0) and not anode_signal(1)) or (anode_signal(0) and anode_signal(2)));
        cathode_signal(6) <= not((not anode_signal(1) and anode_signal(2)) or (anode_signal(0) and not anode_signal(1)) or (not anode_signal(0)
   and anode_signal(1)
        and not anode_signal(2)) or (anode_signal(2) and not anode_signal(3)) or (anode_signal(0) and anode_signal(3)));
    
     
end Behavioral_seven_segment_decoder;
