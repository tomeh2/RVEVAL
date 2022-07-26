library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_vhdl is
    
end top_vhdl;

architecture structural of top_vhdl is
    signal bus_valid, bus_instr, bus_ready : std_logic;
    signal bus_addr, bus_wdata, bus_rdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    
    signal irq : std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, resetn, reset, sdram_we : std_logic;
    
    constant T : time := 20ns;
    
    signal gpio_bus_rdata : std_logic_vector(31 downto 0);
    signal gpio_bus_ready, gpio_cs : std_logic;
    
    signal rom_bus_rdata : std_logic_vector(31 downto 0);
    signal rom_bus_ready, rom_cs : std_logic;
    
    signal sdram_bus_rdata : std_logic_vector(31 downto 0);
    signal sdram_bus_ready, sdram_cs : std_logic;
    
    signal gpio_i, gpio_o : std_logic_vector(31 downto 0);
    
    signal sdram_a : unsigned(12 downto 0);
    signal sdram_ba : unsigned(1 downto 0);
    signal sdram_dq : std_logic_vector(15 downto 0);
    signal sdram_cke : std_logic;
    signal sdram_cs_n : std_logic;
    signal sdram_ras_n : std_logic;
    signal sdram_cas_n : std_logic;
    signal sdram_we_n : std_logic;
    signal sdram_dqml : std_logic;
    signal sdram_dqmh : std_logic;
    signal sdram_dqm : std_logic_vector(1 downto 0);
	
	component ram_simulation
	port(
		bus_valid : in std_logic;
		bus_ready : out std_logic;
		
		bus_addr : in std_logic_vector(31 downto 0);
		bus_wdata : in std_logic_vector(31 downto 0);
		bus_rdata : out std_logic_vector(31 downto 0);
		bus_wstrb : in std_logic_vector(3 downto 0);
		
		clk : in std_logic;
		en : in std_logic;
		resetn : in std_logic
	);
	end component;
	
	component mt48lc16m16a2
	port(
	   Dq : inout std_logic_vector(15 downto 0);
	   addr : in unsigned(12 downto 0);
	   Ba : in std_logic_vector(1 downto 0);
	   Cke : in std_logic;
	   Cs_n : in std_logic;
	   Ras_n : in std_logic;
	   Cas_n : in std_logic;
	   We_n : in std_logic;
	   Clk : in std_logic;
	   Dqm : in std_logic_vector(1 downto 0)
	);
	end component;
begin
    process
    begin
        clk <= '0';
        wait for T / 2;
        clk <= '1';
        wait for T / 2;
    end process;
    
    resetn <= '0', '1' after T * 10;
    reset <= not resetn;

    picorv32 : entity work.picorv32(picorv32)
               generic map(STACKADDR => X"0002_0000",
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
    
    --rom : entity work.rom_memory(rtl)
    --      generic map(SIZE => 128)
    --      port map(bus_addr => bus_addr(8 downto 0),
    --               bus_rdata => rom_bus_rdata,
    --               bus_wstrb => bus_wstrb,
    --               bus_ready => rom_bus_ready,
                   
    --               en => rom_cs,
    --               clk => clk,
    --               resetn => resetn);

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
                    
    sdram_controller : entity work.sdram(arch)
                       generic map(CLK_FREQ => 50000000.0)
                       port map(reset => reset,
                                clk => clk,
                                addr => unsigned(bus_addr(22 downto 0)),
                                data => bus_wdata,
                                we => sdram_we,
                                req => sdram_cs,
                                ack => open,
                                valid => sdram_bus_ready,
                                q => sdram_bus_rdata,
                                
                                sdram_a => sdram_a,
                                sdram_ba => sdram_ba,
                                sdram_dq => sdram_dq,
                                sdram_cke => sdram_cke,
                                sdram_cs_n => sdram_cs_n,
                                sdram_ras_n => sdram_ras_n,
                                sdram_cas_n => sdram_cas_n,
                                sdram_we_n => sdram_we_n,
                                sdram_dqml => sdram_dqml,
                                sdram_dqmh => sdram_dqmh);
                    
    rom : entity work.ram_memory(rtl)
          generic map(SIZE => 1024)
          port map(bus_addr => bus_addr(9 downto 0),
                   bus_wdata => bus_wdata,
                   bus_rdata => rom_bus_rdata,
                   bus_wstrb => bus_wstrb,
                   bus_ready => rom_bus_ready,
                   
                   en => rom_cs,
                   clk => clk,
                   resetn => resetn);
           
    mt48lc16m16a2_dev : mt48lc16m16a2
                        port map(Dq => sdram_dq,
                                 Addr => sdram_a(12 downto 0),
                                 Ba => std_logic_vector(sdram_ba),
                                 Clk => clk,
                                 Cke => sdram_cke,
                                 Cs_n => sdram_cs_n,
                                 Ras_n => sdram_ras_n,
                                 Cas_n => sdram_cas_n,
                                 We_n => sdram_we_n,
                                 Dqm => sdram_dqm);

    sdram_dqm <= sdram_dqmh & sdram_dqml;

    -- ADDRESS DECODING
    process(bus_valid, bus_addr, sdram_bus_rdata, gpio_bus_rdata, rom_bus_rdata)
    begin
        bus_rdata <= (others => '0');
        gpio_cs <= '0';
        rom_cs <= '0';
        sdram_cs <= '0';
    
        if (bus_valid = '1') then
            if (bus_addr(31 downto 24) = X"00") then
                bus_rdata <= rom_bus_rdata;
                rom_cs <= '1';
            elsif (bus_addr(31 downto 24) = X"01") then
                bus_rdata <= gpio_bus_rdata;
                gpio_cs <= '1';
            elsif (bus_addr(31 downto 24) = X"02") then
                bus_rdata <= sdram_bus_rdata;
                sdram_cs <= '1';
            end if;
        end if;
    end process;

    gpio_i <= X"1111_1111";
    bus_ready <= gpio_bus_ready or sdram_bus_ready or rom_bus_ready;
    
    sdram_we <= '1' when bus_wstrb = "0000" else '0'; 

end structural;
