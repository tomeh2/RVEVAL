library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.f32c_pack.all;


entity top_synth is
    port(
	clk_25mhz: in std_logic;

	btn: in std_logic_vector(6 downto 0);
	sw: in std_logic_vector(3 downto 0);
	led: out std_logic_vector(7 downto 0);
		
	sdram_clk: out std_logic;
	sdram_a: out unsigned(12 downto 0);
	sdram_ba: out unsigned(1 downto 0);
	sdram_d: inout std_logic_vector(15 downto 0);
	sdram_cke: out std_logic;
	sdram_csn: out std_logic;
	sdram_rasn: out std_logic;
	sdram_casn: out std_logic;
	sdram_wen: out std_logic;
	sdram_dqm: out std_logic_vector(1 downto 0);

	ftdi_rxd: out std_logic;
	ftdi_txd: in std_logic
    );
end top_synth;

architecture structural of top_synth is
    component pll_sdram_1
    port (
	CLKI: in std_logic;
	CLKOP: out std_logic;
	CLKOS: out std_logic
    );
    end component;

    component picorv32
    /* generic (
	STACKADDR: std_logic_vector(31 downto 0) := (others => '0');
	PROGADDR_RESET: std_logic_vector(31 downto 0) := (others => '0');
	ENABLE_COUNTERS: boolean := false;
	ENABLE_COUNTERS64: std_logic := '0';
	ENABLE_REGS_16_31: std_logic := '1';
	ENABLE_REGS_DUALPORT: std_logic := '1';
	LATCHED_MEM_RDATA: std_logic := '0';
	TWO_STAGE_SHIFT: std_logic := '0';
	BARREL_SHIFTER: std_logic := '0';
	TWO_CYCLE_COMPARE: std_logic := '0';
	TWO_CYCLE_ALU: std_logic := '0';
	COMPRESSED_ISA: std_logic := '0';
	CATCH_ILLINSN: std_logic := '1';
	ENABLE_PCPI: std_logic := '0';
	ENABLE_MUL: std_logic := '0';
	ENABLE_FAST_MUL: std_logic := '0';
	ENABLE_IRQ: std_logic := '0';
	ENABLE_IRQ_QREGS: std_logic := '0';
	ENABLE_IRQ_TIMER: std_logic := '0';
	ENABLE_TRACE: std_logic := '0';
	REGS_INIT_ZERO: std_logic := '0';
	MASKED_IRQ: std_logic_vector(31 downto 0) := (others => '0');
	LATCHED_IRQ: std_logic_vector(31 downto 0) := (others => '0');
	PROGADDR_IRQ: std_logic_vector(31 downto 0) := (others => '0')
    ); */
    port (
	mem_valid: out std_logic;
	mem_instr: out std_logic;
	mem_ready: in std_logic;
	mem_addr: out std_logic_vector(31 downto 0);
	mem_wdata: out std_logic_vector(31 downto 0);
	mem_wstrb: out std_logic_vector(3 downto 0);
	mem_rdata: in std_logic_vector(31 downto 0);

	pcpi_wr: in std_logic;
	pcpi_rd: in std_logic_vector(31 downto 0);
	pcpi_ready: in std_logic;
	pcpi_wait: in std_logic;

	mem_la_read: out std_logic;
	mem_la_write: out std_logic;
	mem_la_addr: out std_logic_vector(31 downto 0);
	mem_la_wdata: out std_logic_vector(31 downto 0);
	mem_la_wstrb: out std_logic_vector(3 downto 0);

	pcpi_valid: out std_logic;
	pcpi_insn: out std_logic_vector(31 downto 0);
	pcpi_rs1: out std_logic_vector(31 downto 0);
	pcpi_rs2: out std_logic_vector(31 downto 0);

	irq: in std_logic_vector(31 downto 0);
	eoi: out std_logic_vector(31 downto 0);

	trace_valid: out std_logic;
	trace_data: out std_logic_vector(35 downto 0);
			
	trap: out std_logic;
	clk: in std_logic;
	resetn: in std_logic
    );
    end component;
	
    -- Top 4 bits of the address that are used in address decoding.
    constant BRAM_ADDR_TOP: std_logic_vector := x"0";
    constant SDRAM_ADDR_TOP: std_logic_vector := x"8";
    constant MMIO_ADDR_TOP: std_logic_vector := x"F";

    signal bus_valid, bus_instr, bus_write, bus_ready: std_logic;
    signal bus_addr, bus_wdata, bus_rdata: std_logic_vector(31 downto 0);
    signal bus_wstrb: std_logic_vector(3 downto 0);
    
    signal irq: std_logic_vector(31 downto 0) := (others => '0');
    
    signal clk, clk_sdram, resetn, reset: std_logic;
    
    signal rom_bus_rdata: std_logic_vector(31 downto 0);
    signal rom_bus_ready, rom_cs: std_logic;
	
    signal ram_bus_rdata: std_logic_vector(31 downto 0);
    signal ram_bus_ready, ram_cs: std_logic;
	
    signal sdram_bus_rdata: std_logic_vector(31 downto 0);
    signal sdram_bus_ready, sdram_valid, sdram_cs, sdram_ack: std_logic;
    signal sdram_cs_read: std_logic;
    signal sdram_bus_access_state: std_logic_vector(1 downto 0);

    signal sio_cs, sio_break: std_logic;
    signal sio_bus_rdata: std_logic_vector(31 downto 0);
    signal sio_byte_sel: std_logic_vector(3 downto 0);

    signal simple_out_cs: std_logic;
    signal R_simple_in, R_simple_out: std_logic_vector(31 downto 0);

    signal mmio_bus_ready: std_logic;
    signal unmapped_bus_ready: std_logic;

