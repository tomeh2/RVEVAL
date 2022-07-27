library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity ram_memory is
    generic(
        SIZE : natural
    );
    port(
        -- ========== BUS SIGNALS ==========
        bus_addr : in std_logic_vector(integer(ceil(log2(real(SIZE)))) + 1 downto 0);
        bus_wdata : in std_logic_vector(31 downto 0);
        bus_rdata : out std_logic_vector(31 downto 0);
        bus_wstrb : in std_logic_vector(3 downto 0);
        bus_ready : out std_logic;
        -- =================================
        
        -- ========== CONTROL SIGNALS ==========
        en : in std_logic;
        clk : in std_logic;
        resetn : in std_logic
        -- =====================================
    );
end ram_memory;

architecture rtl of ram_memory is
    constant NB_COL : integer := 4;
    constant COL_WIDTH : integer := 8;
    constant BUS_ADDR_BITS : integer := integer(ceil(log2(real(SIZE)))) + 2;

    type ram_type is array (0 to SIZE - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);

    impure function init_ram_hex return ram_type is
        file text_file : text open read_mode is "../../../SRC/firmware.hex";
        variable text_line : line;
        variable ram_content : ram_type;
        variable temp : std_logic_vector(31 downto 0);
        begin
            for i in 0 to SIZE - 1 loop
                readline(text_file, text_line);
                hread(text_line, temp);

                ram_content(i) := temp;
				--for j in 0 to 3 loop
                --    ram_content(i)(8 * (j + 1) - 1 downto 8 * j) := temp(8 * (4 - j) - 1 downto 8 * (3 - j));
                --end loop;
            end loop;    
 
        return ram_content;
    end function;
    
    signal ram : ram_type := init_ram_hex;

    signal we : std_logic;
    signal bus_ready_i : std_logic;
begin
    ram_cntrl : process(clk)
    begin
        if (rising_edge(clk)) then
            if (en = '1') then
                if (bus_wstrb = "0000") then
                    bus_rdata <= ram(to_integer(unsigned(bus_addr(BUS_ADDR_BITS - 1 downto 2))));
                else
                    for i in 0 to NB_COL - 1 loop
                        if (bus_wstrb(i) = '1') then
                            ram(to_integer(unsigned(bus_addr(BUS_ADDR_BITS - 1 downto 2))))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= bus_wdata((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
                        end if;
                    end loop;
                end if;
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
    
    we <= '0' when bus_wstrb = "0000" else '1';
    bus_ready <= bus_ready_i;

end rtl;
