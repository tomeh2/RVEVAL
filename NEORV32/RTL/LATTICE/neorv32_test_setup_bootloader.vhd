-- #################################################################################################
-- # << NEORV32 - Test Setup using the UART-Bootloader to upload and run executables >>            #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2021, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32                           #
-- #################################################################################################

-- UNCOMMENT NEO_CPU_CONTROL LINES 1903

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

use neorv32.f32c_pack.all;

entity neorv32_test_setup_bootloader is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 62000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 128*1024     -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    clk_25mhz: in std_logic;
    
    btn: in std_logic_vector(6 downto 0);
    -- GPIO --
    led: out std_logic_vector(7 downto 0);
    
	sdram_clk: out std_logic;
	sdram_a: out std_logic_vector(12 downto 0);
	sdram_ba: out std_logic_vector(1 downto 0);
	sdram_d: inout std_logic_vector(15 downto 0);
	sdram_cke: out std_logic;
	sdram_csn: out std_logic;
	sdram_rasn: out std_logic;
	sdram_casn: out std_logic;
	sdram_wen: out std_logic;
	sdram_dqm: out std_logic_vector(1 downto 0);

	
    --gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    ftdi_rxd : out std_ulogic; -- UART0 send data
    ftdi_txd : in  std_ulogic  -- UART0 receive data
  );
end entity;

architecture neorv32_test_setup_bootloader_rtl of neorv32_test_setup_bootloader is
	component pll_65
	port(
		CLKI : in std_logic;
		CLKOP : out std_logic;
		CLKOS : out std_logic
	);
	end component;

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

  signal con_gpio_o : std_ulogic_vector(63 downto 0);

  signal clk_i, clk_sdram, rstn_i : std_logic;
  
  signal wb_tag : std_ulogic_vector(02 downto 0); -- request tag
  signal wb_addr : std_ulogic_vector(31 downto 0); -- address
  signal wb_dat_i : std_ulogic_vector(31 downto 0) := (others => 'U'); -- read data
  signal wb_dat_o : std_ulogic_vector(31 downto 0); -- write data
  signal wb_we  : std_ulogic; -- read/write
  signal wb_sel : std_ulogic_vector(03 downto 0); -- byte enable
  signal wb_stb : std_ulogic; -- strobe
  signal wb_cyc : std_ulogic; -- valid cycle
  signal wb_ack : std_ulogic := 'L'; -- transfer acknowledge
  signal wb_err : std_ulogic := 'L'; -- transfer error
  
  signal rom_addr : std_logic_vector(29 downto 0);
  signal rom_rdata : std_logic_vector(31 downto 0);
  signal rom_ack : std_logic;
  signal rom_stb : std_logic;
  
  signal ram_wr_en : std_logic;
  signal ram_rdata : std_logic_vector(31 downto 0);
  signal ram_sel : std_logic_vector(3 downto 0);
  signal ram_ack : std_logic;
  signal ram_we : std_logic;
  signal ram_stb : std_logic;
  signal ram_cyc : std_logic;
  signal ram_en : std_logic;
  
  signal sdram_wr_en : std_logic;
  signal sdram_wb_rdata : std_logic_vector(31 downto 0);
  signal sdram_wb_sel : std_logic_vector(3 downto 0);
  signal sdram_wb_ack : std_logic;
  signal sdram_wb_we : std_logic;
  signal sdram_wb_stb : std_logic;
  signal sdram_wb_cyc : std_logic;
  signal sdram_wb_en : std_logic;
  
  signal sdram_ack_delayed : std_logic;
  
  signal led_out : std_logic_vector(15 downto 0);
  
  signal sdram_ack_delay : std_logic;
begin
--    process
--    begin
--        clk_i <= '0';
--        wait for 10ns;
--        clk_i <= '1';
--        wait for 10ns;
--    end process;
    
