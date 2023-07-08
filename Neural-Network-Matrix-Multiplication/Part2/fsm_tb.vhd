library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;           

entity fsm_tb is
end fsm_tb;

architecture arc of fsm_tb is

    signal clk : std_logic := '0';
    signal cathode : std_logic_vector(6 downto 0);
    signal anode  : std_logic_vector(3 downto 0);

begin

    fsm_call: entity work.fsm port map (
        clk => clk,
        cathode => cathode,
        anode => anode
    );
    process
    begin
        clk <= not clk after 5 ns;
        wait for 100 ns;
    end process;

end arc;
