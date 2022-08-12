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
    component clk_wiz_0
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
    clk_wiz : clk_wiz_0
    port map(clk_in1_p => SYSCLK_P,
             clk_in1_n => SYSCLK_N,
             
             clk_out1 => clk,
             locked => clk_locked);

    picorv32 : entity work.picorv32(picorv32)
               generic map(STACKADDR => X"1000_8000",
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
          port map(bus_addr => bus_addr(11 downto 0),
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
                    
        ser_tx => ftdi_rxd,
        ser_rx => ftdi_txd,
                    
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
