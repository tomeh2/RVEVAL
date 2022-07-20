library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_synth is
    port(
        clk_25mhz : in std_logic;
        
        btn : in std_logic_vector(6 downto 0);
        sw : in std_logic_vector(3 downto 0);
		
        led : out std_logic_vector(7 downto 0)
        );
end top_synth;

architecture structural of top_synth is
	component clkgen
		port(
			CLKI : in std_logic;
			CLKOP : out std_logic;
			CLKOS : out std_logic;
			CLKOS2 : out std_logic;
			CLKOS3 : out std_logic
		);
	end component;

	component picorv32
		/*generic(
			STACKADDR : std_logic_vector(31 downto 0);
			PROGADDR_RESET : std_logic_vector(31 downto 0);
			ENABLE_COUNTERS : boolean := false;
			ENABLE_COUNTERS64 : std_logic := '0';
			ENABLE_REGS_16_31 : std_logic := '1';
			ENABLE_REGS_DUALPORT : std_logic := '1';
			LATCHED_MEM_RDATA : std_logic := '0';
			TWO_STAGE_SHIFT : std_logic := '0';
			BARREL_SHIFTER : std_logic := '0';
			TWO_CYCLE_COMPARE : std_logic := '0';
			TWO_CYCLE_ALU : std_logic := '0';
			COMPRESSED_ISA : std_logic := '0';
			CATCH_ILLINSN : std_logic := '1';
			ENABLE_PCPI : std_logic := '0';
			ENABLE_MUL : std_logic := '0';
			ENABLE_FAST_MUL : std_logic := '0';
			ENABLE_IRQ : std_logic := '0';
			ENABLE_IRQ_QREGS : std_logic := '0';
			ENABLE_IRQ_TIMER : std_logic := '0';
			ENABLE_TRACE : std_logic := '0';
			REGS_INIT_ZERO : std_logic := '0';
			MASKED_IRQ : std_logic_vector(31 downto 0) := (others => '0');
			LATCHED_IRQ : std_logic_vector(31 downto 0) := (others => '0');
			PROGADDR_IRQ : std_logic_vector(31 downto 0) := (others => '0')
		);*/
		port(
			mem_valid : out std_logic;
			mem_instr : out std_logic;
			mem_ready : in std_logic;
			mem_addr : out std_logic_vector(31 downto 0);
			mem_wdata : out std_logic_vector(31 downto 0);
			mem_wstrb : out std_logic_vector(3 downto 0);
			mem_rdata : in std_logic_vector(31 downto 0);
			
			pcpi_wr : in std_logic;
			pcpi_rd : in std_logic_vector(31 downto 0);
			pcpi_ready : in std_logic;
			pcpi_wait : in std_logic;
			
			mem_la_read : out std_logic;
			mem_la_write : out std_logic;
			mem_la_addr : out std_logic_vector(31 downto 0);
			mem_la_wdata : out std_logic_vector(31 downto 0);
			mem_la_wstrb : out std_logic_vector(3 downto 0);
			
			pcpi_valid : out std_logic;
			pcpi_insn : out std_logic_vector(31 downto 0);
			pcpi_rs1 : out std_logic_vector(31 downto 0);
			pcpi_rs2 : out std_logic_vector(31 downto 0);
			
			irq : in std_logic_vector(31 downto 0);
			eoi : out std_logic_vector(31 downto 0);
			
			trace_valid : out std_logic;
			trace_data : out std_logic_vector(35 downto 0);
			
			trap : out std_logic;
			clk : in std_logic;
			resetn : in std_logic
		);
	end component;

    signal bus_valid, bus_instr, bus_ready : std_logic;
    signal bus_addr, bus_wdata, bus_rdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    
    signal irq : std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, resetn : std_logic;
    
    signal gpio_bus_rdata : std_logic_vector(31 downto 0);
    signal gpio_bus_ready, gpio_cs : std_logic;
    
    signal ram_bus_rdata : std_logic_vector(31 downto 0);
    signal ram_bus_ready, ram_cs : std_logic;
    
    signal gpio_i, gpio_o : std_logic_vector(31 downto 0);
begin
	clkgen_inst : clkgen
				  port map(CLKI => clk_25mhz,
						    CLKOP => clk,
						    CLKOS => open,
						    CLKOS2 => open,
						    CLKOS3 => open);
							
	picorv32_inst : picorv32
               port map(mem_valid => bus_valid,
                        mem_instr => bus_instr,
                        mem_ready => bus_ready,
                        mem_addr => bus_addr,
                        mem_wdata => bus_wdata,
                        mem_wstrb => bus_wstrb,
                        mem_rdata => bus_rdata,
                        
                        pcpi_wr => '0',
                        pcpi_rd => X"0000_0000",
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

    resetn <= btn(0);
     
    gpio_i(5 downto 0) <= btn(6 downto 1);
    gpio_i(9 downto 6) <= sw;
    
    led <= gpio_o(7 downto 0);
    
    bus_ready <= gpio_bus_ready or ram_bus_ready;

end structural;
