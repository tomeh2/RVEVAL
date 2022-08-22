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

use work.f32c_pack.all;

entity neorv32_test_setup_bootloader is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 100000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 8*1024     -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    CLK100MHZ : in std_logic;
    
    CPU_RESETN      : in  std_ulogic; -- global reset, low-active, async
    -- GPIO --
    LED : out std_ulogic_vector(15 downto 0);
    
    --gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    UART_RXD_OUT : out std_ulogic; -- UART0 send data
    UART_TXD_IN : in  std_ulogic  -- UART0 receive data
  );
end entity;

architecture neorv32_test_setup_bootloader_rtl of neorv32_test_setup_bootloader is

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
  
  signal rom_addr : std_logic_vector(29 downto 0);
  signal rom_data_o : std_logic_vector(31 downto 0);
begin
    process
    begin
        clk_i <= '0';
        wait for 10ns;
        clk_i <= '1';
        wait for 10ns;
    end process;
    
    rstn_i <= '0', '1' after 30ns;

  --clk_i <= CLK100MHZ;
  --rstn_i <= CPU_RESETN; 
  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
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
    --MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_EN                   => false,              -- implement general purpose input/output port unit (GPIO)?
    IO_MTIME_EN                  => false,              -- implement machine system timer (MTIME)?
    IO_UART0_EN                  => false,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    
    MEM_EXT_EN                   => true
  )
  port map (
    -- Global control --
    clk_i       => clk_i,       -- global clock, rising edge
    rstn_i      => rstn_i,      -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o      => con_gpio_o,  -- parallel output
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => UART_RXD_OUT, -- UART0 send data
    uart0_rxd_i => UART_TXD_IN,  -- UART0 receive data
    
    wb_tag_o => wb_tag, -- request tag
    wb_adr_o => wb_addr,  -- address
    wb_dat_i => wb_dat_i, -- read data
    wb_dat_o => wb_dat_o,  -- write data
    wb_we_o => wb_we,   -- read/write
    wb_sel_o => wb_sel,  -- byte enable
    wb_stb_o => wb_stb, -- strobe
    wb_cyc_o => wb_cyc,  -- valid cycle
    wb_ack_i => wb_ack,  -- transfer acknowledge
    wb_err_i => wb_err  -- transfer error
  );
  
    rom : entity work.rom
          generic map(C_arch => ARCH_RV32,
                      C_big_endian => false,
	                  C_boot_spi => false)
          port map(clk => clk_i,
                   strobe => wb_stb,
                   addr => rom_addr,
                   data_ready => wb_ack,
                   data_out => rom_data_o);

    rom_addr <= std_logic_vector(wb_addr(31 downto 2));
    wb_dat_i <= std_ulogic_vector(rom_data_o);

  -- GPIO output --
  --gpio_o <= con_gpio_o(7 downto 0);
    LED <= con_gpio_o(15 downto 0);

end architecture;
