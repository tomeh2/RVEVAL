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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_test_setup_bootloader is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 100000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 8*1024     -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    SYSCLK_N : in std_logic;
    SYSCLK_P : in std_logic;
    
    GPIO_SW_C      : in  std_ulogic; -- global reset, low-active, async
    -- GPIO --
    GPIO_LED_0 : out std_logic;
    GPIO_LED_1 : out std_logic;
    GPIO_LED_2 : out std_logic;
    GPIO_LED_3 : out std_logic;
    
    --gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    USB_UART_TX : in std_ulogic; -- UART0 send data
    USB_UART_RX : out  std_ulogic;  -- UART0 receive data
    
    DDR3_D63 : inout std_logic;
    DDR3_D62 : inout std_logic;
    DDR3_D61 : inout std_logic;
    DDR3_D60 : inout std_logic;
    DDR3_D59 : inout std_logic;
    DDR3_D58 : inout std_logic;
    DDR3_D57 : inout std_logic;
    DDR3_D56 : inout std_logic;
    DDR3_D55 : inout std_logic;
    DDR3_D54 : inout std_logic;
    DDR3_D53 : inout std_logic;
    DDR3_D52 : inout std_logic;
    DDR3_D51 : inout std_logic;
    DDR3_D50 : inout std_logic;
    DDR3_D49 : inout std_logic;
    DDR3_D48 : inout std_logic;
    DDR3_D47 : inout std_logic;
    DDR3_D46 : inout std_logic;
    DDR3_D45 : inout std_logic;
    DDR3_D44 : inout std_logic;
    DDR3_D43 : inout std_logic;
    DDR3_D42 : inout std_logic;
    DDR3_D41 : inout std_logic;
    DDR3_D40 : inout std_logic;
    DDR3_D39 : inout std_logic;
    DDR3_D38 : inout std_logic;
    DDR3_D37 : inout std_logic;
    DDR3_D36 : inout std_logic;
    DDR3_D35 : inout std_logic;
    DDR3_D34 : inout std_logic;
    DDR3_D33 : inout std_logic;
    DDR3_D32 : inout std_logic;
    DDR3_D31 : inout std_logic;
    DDR3_D30 : inout std_logic;
    DDR3_D29 : inout std_logic;
    DDR3_D28 : inout std_logic;
    DDR3_D27 : inout std_logic;
    DDR3_D26 : inout std_logic;
    DDR3_D25 : inout std_logic;
    DDR3_D24 : inout std_logic;
    DDR3_D23 : inout std_logic;
    DDR3_D22 : inout std_logic;
    DDR3_D21 : inout std_logic;
    DDR3_D20 : inout std_logic;
    DDR3_D19 : inout std_logic;
    DDR3_D18 : inout std_logic;
    DDR3_D17 : inout std_logic;
    DDR3_D16 : inout std_logic;
    DDR3_D15 : inout std_logic;
    DDR3_D14 : inout std_logic;
    DDR3_D13 : inout std_logic;
    DDR3_D12 : inout std_logic;
    DDR3_D11 : inout std_logic;
    DDR3_D10 : inout std_logic;
    DDR3_D9 : inout std_logic;
    DDR3_D8 : inout std_logic;
    DDR3_D7 : inout std_logic;
    DDR3_D6 : inout std_logic;
    DDR3_D5 : inout std_logic;
    DDR3_D4 : inout std_logic;
    DDR3_D3 : inout std_logic;
    DDR3_D2 : inout std_logic;
    DDR3_D1 : inout std_logic;
    DDR3_D0 : inout std_logic;
    
    DDR3_DQS7_P : inout std_logic;
    DDR3_DQS6_P : inout std_logic;
    DDR3_DQS5_P : inout std_logic;
    DDR3_DQS4_P : inout std_logic;
    DDR3_DQS3_P : inout std_logic;
    DDR3_DQS2_P : inout std_logic;
    DDR3_DQS1_P : inout std_logic;
    DDR3_DQS0_P : inout std_logic;
    DDR3_DQS7_N : inout std_logic;
    DDR3_DQS6_N : inout std_logic;
    DDR3_DQS5_N : inout std_logic;
    DDR3_DQS4_N : inout std_logic;
    DDR3_DQS3_N : inout std_logic;
    DDR3_DQS2_N : inout std_logic;
    DDR3_DQS1_N : inout std_logic;
    DDR3_DQS0_N : inout std_logic;
    
    DDR3_DM7 : out std_logic;
    DDR3_DM6 : out std_logic;
    DDR3_DM5 : out std_logic;
    DDR3_DM4 : out std_logic;
    DDR3_DM3 : out std_logic;
    DDR3_DM2 : out std_logic;
    DDR3_DM1 : out std_logic;
    DDR3_DM0 : out std_logic;
    
    DDR3_A15 : out std_logic;
    DDR3_A14 : out std_logic;
    DDR3_A13 : out std_logic;
    DDR3_A12 : out std_logic;
    DDR3_A11 : out std_logic;
    DDR3_A10 : out std_logic;
    DDR3_A9 : out std_logic;
    DDR3_A8 : out std_logic;
    DDR3_A7 : out std_logic;
    DDR3_A6 : out std_logic;
    DDR3_A5 : out std_logic;
    DDR3_A4 : out std_logic;
    DDR3_A3 : out std_logic;
    DDR3_A2 : out std_logic;
    DDR3_A1 : out std_logic;
    DDR3_A0 : out std_logic;
    
    DDR3_BA2 : out std_logic;
    DDR3_BA1 : out std_logic;
    DDR3_BA0 : out std_logic;
    
    DDR3_CAS_B : out std_logic;
    DDR3_RAS_B : out std_logic;
    DDR3_WE_B : out std_logic;
    
    DDR3_CKE0 : out std_logic;
    DDR3_CKE1 : out std_logic;
    
    DDR3_CLK0_P : out std_logic;
    DDR3_CLK0_N : out std_logic;
    DDR3_CLK1_P : out std_logic;
    DDR3_CLK1_N : out std_logic;
    
    DDR3_ODT0 : out std_logic;
    DDR3_ODT1 : out std_logic
  );