begin
    resetn <= btn(0) and not sio_break;
    reset <= not resetn;

    picorv32_inst: picorv32
    port map (
	clk => clk,
	resetn => resetn,
	mem_valid => bus_valid,
	mem_instr => bus_instr,
	mem_ready => bus_ready,
	mem_addr => bus_addr,
	mem_wdata => bus_wdata,
	mem_wstrb => bus_wstrb,
	mem_rdata => bus_rdata,

	irq => irq,

	pcpi_wr => '0',
	pcpi_rd => X"0000_0000",
	pcpi_ready => '0',
	pcpi_wait => '0'
    );
    bus_write <= bus_valid when bus_wstrb /= "0000" else '0';

    rom: entity work.rom
    generic map (
	C_arch => ARCH_RV32,
	C_big_endian => false,
	C_boot_spi => false
    )
    port map (
	clk => clk,
	strobe => rom_cs,
	addr => bus_addr(31 downto 2),
	data_out => rom_bus_rdata,
	data_ready => rom_bus_ready
    );
					
    ram: entity work.ram_memory(rtl)
    generic map (
	SIZE_BYTES => 32768
    )
    port map(
	bus_addr => bus_addr(14 downto 0),
	bus_wdata => bus_wdata,
	bus_rdata => ram_bus_rdata,
	bus_wstrb => bus_wstrb,
	bus_ready => ram_bus_ready,
	en => ram_cs,
	clk => clk,
	resetn => resetn
    );
				   
    sdram_controller: entity work.sdram(arch)
    generic map (
	CLK_FREQ => 50.0
    )
    port map(
	reset => reset,
	clk => clk,
	addr => unsigned(bus_addr(22 downto 0)),
	data => bus_wdata,
	we => bus_write,
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
	sdram_dqmh => sdram_dqm(1)
    );

    -- SDRAM clock is also 50 MHz but phase shifted by 90 degrees
    clkgen_inst: pll_sdram_1
    port map (
	CLKI => clk_25mhz,
	CLKOP => clk_sdram,
	CLKOS => clk
    );
    sdram_clk <= clk_sdram;

    -- ADDRESS DECODING
    process(bus_valid, bus_addr, bus_wstrb, sdram_bus_rdata, rom_bus_rdata,
      ram_bus_rdata, sio_bus_rdata, R_simple_in, R_simple_out)
    begin
	bus_rdata <= (others => '0');
	rom_cs <= '0';
	ram_cs <= '0';
	sio_cs <= '0';
	simple_out_cs <= '0';
	mmio_bus_ready <= '0';
	unmapped_bus_ready <= '0';

	if bus_valid = '1' then
	    case bus_addr(31 downto 28) is
	    when BRAM_ADDR_TOP =>
		-- 0x0 to 0x3ff maps to f32c ROM bootloader (1 K)
		if bus_addr(27 downto 10) = x"0000" & "00" then
		    bus_rdata <= rom_bus_rdata;
		    rom_cs <= '1';
		else
		    bus_rdata <= ram_bus_rdata;
		    ram_cs <= '1';
		end if;
	    when SDRAM_ADDR_TOP =>
		bus_rdata <= sdram_bus_rdata;
	    when MMIO_ADDR_TOP =>
		-- IO devices map to 0xfffff000 to 0xffffffff
		mmio_bus_ready <= '1';
		case bus_addr(11 downto 4) is
		when x"B0" =>
		    bus_rdata <= sio_bus_rdata;
		    sio_cs <= '1';
		when x"F0" =>
		    bus_rdata <= R_simple_in;
		when x"F1" =>
		    bus_rdata <= R_simple_out;
		    simple_out_cs <= '1';
		when others =>
		end case;
	    when others =>
		-- do not block on unmapped bus cycles
		unmapped_bus_ready <= '1';
	    end case;
	end if;
    end process;

    bus_ready <= rom_bus_ready or sdram_bus_ready or ram_bus_ready
      or mmio_bus_ready or unmapped_bus_ready;
	
    sdram_cs_proc: process(clk)
    begin
	if rising_edge(clk) then
	    if reset = '1' then
		sdram_bus_access_state <= "00";
	    else
		if sdram_bus_access_state = "00" then
		    if bus_addr(31 downto 28) = SDRAM_ADDR_TOP
		      and bus_valid = '1' then
			sdram_bus_access_state <= "01";
		    else
			sdram_bus_access_state <= "00";
		    end if;
		elsif sdram_bus_access_state = "01" then
		    if sdram_ack = '1' and bus_wstrb = "0000" then
			sdram_bus_access_state <= "10";
		    elsif sdram_ack = '1' and bus_wstrb /= "0000" then
			sdram_bus_access_state <= "00";
		    else
			sdram_bus_access_state <= "01";
		    end if;
		else
		    if sdram_valid = '1' then
			sdram_bus_access_state <= "00";
		    else
			sdram_bus_access_state <= "10";
		    end if;
		end if;
	    end if;
	end if;
    end process;
    
    sdram_cs_proc_2: process(sdram_bus_access_state)
    begin
	if sdram_bus_access_state = "00" then
	    sdram_cs_read <= '0';
	elsif sdram_bus_access_state = "01" then
	    sdram_cs_read <= '1';
	else
	    sdram_cs_read <= '0';
	end if;
    end process;
    
    sdram_cs_proc_3: process(sdram_bus_access_state, bus_wstrb, sdram_cs_read)
    begin
	if sdram_bus_access_state /= "00" then
	    if bus_wstrb = "0000" then
		sdram_cs <= sdram_cs_read;
	    else 
		sdram_cs <= '1';
	    end if;
	else
	    sdram_cs <= '0';
	end if;
    end process;

    sdram_bus_ready <= sdram_ack when bus_write = '1' else sdram_valid;

    -- f32c SIO
    sio_instance: entity work.sio
    generic map (
	C_clk_freq => 50,
	C_break_detect => true
    )
    port map (
	clk => clk,
	ce => sio_cs,
	txd => ftdi_rxd,
	rxd => ftdi_txd,
	bus_write => bus_write,
	byte_sel => sio_byte_sel,
	bus_in => bus_wdata,
	bus_out => sio_bus_rdata,
	break => sio_break
    );
    sio_byte_sel <= bus_wstrb when bus_wstrb /= x"0" else x"f";

    -- simple in & out (LEDs, buttons, switches...)
    R_simple_in <= x"000" & sw & x"00" & '0' & not btn(0) & btn(2) & btn(1)
      & btn(3) & btn(5) & btn(4) & btn(6) when rising_edge(clk);
    R_simple_out <= bus_wdata when rising_edge(clk) and bus_write = '1' and
      simple_out_cs = '1';
    led <= R_simple_out(7 downto 0);

end structural;
