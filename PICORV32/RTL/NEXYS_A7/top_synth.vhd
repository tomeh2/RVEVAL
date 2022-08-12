library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_synth is
    port(
        CLK100MHZ : in std_logic;
        
        CPU_RESETN : in std_logic;
        
        UART_TXD_IN : in std_logic;
        UART_RXD_OUT : out std_logic;
        
        LED : out std_logic_vector(15 downto 0)
        );
end top_synth;

architecture structural of top_synth is
    component clk_wiz_0_clk_wiz
    port
        (-- Clock in ports
        -- Clock out ports
        clk_out1          : out    std_logic;
        -- Status and control signals
        locked             : out     std_logic;
        clk_in1           : in     std_logic
     );
    end component;
    
    component picorv32
		generic(
			STACKADDR : std_logic_vector(31 downto 0) := X"1000_8000";
			PROGADDR_RESET : std_logic_vector(31 downto 0) := X"0000_0000";
			ENABLE_COUNTERS : boolean := false;
			ENABLE_COUNTERS64 : boolean := false;
			ENABLE_REGS_16_31 : boolean := true;
			ENABLE_REGS_DUALPORT : boolean := true;
			LATCHED_MEM_RDATA : boolean := false;
			TWO_STAGE_SHIFT : boolean := false;
			BARREL_SHIFTER : boolean := false;
			TWO_CYCLE_COMPARE : boolean := false;
			TWO_CYCLE_ALU : boolean := false;
			COMPRESSED_ISA : boolean := false;
			CATCH_ILLINSN : boolean := true;
			ENABLE_PCPI : boolean := false;
			ENABLE_MUL : boolean := false;
			ENABLE_FAST_MUL : boolean := false;
			ENABLE_IRQ : boolean := false;
			ENABLE_IRQ_QREGS : boolean := false;
			ENABLE_IRQ_TIMER : boolean := false;
			ENABLE_TRACE : boolean := false;
			REGS_INIT_ZERO : boolean := false;
			MASKED_IRQ : std_logic_vector(31 downto 0) := (others => '0');
			LATCHED_IRQ : std_logic_vector(31 downto 0) := (others => '0');
			PROGADDR_IRQ : std_logic_vector(31 downto 0) := (others => '0')
		);
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
    
    component simpleuart
		port(
			clk : in std_logic;
			resetn : in std_logic;
			
			ser_tx : out std_logic;
			ser_rx : in std_logic;
			
			reg_div_we : in std_logic_vector(3 downto 0);
			reg_div_di : in std_logic_vector(31 downto 0);
			reg_div_do : out std_logic_vector(31 downto 0);
			
			reg_dat_we : in std_logic;
			reg_dat_re : in std_logic;
			
			reg_dat_di : in std_logic_vector(31 downto 0);
			reg_dat_do : out std_logic_vector(31 downto 0);
			reg_dat_wait : out std_logic
		);
	end component;

    -- Top 8 bits of the address that are used in address decoding. For ex. if SDRAM_ADDR_TOP has a value of 0x30 then accessing addresses whose top 8 bits
    -- are 0x30 will access SDRAM
    
    -- NOTE: XILINX boards do not have built-in SDRAM, so it has been replaced with a large BRAM
    constant ROM_ADDR_TOP : std_logic_vector(7 downto 0) := X"00";
    constant BRAM_ADDR_TOP : std_logic_vector(7 downto 0) := X"10";
    constant UART_ADDR_TOP : std_logic_vector(7 downto 0) := X"20";
    constant GPIO_ADDR_TOP : std_logic_vector(7 downto 0) := X"30";

    signal bus_valid, bus_instr, bus_ready : std_logic;
    signal bus_addr, bus_wdata, bus_rdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    
    signal irq : std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, clk_sdram, clk_locked, resetn, reset : std_logic;
    
    signal gpio_bus_rdata : std_logic_vector(31 downto 0);
    signal gpio_bus_ready, gpio_cs : std_logic;
    
    signal rom_bus_rdata : std_logic_vector(31 downto 0);
    signal rom_bus_ready, rom_cs : std_logic;
	
	signal ram_bus_rdata : std_logic_vector(31 downto 0);
    signal ram_bus_ready, ram_cs : std_logic;

	signal uart_reg_div_we : std_logic_vector(3 downto 0);
    signal uart_reg_div_di, uart_reg_div_do, uart_reg_dat_di, uart_reg_dat_do : std_logic_vector(31 downto 0);
    signal uart_reg_dat_we, uart_reg_dat_re, uart_reg_dat_wait, uart_bus_ready : std_logic;
	
    signal gpio_i, gpio_o : std_logic_vector(31 downto 0);
