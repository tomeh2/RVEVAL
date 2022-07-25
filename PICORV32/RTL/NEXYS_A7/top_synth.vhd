library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_synth is
    port(
        CLK100MHZ : in std_logic;
        
        CPU_RESETN : in std_logic;
        
        BTND : in std_logic;
        BTNU : in std_logic;
        BTNL : in std_logic;
        BTNR : in std_logic;
        BTNC : in std_logic;
        
        LED : out std_logic_vector(15 downto 0)
        );
end top_synth;

architecture structural of top_synth is
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
begin
    clk <= CLK100MHZ;

    picorv32_cpu : picorv32
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
          generic map(SIZE => 512)
          port map(bus_addr => bus_addr(10 downto 0),
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

    resetn <= CPU_RESETN;
     
    gpio_i(0) <= BTND;
    gpio_i(1) <= BTNU;
    gpio_i(2) <= BTNL;
    gpio_i(3) <= BTNR;
    gpio_i(4) <= BTNC;
    
    LED <= gpio_o(15 downto 0);
    
    bus_ready <= gpio_bus_ready or ram_bus_ready;

end structural;
