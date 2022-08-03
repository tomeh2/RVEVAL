library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_synth is
    port(
        clk_25mhz : in std_logic;
        
        btn : in std_logic_vector(6 downto 0);
        sw : in std_logic_vector(3 downto 0);
		
        led : out std_logic_vector(7 downto 0);
		
		sdram_clk : out std_logic;
		sdram_a : out unsigned(12 downto 0);
		sdram_ba : out unsigned(1 downto 0);
		sdram_d : inout std_logic_vector(15 downto 0);
		sdram_cke : out std_logic;
		sdram_csn : out std_logic;
		sdram_rasn : out std_logic;
		sdram_casn : out std_logic;
		sdram_wen : out std_logic;
		sdram_dqm : out std_logic_vector(1 downto 0);
		
		ftdi_rxd : out std_logic;
		ftdi_txd : in std_logic
        );
end top_synth;

architecture structural of top_synth is
	component pll_sdram_1
		port(
			CLKI : in std_logic;
			CLKOP : out std_logic;
			CLKOS : out std_logic
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

    signal bus_valid, bus_instr, bus_ready : std_logic;
    signal bus_addr, bus_wdata, bus_rdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    
    signal irq : std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, clk_sdram, resetn, reset : std_logic;
    
    signal gpio_bus_rdata : std_logic_vector(31 downto 0);
    signal gpio_bus_ready, gpio_cs : std_logic;
    
    signal rom_bus_rdata : std_logic_vector(31 downto 0);
    signal rom_bus_ready, rom_cs : std_logic;
	
	signal sdram_bus_rdata : std_logic_vector(31 downto 0);
    signal sdram_bus_ready, sdram_valid, sdram_cs, sdram_ack, sdram_we : std_logic;
    
	signal uart_reg_div_we : std_logic_vector(3 downto 0);
    signal uart_reg_div_di, uart_reg_div_do, uart_reg_dat_di, uart_reg_dat_do : std_logic_vector(31 downto 0);
    signal uart_reg_dat_we, uart_reg_dat_re, uart_reg_dat_wait, uart_bus_ready : std_logic;
	
    signal gpio_i, gpio_o : std_logic_vector(31 downto 0);
	
	signal sdram_cs_read, sdram_cs_write : std_logic;
	signal sdram_bus_access_state : std_logic_vector(1 downto 0);
begin
	sdram_clk <= clk_sdram;

	-- SDRAM clock is also 50 MHz but phase shifted by 90 degrees
	clkgen_inst : pll_sdram_1
				  port map(CLKI => clk_25mhz,
						    CLKOP => clk_sdram,
						    CLKOS => clk);
							
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
                    
    rom : entity work.ram_memory(rtl)
          generic map(SIZE => 1024)
          port map(bus_addr => bus_addr(11 downto 0),
                   bus_wdata => bus_wdata,
                   bus_rdata => rom_bus_rdata,
                   bus_wstrb => bus_wstrb,
                   bus_ready => rom_bus_ready,
                   
                   en => rom_cs,
                   clk => clk,
                   resetn => resetn);
				   
	sdram_controller : entity work.sdram(arch)
                       generic map(CLK_FREQ => 50.0)
                       port map(reset => reset,
                                clk => clk,
                                addr => unsigned(bus_addr(22 downto 0)),
                                data => bus_wdata,
                                we => sdram_we,
                                req => sdram_cs,
                                ack => sdram_ack,
                                valid => sdram_valid,
                                q => sdram_bus_rdata,
                                
                                sdram_a => sdram_a,
                                sdram_ba => sdram_ba,
                                sdram_dq => sdram_d,
                                sdram_cke => sdram_cke,
                                sdram_cs_n => sdram_csn,
                                sdram_ras_n => sdram_rasn,
                                sdram_cas_n => sdram_casn,
                                sdram_we_n => sdram_wen,
                                sdram_dqml => sdram_dqm(0),
                                sdram_dqmh => sdram_dqm(1));
					
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
    process(bus_valid, bus_addr, bus_wstrb, sdram_bus_rdata, gpio_bus_rdata, rom_bus_rdata, uart_reg_div_do, uart_reg_dat_wait)
    begin
        bus_rdata <= (others => '0');
        gpio_cs <= '0';
        rom_cs <= '0';
        sdram_cs_write <= '0';
    
        uart_reg_div_we <= (others => '0');
        uart_reg_dat_we <= '0';
        uart_reg_dat_re <= '0';
        uart_bus_ready <= '0';
        if (bus_valid = '1') then
            if (bus_addr(31 downto 24) = X"00") then
                bus_rdata <= rom_bus_rdata;
                rom_cs <= '1';
            elsif (bus_addr(31 downto 24) = X"10") then
                bus_rdata <= gpio_bus_rdata;
                gpio_cs <= '1';
            elsif (bus_addr(31 downto 24) = X"20") then
                bus_rdata <= sdram_bus_rdata;
                --sdram_cs <= '1';
            elsif (bus_addr(31 downto 24) = X"30") then
                if (bus_addr(23 downto 0) = X"000000") then
                    if (bus_wstrb = "0000") then
                        bus_rdata <= uart_reg_div_do;
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
                    uart_bus_ready <= not uart_reg_dat_wait;
                end if;
            end if;
        end if;
    end process;
	
	sdram_cs_proc : process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                sdram_bus_access_state <= "00";
            else
                if (sdram_bus_access_state = "00") then
                    if (bus_addr(31 downto 24) = X"02" and bus_valid = '1') then
                        sdram_bus_access_state <= "01";
                    else
                        sdram_bus_access_state <= "00";
                    end if;
                elsif (sdram_bus_access_state = "01") then
                    if (sdram_ack = '1' and bus_wstrb = "0000") then
                        sdram_bus_access_state <= "10";
                    elsif (sdram_ack = '1' and bus_wstrb /= "0000") then
                        sdram_bus_access_state <= "00";
                    else
                        sdram_bus_access_state <= "01";
                    end if;
                else
                    if (sdram_valid = '1') then
                        sdram_bus_access_state <= "00";
                    else
                        sdram_bus_access_state <= "10";
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    sdram_cs_proc_2 : process(sdram_bus_access_state)
    begin
        if (sdram_bus_access_state = "00") then
            sdram_cs_read <= '0';
        elsif (sdram_bus_access_state = "01") then
            sdram_cs_read <= '1';
        else
            sdram_cs_read <= '0';
        end if;
    end process;
    
    sdram_cs_proc_3 : process(sdram_bus_access_state, bus_wstrb, sdram_cs_read)
    begin
        if (sdram_bus_access_state /= "00") then
            if (bus_wstrb = "0000") then
                sdram_cs <= sdram_cs_read;
            else 
                sdram_cs <= '1';
            end if;
        else
            sdram_cs <= '0';
        end if;
    end process; 


    resetn <= btn(0);
     
    gpio_i(5 downto 0) <= btn(6 downto 1);
    gpio_i(9 downto 6) <= sw;
    
    led <= gpio_o(7 downto 0);
    
    bus_ready <= gpio_bus_ready or rom_bus_ready or sdram_bus_ready or uart_bus_ready;
	
	sdram_bus_ready <= sdram_ack when sdram_we = '1' else sdram_valid;
    
    sdram_we <= '1' when bus_wstrb /= "0000" else '0'; 
	
	reset <= not resetn;

end structural;
