library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_synth is
    port(
        SYSCLK_P : in std_logic;
        SYSCLK_N : in std_logic;
        
        CPU_RESET : in std_logic;
        
        GPIO_SW_N : in std_logic;
        GPIO_SW_S : in std_logic;
        GPIO_SW_W : in std_logic;
        GPIO_SW_E : in std_logic;
        GPIO_SW_C : in std_logic;
        
        GPIO_DIP_SW0 : in std_logic;
        GPIO_DIP_SW1 : in std_logic;
        GPIO_DIP_SW2 : in std_logic;
        GPIO_DIP_SW3 : in std_logic;
        
        GPIO_LED_0 : out std_logic;
        GPIO_LED_1 : out std_logic;
        GPIO_LED_2 : out std_logic;
        GPIO_LED_3 : out std_logic
        );
end top_synth;

architecture structural of top_synth is
    component clk_wiz_1
    port
        (-- Clock in ports
        -- Clock out ports
        clk_out1          : out    std_logic;
        -- Status and control signals
        locked             : out     std_logic;
        clk_in1_p           : in     std_logic;
        clk_in1_n           : in     std_logic
     );
    end component;

    signal bus_valid, bus_instr, bus_ready : std_logic;
    signal bus_addr, bus_wdata, bus_rdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    
    signal irq : std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, clk_locked, resetn : std_logic;
    
    signal gpio_bus_rdata : std_logic_vector(31 downto 0);
    signal gpio_bus_ready, gpio_cs : std_logic;
    
    signal ram_bus_rdata : std_logic_vector(31 downto 0);
    signal ram_bus_ready, ram_cs : std_logic;
    
    signal gpio_i, gpio_o : std_logic_vector(31 downto 0);
begin
    clk_wiz : clk_wiz_1
    port map(clk_in1_p => SYSCLK_P,
             clk_in1_n => SYSCLK_N,
             
             clk_out1 => clk,
             locked => clk_locked);

    picorv32 : entity work.picorv32(picorv32)
               generic map(STACKADDR => X"0000_1000",
                           PROGADDR_RESET => X"0000_0000",
                           PROGADDR_IRQ => X"FFFF_FFFF",
                           BARREL_SHIFTER => 1,
                           COMPRESSED_ISA => 0,
                           ENABLE_COUNTERS => 0,
                           ENABLE_MUL => 0,
                           ENABLE_DIV => 0,
                           ENABLE_FAST_MUL => 0,
                           ENABLE_IRQ => 0,
                           ENABLE_IRQ_QREGS => 0,
                           REGS_INIT_ZERO => 1)
               port map(mem_valid => bus_valid,
                        mem_instr => bus_instr,
                        mem_ready => bus_ready,
                        mem_addr => bus_addr,
                        mem_wdata => bus_wdata,
                        mem_wstrb => bus_wstrb,
                        mem_rdata => bus_rdata,
                        
                        pcpi_wr => '0',
                        pcpi_rd => (others => '0'),
                        pcpi_ready => '0',
                        pcpi_wait => '0',
                        
                        irq => irq,
                        
                        clk => clk,
                        resetn => resetn);

    gpio : entity work.gpio_device(rtl)
           port map(gpio_i => gpio_i,
                    gpio_o => gpio_o,
                    
                    bus_addr => bus_addr(2 downto 0),
                    bus_wdata => bus_wdata,
                    bus_rdata => gpio_bus_rdata,
                    bus_wstrb => bus_wstrb,
                    bus_ready => gpio_bus_ready,
                    
                    cs => gpio_cs,
                    clk => clk,
                    resetn => resetn);
                    
    ram : entity work.ram_memory(rtl)
          generic map(SIZE => 1024)
          port map(bus_addr => bus_addr(11 downto 0),
                   bus_wdata => bus_wdata,
                   bus_rdata => ram_bus_rdata,
                   bus_wstrb => bus_wstrb,
                   bus_ready => ram_bus_ready,
                   
                   en => ram_cs,
                   clk => clk,
                   resetn => resetn);
           

    -- ADDRESS DECODING
    process(all)
    begin
        bus_rdata <= (others => '0');
        gpio_cs <= '0';
        ram_cs <= '0';
    
        if (bus_valid = '1') then
            if (bus_addr(31 downto 16) = X"0000") then
                bus_rdata <= ram_bus_rdata;
                ram_cs <= '1';
            elsif (bus_addr(31 downto 16) = X"0001") then
                bus_rdata <= gpio_bus_rdata;
                gpio_cs <= '1';
            end if;
        end if;
    end process;

    resetn <= not CPU_RESET and clk_locked;
     
    gpio_i(0) <= GPIO_SW_N;
    gpio_i(1) <= GPIO_SW_S;
    gpio_i(2) <= GPIO_SW_W;
    gpio_i(3) <= GPIO_SW_E;
    gpio_i(4) <= GPIO_SW_C;
    
    gpio_i(5) <= GPIO_DIP_SW0;
    gpio_i(6) <= GPIO_DIP_SW1;
    gpio_i(7) <= GPIO_DIP_SW2;
    gpio_i(8) <= GPIO_DIP_SW3;
    
    GPIO_LED_0 <= gpio_o(0);
    GPIO_LED_1 <= gpio_o(1);
    GPIO_LED_2 <= gpio_o(2);
    GPIO_LED_3 <= gpio_o(3);
    
    bus_ready <= gpio_bus_ready or ram_bus_ready;

end structural;
