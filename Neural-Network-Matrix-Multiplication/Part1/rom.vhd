library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity ROM_MEM is
    generic (
        ADDR_WIDTH : integer := 10;
        DATA_WIDTH : integer := 8;
        IMAGE_SIZE : integer := 784;
        TOTAL_SIZE : integer := 51914;
        IMAGE_FILE_NAME : string :="imgdata_digit7.mif";
        WEIGHTS_BIAS_FILE_NAME: string := "weights_bias.mif"
    );
    port(
    	clk: in std_logic;
        read_addr: in unsigned(15 downto 0); --addr needed till 51k;
        output: out signed(7 downto 0);
        read_enable: in std_logic
        );
end ROM_MEM;

architecture Behavioral of ROM_MEM is
    TYPE mem_type IS ARRAY((TOTAL_SIZE+10) downto 0) OF std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
    -- 1024 + 50816 weights + 74 biases = 51914
    
    impure function init_mem(image_file_name : in string; wts_bias_file_name : in string) return mem_type is
        file image_file : text open read_mode is image_file_name;
        file wts_bias_file : text open read_mode is wts_bias_file_name;
        variable mif_line : line;
        variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
        variable temp_mem : mem_type;
        
    begin
        for i in 0 to (IMAGE_SIZE -1) loop
            readline(image_file, mif_line);
            read(mif_line, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        for i in 1024 to (TOTAL_SIZE -1) loop
            readline(wts_bias_file, mif_line);
            read(mif_line, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
    	return temp_mem;
    end function;
    
    -- Signal declarations
  
    signal rom_block: mem_type := init_mem(IMAGE_FILE_NAME, WEIGHTS_BIAS_FILE_NAME);
   
    begin
    --Your ROM code
    	process(clk) 
        begin
        	if rising_edge(clk) then
            	if read_enable ='1' then
            	      output <= signed(rom_block(to_integer(read_addr)));
                end if;
            end if;  
    	end process;
    
end Behavioral;