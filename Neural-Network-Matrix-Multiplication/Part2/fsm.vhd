library ieee;
use ieee.numeric_std.all;  
use ieee.std_logic_1164.all;

entity fsm is
    port (
        clk : in std_logic;
        cathode : out std_logic_vector(6 downto 0);
        anode  :out std_logic_vector(3 downto 0)
    );
end fsm;

architecture behavioural of fsm is

    signal state: integer := 1;
    
    signal shift_enable     : std_logic := '0'; 
    signal argm_enable    : std_logic;         
    signal argm_init : std_logic;               
    signal ram_read_enable   : std_logic := '0'; 
    signal ram_write_enable   : std_logic := '1';    
    signal rom_read_enable   : std_logic := '1';
    signal mac_init: std_logic;
    
    signal ram_addr : unsigned(15 downto 0) := "0000000000000000";
    signal rom_addr : unsigned(15 downto 0) := "0000000000000000";
    
    signal ram_read_start : unsigned(15 downto 0);  
    signal ram_write_start : unsigned(15 downto 0); 
    signal rom_weights_start : unsigned(15 downto 0);
    signal rom_bias_start : unsigned(15 downto 0);
   
    signal rom_out : signed(7 downto 0);
    signal comp_out: signed(15 downto 0);
    signal shift_out   : signed(15 downto 0);
    signal mac_out  : signed(15 downto 0);
    signal argm_out  : std_logic_vector(3 downto 0);
    signal ram_out : signed(15 downto 0);
    
    signal comp_in: signed(15 downto 0);        
    signal shift_in    : signed(15 downto 0);
    signal mac_in1  : signed(7 downto 0);
    signal mac_in2  : signed(15 downto 0); 
    signal argm_in   : signed(15 downto 0);
    signal ram_in  : signed(15 downto 0); 
    
    signal row_index : unsigned(15 downto 0); -- index of the current row
    signal row_limit : std_logic_vector(15 downto 0); -- total number of rows
    signal column_index : unsigned(15 downto 0); -- index of the current column
    signal column_limit : std_logic_vector(15 downto 0); -- total number of columns
    signal idx : unsigned(15 downto 0);          
     
    signal current_max: signed(15 downto 0);
    signal counter: unsigned(3 downto 0); -- used while deducing the final output class using argmax
    signal display_number: std_logic_vector(3 downto 0); -- final output class
    signal clk_counter: integer:=0;
    signal clk2: std_logic:='0'; -- slower clock which drives the FSM

