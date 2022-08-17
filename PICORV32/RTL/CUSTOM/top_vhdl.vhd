library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_vhdl is
    
end top_vhdl;

architecture structural of top_vhdl is
    -- Top 8 bits of the address that are used in address decoding. For ex. if SDRAM_ADDR_TOP has a value of 0x30 then accessing addresses whose top 8 bits
    -- are 0x30 will access SDRAM
    constant ROM_ADDR_TOP : std_logic_vector(7 downto 0) := X"00";
    constant BRAM_ADDR_TOP : std_logic_vector(7 downto 0) := X"10";
    constant SDRAM_ADDR_TOP : std_logic_vector(7 downto 0) := X"20";
    constant IO_BASE_ADDR : std_logic_vector(20 downto 0) := "111111111111111111111";		-- 0xfffff8
	
	constant IO_GPIO_DATA_ADDR : std_logic_vector(10 downto 0) := "11100010000";			-- 0x710        -- LEDs
	constant IO_GPIO_CTL_ADDR : std_logic_vector(10 downto 0) := "00000000100";			-- 0x004
	
	constant IO_UART_DATA_STATUS_ADDR : std_logic_vector(10 downto 0) := "01100000000";			-- 0x300 (1st Byte = DATA | 2nd Byte = STATUS)
	constant IO_UART_BAUD_ADDR : std_logic_vector(10 downto 0) := "01100000010";			-- 0x302

    component sdrc_top
	port(
			sdram_clk: in std_logic; --SDRAM Clock 
			sdram_resetn: in std_logic; --Reset Signal
			cfg_sdr_width: in std_logic_vector(1 downto 0); -- 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
			cfg_colbits: in std_logic_vector(1 downto 0); -- 2'b00 - 8 Bit column address, 
														 -- 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits

			--------------------------------------
			--Wish Bone Interface
			-------------------------------------      
			wb_rst_i: in std_logic;
			wb_clk_i: in std_logic;

			wb_stb_i: in std_logic;
			wb_ack_o: out std_logic;
			wb_addr_i: in std_logic_vector(25 downto 0);
			wb_we_i: in std_logic; -- 1 - Write, 0 - Read
			wb_dat_i: in std_logic_vector(31 downto 0);
			wb_sel_i: in std_logic_vector(3 downto 0); -- Byte enable
			wb_dat_o: out std_logic_vector(31 downto 0);
			wb_cyc_i: in std_logic;
			wb_cti_i: in std_logic_vector(2 downto 0);

			------------------------------------------------
			-- Interface to SDRAMs
			------------------------------------------------
			sdr_cke: out std_logic; -- SDRAM CKE
			sdr_cs_n: out std_logic;            -- SDRAM Chip Select
			sdr_ras_n: out std_logic; -- SDRAM ras
			sdr_cas_n: out std_logic; -- SDRAM cas
			sdr_we_n: out std_logic; -- SDRAM write enable
			sdr_dqm: out std_logic_vector(1 downto 0); -- SDRAM Data Mask
			sdr_ba: out std_logic_vector(1 downto 0); -- SDRAM Bank Enable
			sdr_addr: out std_logic_vector(12 downto 0); -- SDRAM Address
			sdr_dq: inout std_logic_vector(15 downto 0); -- SDRA Data Input/output

			------------------------------------------------
			-- Configuration Parameter
			------------------------------------------------
			sdr_init_done: out std_logic; -- Indicate SDRAM Initialisation Done
			cfg_sdr_tras_d: in std_logic_vector(3 downto 0); -- Active to precharge delay
			cfg_sdr_trp_d: in std_logic_vector(3 downto 0); -- Precharge to active delay
			cfg_sdr_trcd_d: in std_logic_vector(3 downto 0); -- Active to R/W delay
			cfg_sdr_en: in std_logic; -- Enable SDRAM controller
			cfg_req_depth: in std_logic_vector(1 downto 0); --Maximum Request accepted by SDRAM controller
			cfg_sdr_mode_reg: in std_logic_vector(12 downto 0);
			cfg_sdr_cas: in std_logic_vector(2 downto 0); -- SDRAM CAS Latency
			cfg_sdr_trcar_d: in std_logic_vector(3 downto 0); -- Auto-refresh period
			cfg_sdr_twr_d: in std_logic_vector(3 downto 0); -- Write recovery delay
			cfg_sdr_rfsh: in std_logic_vector(11 downto 0);
			cfg_sdr_rfmax: in std_logic_vector(2 downto 0)

	);
	end component;

    signal bus_valid, bus_instr, bus_ready, bus_write : std_logic;
    signal bus_addr, bus_wdata, bus_rdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    
    signal irq : std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, resetn, reset, sdram_we, ser_tx, ser_rx : std_logic;
    
    signal uart_sim_bit : std_logic;
    signal uart_reg_div_we : std_logic_vector(3 downto 0);
    signal uart_reg_div_di, uart_reg_div_do, uart_reg_dat_di, uart_reg_dat_do : std_logic_vector(31 downto 0);
    signal uart_reg_dat_we, uart_reg_dat_re, uart_reg_dat_wait, uart_bus_ready : std_logic;
    
    constant T : time := 20ns;
    
    signal gpio_bus_rdata : std_logic_vector(31 downto 0);
    signal gpio_bus_ready, gpio_cs : std_logic;
    
    signal rom_bus_rdata : std_logic_vector(31 downto 0);
    signal rom_bus_ready, rom_cs : std_logic;
    
    signal ram_bus_rdata : std_logic_vector(31 downto 0);
    signal ram_bus_ready, ram_cs : std_logic;
    
    signal sdram_bus_rdata : std_logic_vector(31 downto 0);
    signal sdram_bus_ready, sdram_init_done, sdram_valid, sdram_cs_read, sdram_cs_write, sdram_cs, sdram_ack : std_logic;
    
    signal gpio_i, gpio_o : std_logic_vector(31 downto 0);
    
    signal we : std_logic;
    
    signal sdram_au : unsigned(12 downto 0);
    signal sdram_a : std_logic_vector(12 downto 0);
    signal sdram_ba : std_logic_vector(1 downto 0);
    signal sdram_dq : std_logic_vector(15 downto 0);
    signal sdram_cke : std_logic;
    signal sdram_cs_n : std_logic;
    signal sdram_ras_n : std_logic;
    signal sdram_cas_n : std_logic;
    signal sdram_we_n : std_logic;
    signal sdram_dqml : std_logic;
    signal sdram_dqmh : std_logic;
    signal sdram_dqm : std_logic_vector(1 downto 0);
    
    signal test_state : std_logic_vector(1 downto 0);
	
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
               generic map(STACKADDR => X"1000_1000",
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
    
    rom : entity work.rom_memory(rtl)
		  generic map(SIZE_BYTES => 4096)
		  port map(bus_addr => bus_addr(11 downto 0),
				   bus_rdata => rom_bus_rdata,
				   bus_ready => rom_bus_ready,
				   
				   en => rom_cs,
				   clk => clk,
				   resetn => resetn);
					
    ram : entity work.ram_memory(rtl)
          generic map(SIZE_BYTES => 4096)
          port map(bus_addr => bus_addr(11 downto 0),
                   bus_wdata => bus_wdata,
                   bus_rdata => ram_bus_rdata,
                   bus_wstrb => bus_wstrb,
                   bus_ready => ram_bus_ready,
                   
                   en => ram_cs,
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
                  
    bus_write <= '1' when bus_wstrb /= "0000" else '0'; 
    sdram_controller: sdrc_top
				      port map(sdram_clk => clk,
								sdram_resetn => resetn,
								cfg_sdr_width => "11",
								cfg_colbits => "01",
								
								wb_rst_i => reset,
								wb_clk_i => clk,
								wb_stb_i => sdram_cs,
								wb_ack_o => sdram_ack,
								wb_addr_i => bus_addr(25 downto 0),
								wb_we_i => bus_write,
								wb_dat_i => bus_wdata,
								wb_sel_i => bus_wstrb,
								wb_dat_o => sdram_bus_rdata,
								wb_cyc_i => '1',
								wb_cti_i => "000",
								
								sdr_cke => sdram_cke,
								sdr_cs_n => sdram_cs_n,
								sdr_ras_n => sdram_ras_n,
								sdr_cas_n => sdram_cas_n,
								sdr_we_n => sdram_we_n,
								sdr_dqm => sdram_dqm,
								sdr_ba => sdram_ba,
								sdr_addr => sdram_a,
								sdr_dq => sdram_dq,
								
								sdr_init_done => sdram_init_done,
								cfg_sdr_tras_d => "1000",
								cfg_sdr_trp_d => "1000",
								cfg_sdr_trcd_d => "1000",
								cfg_sdr_en => '1', 
								cfg_req_depth => "00",
								cfg_sdr_mode_reg => "0000000000000",
								cfg_sdr_cas => "100",
								cfg_sdr_trcar_d => "1000",
								cfg_sdr_twr_d => "1000",
								cfg_sdr_rfsh => "000000100000",
								cfg_sdr_rfmax => "100" 
								);
                    
    sdram_au <= unsigned(sdram_a);
    mt48lc16m16a2_dev : mt48lc16m16a2
                        port map(Dq => sdram_dq,
                                 Addr => sdram_au,
                                 Ba => std_logic_vector(sdram_ba),
                                 Clk => clk,
                                 Cke => sdram_cke,
                                 Cs_n => sdram_cs_n,
                                 Ras_n => sdram_ras_n,
                                 Cas_n => sdram_cas_n,
                                 We_n => sdram_we_n,
                                 Dqm => sdram_dqm);

    /*
    uart : simpleuart
           port map(clk => clk,
                    resetn => resetn,
                    
                    ser_tx => ser_tx,
                    ser_rx => ser_rx,
                    
                    reg_div_we => uart_reg_div_we,
                    reg_div_di => bus_wdata,
                    reg_div_do => uart_reg_div_do,
                    
                    reg_dat_we => uart_reg_dat_we,
                    reg_dat_re => uart_reg_dat_re,
                    
                    reg_dat_di => bus_wdata,
                    reg_dat_do => uart_reg_dat_do,
                    
                    reg_dat_wait => uart_reg_dat_wait
                    );*/
                    
    sio_inst : entity work.sio(Behavioral)
               generic map(C_clk_freq => 50)
               port map(bus_write => we,
                        byte_sel => bus_wstrb,
                        bus_in => bus_wdata,
                        bus_out => uart_reg_div_do,
                        break => open,
                        rxd => ser_rx,
                        txd => ser_tx,
                        ce => uart_reg_dat_re or uart_reg_dat_we,
                        clk => clk);

    sdram_dqm <= sdram_dqmh & sdram_dqml;

    -- ADDRESS DECODING
    -- ADDRESS DECODING
    process(bus_valid, bus_addr, bus_wstrb, sdram_bus_rdata, gpio_bus_rdata, rom_bus_rdata, ram_bus_rdata, uart_reg_div_do, uart_reg_dat_wait)
    begin
		bus_rdata <= (others => '0');
		gpio_cs <= '0';
		rom_cs <= '0';
		ram_cs <= '0';
		sdram_cs_write <= '0';
				
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
				when SDRAM_ADDR_TOP =>
					bus_rdata <= sdram_bus_rdata;
				when X"FF" => 
					if (bus_addr(31 downto 11) = IO_BASE_ADDR) then
						if (bus_addr(10 downto 0) = IO_UART_BAUD_ADDR) then
							if (bus_wstrb = "0000") then
								bus_rdata <= uart_reg_div_do;
								uart_bus_ready <= '1';
							else
								uart_reg_div_we <= "1111";
								uart_bus_ready <= '1';
							end if;
						elsif (bus_addr(10 downto 0) = IO_UART_DATA_STATUS_ADDR) then
							if (bus_wstrb = "0000") then
								bus_rdata <= uart_reg_div_do;
								uart_reg_dat_re <= '1';
								
								--bus_rdata(15 downto 8) <= "0000000" & uart_sim_bit;
							    uart_bus_ready <= '1';
							else
							    uart_bus_ready <= '1';
								uart_reg_dat_we <= '1';
							end if;
						elsif (bus_addr(10 downto 0) = IO_GPIO_DATA_ADDR and bus_wstrb = "0001") then
						    if (bus_wstrb = "0000") then
						        bus_rdata <= gpio_bus_rdata;
							    gpio_cs <= '1';
						    else
						        gpio_cs <= '1';
						    end if;
						end if;
					end if;
					when others => 
					
			end case;
        end if;
    end process;
    
    sdram_cs_proc : process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                test_state <= "00";
            else
                if (test_state = "00") then
                    if (bus_addr(31 downto 24) = SDRAM_ADDR_TOP and bus_valid = '1') then
                        test_state <= "01";
                    else
                        test_state <= "00";
                    end if;
                elsif (test_state = "01") then
                    if (sdram_ack = '1' and bus_wstrb = "0000") then
                        test_state <= "10";
                    elsif (sdram_ack = '1' and bus_wstrb /= "0000") then
                        test_state <= "00";
                    else
                        test_state <= "01";
                    end if;
                else
                    if (sdram_valid = '1') then
                        test_state <= "00";
                    else
                        test_state <= "10";
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    sdram_cs_proc_2 : process(test_state)
    begin
        if (test_state = "00") then
            sdram_cs_read <= '0';
        elsif (test_state = "01") then
            sdram_cs_read <= '1';
        else
            sdram_cs_read <= '0';
        end if;
    end process;
    
    sdram_cs_proc_3 : process(test_state, bus_wstrb, sdram_cs_read)
    begin
        if (test_state /= "00") then
            if (bus_wstrb = "0000") then
                sdram_cs <= sdram_cs_read;
            else 
                sdram_cs <= '1';
            end if;
        else
            sdram_cs <= '0';
        end if;
    end process; 

    gpio_i <= X"1111_1111";
    bus_ready <= gpio_bus_ready or rom_bus_ready or sdram_bus_ready or uart_bus_ready or ram_bus_ready;
    
    process
    begin
        ser_rx <= '1';
        wait for 500us;
        ser_rx <= '0';
        wait for 100us;
        ser_rx <= '1';
        wait for 1sec;
    end process;
    
    process
    begin
        uart_sim_bit <= '0';
        wait for 100us;
        uart_sim_bit <= '1';
        wait for 1ms;
    end process;
    
    sdram_bus_ready <= sdram_ack when sdram_we = '1' else sdram_valid;
    
    we <= '1' when bus_wstrb /= "0000" else '0';
    sdram_we <= '1' when bus_wstrb /= "0000" else '0'; 

end structural;