begin
    clk_wiz : clk_wiz_0_clk_wiz
    port map(clk_in1 => CLK100MHZ,
             
             clk_out1 => clk,
             locked => clk_locked);

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
                    
	rom : entity work.rom_memory(rtl)
		  generic map(SIZE_BYTES => 4096)
		  port map(bus_addr => bus_addr(11 downto 0),
				   bus_rdata => rom_bus_rdata,
				   bus_ready => rom_bus_ready,
				   
				   en => rom_cs,
				   clk => clk,
				   resetn => resetn);
					
    ram : entity work.ram_memory(rtl)
          generic map(SIZE_BYTES => 32768)
          port map(bus_addr => bus_addr(14 downto 0),
                   bus_wdata => bus_wdata,
                   bus_rdata => ram_bus_rdata,
                   bus_wstrb => bus_wstrb,
                   bus_ready => ram_bus_ready,
                   
                   en => ram_cs,
                   clk => clk,
                   resetn => resetn);
           
    uart : simpleuart
		port map(clk => clk,
        resetn => resetn,
                    
        ser_tx => UART_RXD_OUT,
        ser_rx => UART_TXD_IN,
                    
        reg_div_we => uart_reg_div_we,
        reg_div_di => bus_wdata,
        reg_div_do => uart_reg_div_do,
                    
        reg_dat_we => uart_reg_dat_we,
        reg_dat_re => uart_reg_dat_re,
                    
        reg_dat_di => bus_wdata,
        reg_dat_do => uart_reg_dat_do,
                   
        reg_dat_wait => uart_reg_dat_wait);

    -- ADDRESS DECODING
    process(bus_valid, bus_addr, bus_wstrb, gpio_bus_rdata, rom_bus_rdata, ram_bus_rdata, uart_reg_div_do, uart_reg_dat_wait)
    begin
		bus_rdata <= (others => '0');
		gpio_cs <= '0';
		rom_cs <= '0';
		ram_cs <= '0';	
		
		uart_reg_div_we <= (others => '0');
		uart_reg_dat_we <= '0';
		uart_reg_dat_re <= '0';
		uart_bus_ready <= '0';
	
        if (bus_valid = '1') then
			case bus_addr(31 downto 24) is
				when ROM_ADDR_TOP =>
					bus_rdata <= rom_bus_rdata;
					rom_cs <= '1';
				when BRAM_ADDR_TOP => 
					bus_rdata <= ram_bus_rdata;
					ram_cs <= '1';
				when UART_ADDR_TOP =>
					if (bus_addr(23 downto 0) = X"000000") then
						if (bus_wstrb = "0000") then
							bus_rdata <= uart_reg_div_do;
							uart_bus_ready <= '1';
						else
							uart_reg_div_we <= "1111";
							uart_bus_ready <= '1';
						end if;
					elsif (bus_addr(23 downto 0) = X"000004") then
						uart_reg_dat_we <= '1';
						uart_bus_ready <= not uart_reg_dat_wait;
					elsif (bus_addr(23 downto 0) = X"000008") then
						bus_rdata <= uart_reg_dat_do;
						uart_reg_dat_re <= '1';
						uart_bus_ready <= '1';
					end if;
				when GPIO_ADDR_TOP => 
					bus_rdata <= gpio_bus_rdata;
					gpio_cs <= '1';
				when others => 
					
			end case;
        end if;
    end process;


    resetn <= CPU_RESETN;

    
    LED <= gpio_o(15 downto 0);
    
    bus_ready <= gpio_bus_ready or ram_bus_ready or rom_bus_ready or uart_bus_ready;

end structural;
