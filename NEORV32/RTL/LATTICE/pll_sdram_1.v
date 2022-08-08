/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.0.396.4 */
/* Module Version: 5.7 */
/* C:\diamond\diamond\3.11_x64\ispfpga\bin\nt64\scuba.exe -w -n pll_sdram_1 -lang verilog -synth synplify -bus_exp 7 -bb -arch sa5p00 -type pll -fin 25 -fclkop 50 -fclkop_tol 0.0 -fclkos 50 -fclkos_tol 0.0 -phases 90 -phase_cntl STATIC -fb_mode 1 -fdc C:/Users/koncarevac/Desktop/Repo/RVEVAL/NEORV32/RTL/LATTICE/pll_sdram/pll_sdram_1/pll_sdram_1.fdc  */
/* Mon Aug 08 09:32:19 2022 */


`timescale 1 ns / 1 ps
module pll_sdram_1 (CLKI, CLKOP, CLKOS)/* synthesis NGD_DRC_MASK=1 */;
    input wire CLKI;
    output wire CLKOP;
    output wire CLKOS;

    wire REFCLK;
    wire LOCK;
    wire CLKOS_t;
    wire CLKOP_t;
    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam PLLInst_0.PLLRST_ENA = "DISABLED" ;
    defparam PLLInst_0.INTFB_WAKE = "DISABLED" ;
    defparam PLLInst_0.STDBY_ENABLE = "DISABLED" ;
    defparam PLLInst_0.DPHASE_SOURCE = "DISABLED" ;
    defparam PLLInst_0.CLKOS3_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS3_CPHASE = 0 ;
    defparam PLLInst_0.CLKOS2_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS2_CPHASE = 0 ;
    defparam PLLInst_0.CLKOS_FPHASE = 2 ;
    defparam PLLInst_0.CLKOS_CPHASE = 15 ;
    defparam PLLInst_0.CLKOP_FPHASE = 0 ;
    defparam PLLInst_0.CLKOP_CPHASE = 12 ;
    defparam PLLInst_0.PLL_LOCK_MODE = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_POL = "FALLING" ;
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOP_TRIM_POL = "FALLING" ;
    defparam PLLInst_0.OUTDIVIDER_MUXD = "DIVD" ;
    defparam PLLInst_0.CLKOS3_ENABLE = "DISABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXC = "DIVC" ;
    defparam PLLInst_0.CLKOS2_ENABLE = "DISABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXB = "DIVB" ;
    defparam PLLInst_0.CLKOS_ENABLE = "ENABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXA = "DIVA" ;
    defparam PLLInst_0.CLKOP_ENABLE = "ENABLED" ;
    defparam PLLInst_0.CLKOS3_DIV = 1 ;
    defparam PLLInst_0.CLKOS2_DIV = 1 ;
    defparam PLLInst_0.CLKOS_DIV = 13 ;
    defparam PLLInst_0.CLKOP_DIV = 13 ;
    defparam PLLInst_0.CLKFB_DIV = 2 ;
    defparam PLLInst_0.CLKI_DIV = 1 ;
    defparam PLLInst_0.FEEDBK_PATH = "CLKOP" ;
    EHXPLLL PLLInst_0 (.CLKI(CLKI), .CLKFB(CLKOP_t), .PHASESEL1(scuba_vlo), 
        .PHASESEL0(scuba_vlo), .PHASEDIR(scuba_vlo), .PHASESTEP(scuba_vlo), 
        .PHASELOADREG(scuba_vlo), .STDBY(scuba_vlo), .PLLWAKESYNC(scuba_vlo), 
        .RST(scuba_vlo), .ENCLKOP(scuba_vlo), .ENCLKOS(scuba_vlo), .ENCLKOS2(scuba_vlo), 
        .ENCLKOS3(scuba_vlo), .CLKOP(CLKOP_t), .CLKOS(CLKOS_t), .CLKOS2(), 
        .CLKOS3(), .LOCK(LOCK), .INTLOCK(), .REFCLK(REFCLK), .CLKINTFB())
             /* synthesis FREQUENCY_PIN_CLKOS="50.000000" */
             /* synthesis FREQUENCY_PIN_CLKOP="50.000000" */
             /* synthesis FREQUENCY_PIN_CLKI="25.000000" */
             /* synthesis ICP_CURRENT="6" */
             /* synthesis LPF_RESISTOR="16" */;

    assign CLKOS = CLKOS_t;
    assign CLKOP = CLKOP_t;


    // exemplar begin
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOS 50.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOP 50.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKI 25.000000
    // exemplar attribute PLLInst_0 ICP_CURRENT 6
    // exemplar attribute PLLInst_0 LPF_RESISTOR 16
    // exemplar end

endmodule