--    rstn_i <= '0', '1' after 30ns;

    rstn_i <= btn(0);
	
	sdram_clk <= clk_sdram;
	
	clk_gen: pll_65
		port map(CLKI => clk_25mhz,
				  CLKOP => clk_sdram,
				  CLKOS => clk_i);

  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: entity neorv32.neorv32_top
  generic map (
    -- General --
    CLOCK_FREQUENCY              => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    INT_BOOTLOADER_EN            => false,              -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- RISC-V CPU Extensions --
    CPU_EXTENSION_RISCV_C        => false,              -- implement compressed extension?
    CPU_EXTENSION_RISCV_M        => false,              -- implement mul/div extension?
    CPU_EXTENSION_RISCV_Zicsr    => true,              -- implement CSR system?
    CPU_EXTENSION_RISCV_Zicntr   => true,              -- implement base counters?
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN              => false,              -- implement processor-internal instruction memory
    --MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN              => false,              -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_EN                   => false,              -- implement general purpose input/output port unit (GPIO)?
    IO_MTIME_EN                  => true,              -- implement machine system timer (MTIME)?
    IO_UART0_EN                  => true,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    
	ICACHE_EN					 => false,
	FAST_MUL_EN                  => true,				-- use DSPs for M extension's multiplier
    FAST_SHIFT_EN                => true,  			-- use barrel shifter for shift operations
	
	MEM_EXT_ASYNC_RX             => false,  -- use register buffer for RX data when false
    MEM_EXT_ASYNC_TX             => false,  -- use register buffer for TX data when false
	
    MEM_EXT_EN                   => true
  )
  port map (
    -- Global control --
    clk_i       => clk_i,       -- global clock, rising edge
    rstn_i      => rstn_i,      -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o      => con_gpio_o,  -- parallel output
    -- primary UART0 (available if IO_UART0_EN = true) --
    --uart0_txd_o => UART_RXD_OUT, -- UART0 send data
    --uart0_rxd_i => UART_TXD_IN,  -- UART0 receive data
    
    wb_tag_o => wb_tag, -- request tag
    wb_adr_o => wb_addr,  -- address
    wb_dat_i => wb_dat_i, -- read data
    wb_dat_o => wb_dat_o,  -- write data
    wb_we_o => wb_we,   -- read/write
    wb_sel_o => wb_sel,  -- byte enable
    wb_stb_o => wb_stb, -- strobe
    wb_cyc_o => wb_cyc,  -- valid cycle
    wb_ack_i => wb_ack,  -- transfer acknowledge
    
    led_out => led_out,
    rxd => ftdi_txd,
    txd => ftdi_rxd
  );
  
    rom : entity neorv32.rom
          generic map(C_arch => ARCH_RV32,
                      C_big_endian => false,
	                  C_boot_spi => false)
          port map(clk => clk_i,
                   strobe => rom_stb,
                   addr => rom_addr,
                   data_ready => rom_ack,
                   data_out => rom_rdata);

   
    ram_memory : entity neorv32.ram_memory
                 generic map(SIZE_BYTES => 128 * 1024)
                 port map(bus_addr => std_logic_vector(wb_addr(16 downto 0)),
                          bus_wdata => std_logic_vector(wb_dat_o),
                          bus_rdata => ram_rdata,
                          bus_wstrb => std_logic_vector(wb_sel),
                          bus_ready => ram_ack,
                          
                          wr_en => ram_wr_en,
                          stb => ram_en,
                          clk => clk_i,
                          resetn => rstn_i);
	
	sdram_controller: sdrc_top
				      port map(sdram_clk => clk_i,
								sdram_resetn => rstn_i,
								cfg_sdr_width => "01",
								cfg_colbits => "01",
								
								wb_rst_i => not rstn_i,
								wb_clk_i => clk_i,
								wb_stb_i => sdram_wb_stb,
								wb_ack_o => sdram_wb_ack,
								wb_addr_i => wb_addr(25 downto 0),
								wb_we_i => sdram_wb_we,
								wb_dat_i => wb_dat_o,
								wb_sel_i => sdram_wb_sel,
								wb_dat_o => sdram_wb_rdata,
								wb_cyc_i => sdram_wb_cyc,
								wb_cti_i => "000",
								
								sdr_cke => sdram_cke,
								sdr_cs_n => sdram_csn,
								sdr_ras_n => sdram_rasn,
								sdr_cas_n => sdram_casn,
								sdr_we_n => sdram_wen,
								sdr_dqm => sdram_dqm,
								sdr_ba => sdram_ba,
								sdr_addr => sdram_a,
								sdr_dq => sdram_d,
								
								sdr_init_done => open,
								cfg_sdr_tras_d => "0011",
								cfg_sdr_trp_d => "0011",
								cfg_sdr_trcd_d => "0011",
								cfg_sdr_en => '1', 
								cfg_req_depth => "01",
								cfg_sdr_mode_reg => "0000000110001",
								cfg_sdr_cas => "100",
								cfg_sdr_trcar_d => "0011",
								cfg_sdr_twr_d => "0011",
								cfg_sdr_rfsh => "000010000000",
								cfg_sdr_rfmax => "011" 
								);

	

    process(wb_addr, ram_rdata, rom_rdata, wb_stb, wb_cyc, wb_sel, wb_we, sdram_wb_rdata)
    begin
		rom_addr <= (others => '0');
        ram_wr_en <= '0';
        wb_dat_i <= (others => '0');
        rom_stb <= '0';
		ram_en <= '0';
	
		sdram_wb_we <= '0';
        sdram_wb_cyc <= '0';
        sdram_wb_stb <= '0';
        sdram_wb_sel <= "0000";
		sdram_wb_en <= '0';
		
		ram_we <= '0';
        ram_cyc <= '0';
        ram_stb <= '0';
        ram_sel <= X"0";
		ram_en <= '0';
	
        case wb_addr(31 downto 28) is
            when X"8" => 
                sdram_wb_we <= wb_we;
                sdram_wb_cyc <= wb_cyc;
                sdram_wb_stb <= wb_stb;
                sdram_wb_sel <= wb_sel when wb_we = '1' else "0000";
                wb_dat_i <= std_ulogic_vector(sdram_wb_rdata);			
			when X"0" | X"1" => 
				if (wb_addr(27 downto 10) = X"0000" & "00") then
					rom_stb <= wb_stb and wb_cyc;
					rom_addr <= std_logic_vector(wb_addr(31 downto 2));
					wb_dat_i <= std_ulogic_vector(rom_rdata);
				else
					ram_wr_en <= wb_we;
					wb_dat_i <= std_ulogic_vector(ram_rdata);
					ram_en <= wb_stb and wb_cyc;
				end if;
            when others => 
        end case;
    end process;
/*
    process(wb_addr, ram_rdata, rom_rdata, wb_addr, wb_stb, wb_cyc)
    begin
        case wb_addr(31 downto 28) is
            when X"8" => 
                rom_addr <= (others => '0');
                ram_wr_en <= wb_we;
                wb_dat_i <= std_ulogic_vector(ram_rdata);
                rom_stb <= '0';
				ram_en <= wb_stb and wb_cyc;
            when others => 
                rom_stb <= wb_stb;
                rom_addr <= std_logic_vector(wb_addr(31 downto 2));
                ram_wr_en <= '0';
                wb_dat_i <= std_ulogic_vector(rom_rdata);
				ram_en <= '0';
        end case;
    end process;*/


	led <= led_out(7 downto 0);

    wb_ack <= ram_ack or rom_ack or sdram_wb_ack;


end architecture;
