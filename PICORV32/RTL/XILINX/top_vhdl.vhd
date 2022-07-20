library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_vhdl is
    
end top_vhdl;

architecture structural of top_vhdl is
    signal bus_valid, bus_instr, bus_ready : std_logic;
    signal bus_addr, bus_wdata, bus_rdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    
    signal irq : std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, resetn : std_logic;
    
    constant T : time := 20ns;
    
    signal rom_bus_rdata : std_logic_vector(31 downto 0);
    signal rom_bus_ready, rom_cs : std_logic;
    
    signal gpio_bus_rdata : std_logic_vector(31 downto 0);
    signal gpio_bus_ready, gpio_cs : std_logic;
    
    signal ram_bus_rdata : std_logic_vector(31 downto 0);
    signal ram_bus_ready, ram_cs : std_logic;
    
    signal gpio_i, gpio_o : std_logic_vector(31 downto 0);
begin
    process
    begin
        clk <= '0';
        wait for T / 2;
        clk <= '1';
        wait for T / 2;
    end process;
    
    resetn <= '0', '1' after T * 10;

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
    /*
    rom : entity work.rom_memory(rtl)
          generic map(SIZE => 128)
          port map(bus_addr => bus_addr(8 downto 0),
                   bus_rdata => rom_bus_rdata,
                   bus_wstrb => bus_wstrb,
                   bus_ready => rom_bus_ready,
                   
                   en => rom_cs,
                   clk => clk,
                   resetn => resetn);*/

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
        rom_cs <= '0';
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

    gpio_i <= X"1111_1111";
    bus_ready <= gpio_bus_ready or ram_bus_ready;

end structural;
