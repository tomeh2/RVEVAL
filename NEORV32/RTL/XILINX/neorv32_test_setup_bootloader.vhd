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
    CLOCK_FREQUENCY   : natural := 115000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 128*1024     -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    SYSCLK_P : in std_logic;
    SYSCLK_N : in std_logic;
    
    CPU_RESET      : in  std_ulogic; -- global reset, low-active, async
    -- GPIO --
    GPIO_LED_0 : out std_logic;
    GPIO_LED_1 : out std_logic;
    GPIO_LED_2 : out std_logic;
    GPIO_LED_3 : out std_logic;
    
    --gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    USB_UART_RX : out std_ulogic; -- UART0 send data
    USB_UART_TX : in  std_ulogic  -- UART0 receive data
  );
end entity;

architecture neorv32_test_setup_bootloader_rtl of neorv32_test_setup_bootloader is

    component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  locked            : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;

COMPONENT ila_0

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
	probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

  signal con_gpio_o : std_ulogic_vector(63 downto 0);

  signal clk_i, rstn_i : std_logic;
  
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
  
  signal led : std_logic_vector(15 downto 0);
  signal rom_addr : std_logic_vector(29 downto 0);
  signal rom_rdata : std_logic_vector(31 downto 0);
  signal rom_ack : std_logic;
  signal rom_stb : std_logic;
  
  signal ram_wr_en : std_logic;
  signal ram_rdata : std_logic_vector(31 downto 0);
  signal ram_ack : std_logic;
  signal ram_stb : std_logic;
  signal ram_en : std_logic;
begin
--    process
--    begin
--        clk_i <= '0';
--        wait for 10ns;
--        clk_i <= '1';
--        wait for 10ns;
--    end process;
    
--    rstn_i <= '0', '1' after 30ns;

    rstn_i <= not CPU_RESET;

   your_instance_name : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_i,
  -- Status and control signals                
   locked => open,
   -- Clock in ports
   clk_in1_p => SYSCLK_P,
   clk_in1_n => SYSCLK_N
 );
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
    
    led_out => led,
    rxd => USB_UART_TX,
    txd => USB_UART_RX
  );
    --GPIO_LED_0 <= led(0);
    --GPIO_LED_1 <= led(1);
    --GPIO_LED_2 <= led(5);
    --GPIO_LED_3 <= led(6);
  
    GPIO_LED_0 <= led(0);
    GPIO_LED_1 <= led(1);
    GPIO_LED_2 <= led(2);
    GPIO_LED_3 <= led(3);
  
    rom : entity work.rom
          generic map(C_arch => ARCH_RV32,
                      C_big_endian => false,
	                  C_boot_spi => false)
          port map(clk => clk_i,
                   strobe => rom_stb,
                   addr => rom_addr,
                   data_ready => rom_ack,
                   data_out => rom_rdata);

   
   
    ram_memory : entity neorv32.ram_memory_no_delay
                 generic map(SIZE_BYTES => 512 * 1024)
                 port map(bus_addr => std_logic_vector(wb_addr(18 downto 0)),
                          bus_wdata => std_logic_vector(wb_dat_o),
                          bus_rdata => ram_rdata,
                          bus_wstrb => std_logic_vector(wb_sel),
                          bus_ready => ram_ack,
                          
                          wr_en => ram_wr_en,
                          stb => ram_en,
                          clk => clk_i,
                          resetn => rstn_i);
--/
--    ila : ila_0
--PORT MAP (
--	clk => clk_i,



--	probe0 => std_logic_vector(wb_addr), 
--	probe1 => std_logic_vector(wb_dat_i), 
--	probe2 => std_logic_vector(wb_dat_o), 
--	probe3(0) => std_logic(wb_we), 
--	probe4 => std_logic_vector(wb_sel), 
--	probe5(0) => std_logic(wb_stb), 
--	probe6(0) => std_logic(wb_cyc),
--	probe7(0) => std_logic(wb_ack)
--);


    ram_en <= '1' when wb_addr(31 downto 28) = X"8" and wb_stb = '1' else '0'; 

    process(wb_addr, ram_rdata, rom_rdata, wb_addr, wb_stb)
    begin
        case wb_addr(31 downto 28) is
            when X"8" => 
                rom_addr <= (others => '0');
                ram_wr_en <= wb_we;
                wb_dat_i <= std_ulogic_vector(ram_rdata);
                rom_stb <= '0';
            when others => 
                rom_stb <= wb_stb;
                rom_addr <= std_logic_vector(wb_addr(31 downto 2));
                ram_wr_en <= '0';
                wb_dat_i <= std_ulogic_vector(rom_rdata);
        end case;
    end process;

    wb_ack <= ram_ack or rom_ack;

  -- GPIO output --
  --LED(15 downto 0) <= std_logic_vector(con_gpio_o(15 downto 0));

end architecture;