end entity;

architecture neorv32_test_setup_bootloader_rtl of neorv32_test_setup_bootloader is

    signal con_gpio_o : std_ulogic_vector(63 downto 0);
    signal ddr3_d : std_logic_vector(63 downto 0);

    component drac_ddr3
    port
    (
        ckin : in std_logic;
        ckout : out std_logic;
        ckouthalf : out std_logic;
        reset : out std_logic;
        
        ddq : inout std_logic_vector(63 downto 0);
        dqsp : inout std_logic_vector(7 downto 0);
        dqsn : inout std_logic_vector(7 downto 0);
        ddm : out std_logic_vector(7 downto 0);
        da : out std_logic_vector(15 downto 0);
        dba : out std_logic_vector(2 downto 0);
        dcmd : out std_logic_vector(2 downto 0);
        dce : out std_logic_vector(1 downto 0);
        dcs : out std_logic_vector(1 downto 0);
        dckp : out std_logic_vector(1 downto 0);
        dckn : out std_logic_vector(1 downto 0);
        dodt : out std_logic_vector(1 downto 0);
        
        srd : in std_logic;
        swr : in std_logic;
        sa : in std_logic_vector(33 downto 5);
        swdat : in std_logic_vector(255 downto 0);
        smsk : in std_logic_vector(31 downto 0);
        srdat : out std_logic_vector(255 downto 0);
        srdy : out std_logic;
        
        dbg_in : out std_logic_vector(7 downto 0);
        dbg_out : in std_logic_vector(2 downto 0)
    );
    end component;

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic;
  
  locked : out std_logic
 );
end component;
    signal clk_i, clk_ddr_out, clk_ddr_half, clk_2, rstn_i, uart_rx, uart_tx, clk_locked : std_logic;
    signal srd, swd, srdy, stb : std_logic;
    signal sa : std_ulogic_vector(28 downto 0);
    signal swdat, srdat : std_ulogic_vector(31 downto 0);
    signal smsk : std_ulogic_vector(31 downto 0);
    
    signal sa_2 : std_logic_vector(28 downto 0);
    signal swdat_2, srdat_2 : std_logic_vector(255 downto 0);
    signal srdat_3 : std_logic_vector(31 downto 0);
    signal smsk_2 : std_logic_vector(31 downto 0);
