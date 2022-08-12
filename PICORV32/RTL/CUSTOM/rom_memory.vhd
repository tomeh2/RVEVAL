library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity rom_memory is
    generic(
        SIZE_BYTES : integer
    );
    port(
        -- ========== BUS SIGNALS ==========
        bus_addr : in std_logic_vector(integer(ceil(log2(real(SIZE_BYTES)))) - 1 downto 0);
        bus_rdata : out std_logic_vector(31 downto 0);
        bus_ready : out std_logic;
        -- =================================
        
        -- ========== CONTROL SIGNALS ==========
        en : in std_logic;
        clk : in std_logic;
        resetn : in std_logic
        -- =====================================
    );
end rom_memory;

architecture rtl of rom_memory is
	constant BUS_ADDR_BITS : integer := integer(ceil(log2(real(SIZE_BYTES))));

    type rom_type is array (0 to SIZE_BYTES / 4 - 1) of std_logic_vector(31 downto 0);

    impure function init_rom_hex return rom_type is
        file text_file : text open read_mode is "../../../SRC/projects/system_test/firmware.hex";
        variable text_line : line;
        variable rom_content : rom_type;
        variable temp : std_logic_vector(31 downto 0);
        begin
            for i in 0 to SIZE_BYTES / 4 - 1 loop
                readline(text_file, text_line);
                hread(text_line, temp);

                rom_content(i) := temp;
            end loop;    
 
        return rom_content;
    end function;
    
    signal rom : rom_type := init_rom_hex;

    signal we : std_logic;
    signal bus_ready_i : std_logic;
begin
    ram_cntrl : process(clk)
    begin
        if (rising_edge(clk)) then
            if (en = '1') then
                bus_rdata <= rom(to_integer(unsigned(bus_addr(BUS_ADDR_BITS - 1 downto 2))));
            end if;
        end if;
    end process;

    bus_cntrl : process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                bus_ready_i <= '0';
            else
                bus_ready_i <= en and not bus_ready_i;
            end if;
        end if;
    end process;
    
    bus_ready <= bus_ready_i;

end rtl;