begin
    ------------------ DataPath

    -- Read-Only Memory (ROM) - To store the parameters and the input image
    call_rom: entity work.ROM_MEM port map (clk  => clk, read_addr => rom_addr, read_enable   => rom_read_enable, output => rom_out);

    -- To perform integer division by a constant factor 32
    call_shifter: entity work.shifter port map (en => shift_enable, shift_input_sig => shift_in, shift_out_sig => shift_out);

    -- To display the final output class on the Basys3 board
    call_sevenSeg: entity work.seven_segment port map (anode_signal => display_number, cathode_signal => cathode);

    -- Random-Access Memory or Read-Write Memory or RAM
    call_ram: entity work.ram port map (clk  => clk, addr => ram_addr, input  => ram_in, output => ram_out, read_enable => ram_read_enable, write_enable => ram_write_enable);

    -- Multiply-Accumulate block (MAC)
    call_mac: entity work.mac port map (clk => clk, cntrl => mac_init, mac_input_1 => mac_in1, mac_input_2 => mac_in2, accumulator => mac_out);

    -- Implement ReLU operation of the neural network
    call_comp: entity work.comparator port map (comp_input_sig => comp_in, comp_out_sig => comp_out);

    ------------------ Control Logic 
    
    anode <= "0001";
    display_number <= argm_out;
    argm_in    <= signed(ram_out);
    ram_in       <= signed("00000000" & rom_out) when state = 1 else comp_out;
    comp_in <= shift_out;
    shift_in <= signed(mac_out);
    mac_in1 <= signed(rom_out);
    mac_in2 <= signed(ram_out) when state=2 or state=5 else  
                x"0001" when state=3 or state=6 else
                x"0000" ;
    
    -- To obtain a slower clock to allow enough clock cycles for reading and writing values
    process(clk)
    begin
        if rising_edge(clk) then
            clk_counter <= clk_counter + 1;
            if clk_counter = 0 then
                clk2 <= not clk2;
            end if;
        end if;
    end process;

    -- Main Control FSM : Consists of 8 states
    process (clk2)
    begin
        if rising_edge(clk2) then
            case state is
                
                when 1 => -- LOAD
                    if ram_addr = to_unsigned(784,16) then
                        state <= 2;
                        row_index <= "0000000000000001"; -- index of the current row
                        column_index <= "0000000000000000"; -- index of the current column
                        idx <= "0000000000000000";
    
                        row_limit <= std_logic_vector(to_unsigned(784,16));
                        column_limit <= std_logic_vector(to_unsigned(64,16));
                        rom_weights_start <= to_unsigned(1024,16);
                        rom_bias_start <= to_unsigned(51200,16); -- 1024 + 784*64
                        ram_read_start <= to_unsigned(0,16);
                        ram_write_start <= to_unsigned(784,16);
                        rom_addr <= to_unsigned(1024,16);
                    else
                        ram_write_enable <= '1';
                        ram_addr <= ram_addr + 1;
                        rom_addr <= rom_addr + 1;
                    end if;

                when 2 => -- Multiplication for layer 1
                   if idx ="0000000000000000" then
                        ram_read_enable <= '1';
                        ram_write_enable <= '0';
                        mac_init <= '1';
                        ram_addr <= ram_read_start;
                    else
                        mac_init <= '0';
                    end if;

                    if idx = unsigned(row_limit) then
                        state <= 3;
                    else
                        idx <= idx+1;
                        ram_addr <= ram_read_start + idx;
                        if row_index < unsigned(row_limit) then
                            row_index <= row_index+1;
                            rom_addr <= rom_weights_start + row_index;
                        else
                            rom_addr <= rom_bias_start + column_index;
                        end if;
                    end if;

                when 3 => -- Accumulation for layer 1
                    shift_enable <= '1';
                    ram_write_enable <= '1';
                    ram_read_enable <= '0';
                    state <= 4;
                    ram_addr <= ram_write_start + column_index(15 downto 0);

                when 4 => -- Storing the outputs of layer 1
                    row_index <= "0000000000000001";
                    idx <= "0000000000000000";
                    ram_write_enable <= '0';
                    ram_read_enable <= '1';

                    if (column_index = unsigned(column_limit)-1) then
                        column_index <= "0000000000000000";
                        rom_weights_start <= to_unsigned(51264,16); -- 1024 + 784*64 + 64
                        rom_bias_start <= to_unsigned(51904,16); -- 1024 + 784*64 + 64 + 64*10
                        ram_read_start <= to_unsigned(784,16);
                        ram_write_start <= to_unsigned(848,16);
                        row_limit <= std_logic_vector(to_unsigned(64,16));
                        column_limit <= std_logic_vector(to_unsigned(10,16));
                        state <= 5;

                        rom_addr <= to_unsigned(51264,16); -- 1024 + 784*64 + 64
                    else
                        column_index <= column_index+1;
                        rom_weights_start <= rom_weights_start + unsigned(row_limit);
                        rom_addr <= rom_weights_start + unsigned(row_limit);
				state <= 2;
                    end if;


                when 5 => -- Multiplication for layer 2
                   if idx = "0000000000000000" then
                        ram_read_enable <= '1';
                        ram_write_enable <= '0';
                        mac_init <= '1';
                        ram_addr <= ram_read_start;
                        
                    else
                        mac_init <= '0';
                    end if;

                    if idx = unsigned(row_limit) then
                        state <= 6;
                    else
                        idx <= idx+1;
                        ram_addr <= ram_read_start + idx;
                        if row_index < unsigned(row_limit) then
                            row_index <= row_index+1;
                            rom_addr <= rom_weights_start + row_index;
                            
                        else
                            rom_addr <= rom_bias_start + column_index;
                        end if;
                    end if;

                when 6 => -- Accumulation for layer 2
                    shift_enable <= '1';
                    ram_write_enable <= '1';
                    ram_read_enable <= '0';
                    state <= 7;
                    ram_addr <= ram_write_start + column_index;

                when 7 => -- Storing the outputs of layer 2
                    row_index <= "0000000000000001";
                    idx <= "0000000000000000";
                    ram_write_enable <= '0';
                    ram_read_enable <= '1';

                    if (column_index = unsigned(column_limit)-1) then
                        column_index <= "0000000000000000";
                      
                        ram_read_start <= to_unsigned(848,16);
                        row_limit <= std_logic_vector(to_unsigned(10,16));
                        state <= 8;
                        argm_enable <= '1';
                        ram_addr <= to_unsigned(848,16);
                        argm_init <= '1';
                    else
                        column_index <= column_index+1;
                        rom_weights_start <= rom_weights_start + unsigned(row_limit);
                        rom_addr <= rom_weights_start + unsigned(row_limit);
				state <= 5;
                    end if;

                when 8 => -- Finds the digit to be displayed by calculating the argmax of final output values
                    argm_enable <= '1';
                    argm_init <= '0';
    
                    if idx = 10 then
                        state <= 9;
                        argm_enable <= '0';
                    else
                        idx <= idx+1;
                    end if;
                    ram_addr <= ram_read_start + idx;
               when others => -- does nothing

            end case;

            -- Logic for finding the digit corresponding to maximum final output value
            if argm_enable = '1' then
                if argm_init = '1' then
                    counter <= "0000";
                    current_max <= argm_in;
                    argm_out <= "0000";
                else
                    counter <= counter + 1;
                    if (argm_in > current_max) then
                        current_max <= argm_in;
                        argm_out <= std_logic_vector(counter);
                    end if;
                end if;
            end if;

        end if;
    end process;
        
end behavioural;   