begin
    your_instance_name : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_i,
   -- Clock in ports
   clk_in1_p => SYSCLK_P,
   clk_in1_n => SYSCLK_N,
   
   locked => clk_locked
 );
    rstn_i <= not GPIO_SW_C and clk_locked; 
  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- General --
    CLOCK_FREQUENCY              => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    INT_BOOTLOADER_EN            => true,              -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- RISC-V CPU Extensions --
    CPU_EXTENSION_RISCV_C        => true,              -- implement compressed extension?
    CPU_EXTENSION_RISCV_M        => true,              -- implement mul/div extension?
    CPU_EXTENSION_RISCV_Zicsr    => true,              -- implement CSR system?
    CPU_EXTENSION_RISCV_Zicntr   => true,              -- implement base counters?
    
    MEM_EXT_EN => true,
    MEM_EXT_TIMEOUT => 1023,
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN              => true,              -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN              => false,              -- implement processor-internal data memory
    --MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_EN                   => true,              -- implement general purpose input/output port unit (GPIO)?
    IO_MTIME_EN                  => true,              -- implement machine system timer (MTIME)?
    IO_UART0_EN                  => true               -- implement primary universal asynchronous receiver/transmitter (UART0)?
  )
  port map (
    -- Global control --
    clk_i       => clk_i,       -- global clock, rising edge
    rstn_i      => rstn_i,      -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o      => con_gpio_o,  -- parallel output
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => USB_UART_RX, -- UART0 send data
    uart0_rxd_i => USB_UART_TX,  -- UART0 receive data
    
        -- Wishbone bus interface (available if MEM_EXT_EN = true) --
    wb_tag_o    => open,                         -- request tag
    wb_adr_o(28 downto 0)    => sa,                         -- address
    wb_adr_o(31 downto 29) => open,
    wb_dat_i    => srdat,              -- read data
    wb_dat_o    => swdat,                         -- write data
    wb_we_o     => swd,                         -- read/write
    wb_sel_o    => smsk(3 downto 0),                         -- byte enable
    wb_stb_o    => stb,                         -- strobe
    wb_cyc_o    => open,                         -- valid cycle
    wb_ack_i    => srdy,                          -- transfer acknowledge
    wb_err_i    => '0'                          -- transfer error
  );
  srd <= not swd and stb;
  smsk(31 downto 4) <= (others => '0');
  
  sa_2 <= std_logic_vector(sa);
  srdat_3 <= srdat_2(31 downto 0);
  srdat <= std_ulogic_vector(srdat_3);
  swdat_2(31 downto 0) <= std_logic_vector(swdat);
  swdat_2(255 downto 32) <= (others => '0');
  smsk_2 <= std_logic_vector(smsk);
  smsk_2(31 downto 4) <= (others => '0'); 
  
  drac_ddr3_instr : drac_ddr3
  port map(ckin => clk_i,
           ckout => clk_ddr_out,
           ckouthalf => clk_ddr_half,
           
           ddq(63) => DDR3_D63,
           ddq(62) => DDR3_D62,
           ddq(61) => DDR3_D61,
           ddq(60) => DDR3_D60,
           ddq(59) => DDR3_D59,
           ddq(58) => DDR3_D58,
           ddq(57) => DDR3_D57,
           ddq(56) => DDR3_D56,
           ddq(55) => DDR3_D55,
           ddq(54) => DDR3_D54,
           ddq(53) => DDR3_D53,
           ddq(52) => DDR3_D52,
           ddq(51) => DDR3_D51,
           ddq(50) => DDR3_D50,
           ddq(49) => DDR3_D49,
           ddq(48) => DDR3_D48,
           ddq(47) => DDR3_D47,
           ddq(46) => DDR3_D46,
           ddq(45) => DDR3_D45,
           ddq(44) => DDR3_D44,
           ddq(43) => DDR3_D43,
           ddq(42) => DDR3_D42,
           ddq(41) => DDR3_D41,
           ddq(40) => DDR3_D40,
           ddq(39) => DDR3_D39,
           ddq(38) => DDR3_D38,
           ddq(37) => DDR3_D37,
           ddq(36) => DDR3_D36,
           ddq(35) => DDR3_D35,
           ddq(34) => DDR3_D34,
           ddq(33) => DDR3_D33,
           ddq(32) => DDR3_D32,
           ddq(31) => DDR3_D31,
           ddq(30) => DDR3_D30,
           ddq(29) => DDR3_D29,
           ddq(28) => DDR3_D28,
           ddq(27) => DDR3_D27,
           ddq(26) => DDR3_D26,
           ddq(25) => DDR3_D25,
           ddq(24) => DDR3_D24,
           ddq(23) => DDR3_D23,
           ddq(22) => DDR3_D22,
           ddq(21) => DDR3_D21,
           ddq(20) => DDR3_D20,
           ddq(19) => DDR3_D19,
           ddq(18) => DDR3_D18,
           ddq(17) => DDR3_D17,
           ddq(16) => DDR3_D16,
           ddq(15) => DDR3_D15,
           ddq(14) => DDR3_D14,
           ddq(13) => DDR3_D13,
           ddq(12) => DDR3_D12,
           ddq(11) => DDR3_D11,
           ddq(10) => DDR3_D10,
           ddq(9) => DDR3_D9,
           ddq(8) => DDR3_D8,
           ddq(7) => DDR3_D7,
           ddq(6) => DDR3_D6,
           ddq(5) => DDR3_D5,
           ddq(4) => DDR3_D4,
           ddq(3) => DDR3_D3,
           ddq(2) => DDR3_D2,
           ddq(1) => DDR3_D1,
           ddq(0) => DDR3_D0,
           
           dqsp(7) => DDR3_DQS7_P,
           dqsp(6) => DDR3_DQS6_P,
           dqsp(5) => DDR3_DQS5_P,
           dqsp(4) => DDR3_DQS4_P,
           dqsp(3) => DDR3_DQS3_P,
           dqsp(2) => DDR3_DQS2_P,
           dqsp(1) => DDR3_DQS1_P,
           dqsp(0) => DDR3_DQS0_P,
           dqsn(7) => DDR3_DQS7_N,
           dqsn(6) => DDR3_DQS6_N,
           dqsn(5) => DDR3_DQS5_N,
           dqsn(4) => DDR3_DQS4_N,
           dqsn(3) => DDR3_DQS3_N,
           dqsn(2) => DDR3_DQS2_N,
           dqsn(1) => DDR3_DQS1_N,
           dqsn(0) => DDR3_DQS0_N,
           
           ddm(7) => DDR3_DM7,
           ddm(6) => DDR3_DM6,
           ddm(5) => DDR3_DM5,
           ddm(4) => DDR3_DM4,
           ddm(3) => DDR3_DM3,
           ddm(2) => DDR3_DM2,
           ddm(1) => DDR3_DM1,
           ddm(0) => DDR3_DM0,
           
           da(15) => DDR3_A15, 
           da(14) => DDR3_A14, 
           da(13) => DDR3_A13, 
           da(12) => DDR3_A12, 
           da(11) => DDR3_A11, 
           da(10) => DDR3_A10, 
           da(9) => DDR3_A9, 
           da(8) => DDR3_A8, 
           da(7) => DDR3_A7, 
           da(6) => DDR3_A6, 
           da(5) => DDR3_A5, 
           da(4) => DDR3_A4, 
           da(3) => DDR3_A3, 
           da(2) => DDR3_A2, 
           da(1) => DDR3_A1, 
           da(0) => DDR3_A0, 
           
           dba(2) => DDR3_BA2,
           dba(1) => DDR3_BA1,
           dba(0) => DDR3_BA0,
           
           dcmd(2) => DDR3_RAS_B,
           dcmd(1) => DDR3_CAS_B,
           dcmd(0) => DDR3_WE_B,
           
           dce(1) => DDR3_CKE1,
           dce(0) => DDR3_CKE0,
           
           dckp(1) => DDR3_CLK1_P,
           dckp(0) => DDR3_CLK0_P,
           dckn(1) => DDR3_CLK1_N,
           dckn(0) => DDR3_CLK0_N,
           
           dodt(1) => DDR3_ODT1,
           dodt(0) => DDR3_ODT0,
           
           srd => srd,
           swr => swd,
           sa => sa_2,
           swdat => swdat_2,
           smsk => smsk_2,
           srdat => srdat_2,
           srdy => srdy,
           
           dbg_out => "000"
           ); 


  -- GPIO output --
  --gpio_o <= con_gpio_o(7 downto 0);
  GPIO_LED_0 <= con_gpio_o(0);
  GPIO_LED_1 <= con_gpio_o(1);
  GPIO_LED_2 <= con_gpio_o(2);
  GPIO_LED_3 <= con_gpio_o(3);
  
  
  

end architecture;
