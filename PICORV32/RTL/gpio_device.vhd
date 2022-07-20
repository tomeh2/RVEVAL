library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gpio_device is
    port (
        -- ========== GPIO SIGNALS ==========
        gpio_o : out std_logic_vector(31 downto 0);
        gpio_i : in std_logic_vector(31 downto 0);
        -- ==================================
        
        -- ========== BUS SIGNALS ==========
        bus_addr : in std_logic_vector(2 downto 0);
        bus_wdata : in std_logic_vector(31 downto 0);
        bus_rdata : out std_logic_vector(31 downto 0);
        bus_wstrb : in std_logic_vector(3 downto 0);
        bus_ready : out std_logic;
        -- =================================
        
        -- ========== CONTROL SIGNALS ==========
        cs : in std_logic;
        clk : in std_logic;
        resetn : in std_logic
        -- =====================================
    );
end gpio_device;

architecture rtl of gpio_device is
    signal r_w : std_logic;
    signal bus_ready_i : std_logic;

    signal gpio_o_reg : std_logic_vector(31 downto 0);
    signal gpio_i_reg : std_logic_vector(31 downto 0);
begin
    -- REGISTER WRITE CONTROL
    gpio_reg_cntrl : process(clk)
    begin
        if (rising_edge(clk)) then
             if (resetn = '0') then
                gpio_o_reg <= (others => '0');
                gpio_i_reg <= (others => '0');
             else
                gpio_i_reg <= gpio_i;
                
                if (cs = '1' and r_w = '0' and bus_addr(2) = '0') then
                    if (bus_wstrb(0) = '1') then
                        gpio_o_reg(7 downto 0) <= bus_wdata(7 downto 0);
                    end if;
                    
                    if (bus_wstrb(1) = '1') then
                        gpio_o_reg(15 downto 8) <= bus_wdata(15 downto 8);
                    end if;
                    
                    if (bus_wstrb(2) = '1') then
                        gpio_o_reg(23 downto 16) <= bus_wdata(23 downto 16);
                    end if;
                    
                    if (bus_wstrb(3) = '1') then
                        gpio_o_reg(31 downto 24) <= bus_wdata(31 downto 24);
                    end if;
                end if;
             end if;
        end if;
    end process;
    
    -- REGISTER READ CONTROL
    gpio_reg_read_cntrl : process(clk)
    begin
        if (rising_edge(clk)) then
            if (cs = '1' and r_w = '1') then
                case bus_addr(2) is
                    when '0' => bus_rdata <= gpio_o_reg;
                    when '1' => bus_rdata <= gpio_i_reg;
                    when others => bus_rdata <= (others => '0');
                end case;
            else
                bus_rdata <= (others => '0');
            end if;
        end if;
    end process;
    
    bus_cntrl : process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                bus_ready_i <= '0';
            else
                bus_ready_i <= cs and not bus_ready_i;
            end if;
        end if;
    end process;

    r_w <= '1' when bus_wstrb = "0000" else '0';
    gpio_o <= gpio_o_reg;
    bus_ready <= bus_ready_i;

end rtl;
