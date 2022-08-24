library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.boot_block_pack.all;

package boot_sio_rv32el is

constant boot_sio_rv32el : boot_block_type := (
	x"13", x"01", x"01", x"fe", x"23", x"2e", x"11", x"00", 
	x"23", x"2c", x"81", x"00", x"23", x"2a", x"91", x"00", 
	x"23", x"28", x"21", x"01", x"23", x"26", x"31", x"01", 
	x"23", x"24", x"41", x"01", x"13", x"00", x"00", x"00", 
	x"13", x"08", x"00", x"00", x"93", x"05", x"00", x"00", 
	x"93", x"07", x"00", x"00", x"b7", x"0f", x"00", x"08", 
	x"93", x"08", x"30", x"00", x"93", x"02", x"00", x"06", 
	x"93", x"03", x"10", x"00", x"93", x"00", x"50", x"00", 
	x"37", x"17", x"72", x"76", x"13", x"06", x"00", x"00", 
	x"13", x"07", x"d7", x"a0", x"37", x"35", x"3e", x"20", 
	x"83", x"06", x"10", x"b0", x"93", x"f6", x"46", x"00", 
	x"e3", x"9c", x"06", x"fe", x"23", x"00", x"e0", x"b0", 
	x"13", x"57", x"87", x"40", x"e3", x"16", x"07", x"fe", 
	x"63", x"00", x"06", x"08", x"93", x"0e", x"20", x"00", 
	x"13", x"04", x"30", x"05", x"93", x"04", x"f0", x"ff", 
	x"13", x"09", x"d0", x"00", x"93", x"09", x"f0", x"01", 
	x"13", x"06", x"f0", x"0f", x"93", x"06", x"f0", x"ff", 
	x"13", x"05", x"20", x"00", x"13", x"0f", x"00", x"04", 
	x"13", x"da", x"85", x"40", x"63", x"da", x"06", x"06", 
	x"f3", x"27", x"10", x"c0", x"33", x"f7", x"f7", x"01", 
	x"63", x"04", x"07", x"00", x"13", x"07", x"f0", x"0f", 
	x"13", x"d3", x"37", x"41", x"13", x"fe", x"f7", x"0f", 
	x"13", x"73", x"f3", x"0f", x"63", x"56", x"c3", x"05", 
	x"13", x"47", x"f7", x"00", x"23", x"08", x"e0", x"f0", 
	x"03", x"07", x"10", x"b0", x"13", x"77", x"17", x"00", 
	x"e3", x"06", x"07", x"fc", x"03", x"07", x"00", x"b0", 
	x"63", x"d0", x"06", x"06", x"63", x"00", x"87", x"02", 
	x"63", x"1c", x"97", x"02", x"6f", x"00", x"00", x"11", 
	x"93", x"07", x"00", x"00", x"6f", x"f0", x"df", x"fa", 
	x"13", x"06", x"f0", x"ff", x"13", x"07", x"35", x"23", 
	x"6f", x"f0", x"1f", x"f6", x"93", x"07", x"00", x"00", 
	x"93", x"06", x"00", x"00", x"6f", x"f0", x"5f", x"f9", 
	x"13", x"47", x"07", x"0f", x"6f", x"f0", x"9f", x"fb", 
	x"23", x"08", x"40", x"f1", x"6f", x"f0", x"5f", x"fb", 
	x"e3", x"08", x"27", x"f3", x"93", x"07", x"00", x"00", 
	x"e3", x"dc", x"e9", x"f6", x"83", x"07", x"10", x"b0", 
	x"93", x"f7", x"47", x"00", x"e3", x"9c", x"07", x"fe", 
	x"23", x"00", x"e0", x"b0", x"6f", x"f0", x"5f", x"f6", 
	x"13", x"03", x"67", x"ff", x"e3", x"f6", x"68", x"f4", 
	x"13", x"93", x"47", x"00", x"63", x"da", x"e2", x"00", 
	x"13", x"07", x"07", x"fe", x"13", x"07", x"97", x"fc", 
	x"b3", x"67", x"67", x"00", x"6f", x"00", x"00", x"01", 
	x"93", x"07", x"07", x"fd", x"b3", x"e7", x"67", x"00", 
	x"e3", x"46", x"ef", x"fe", x"93", x"86", x"16", x"00", 
	x"63", x"94", x"76", x"04", x"13", x"87", x"97", x"ff", 
	x"63", x"e8", x"ee", x"02", x"23", x"20", x"01", x"00", 
	x"23", x"20", x"21", x"00", x"37", x"04", x"00", x"80", 
	x"b7", x"04", x"00", x"10", x"33", x"71", x"88", x"00", 
	x"33", x"61", x"91", x"00", x"93", x"00", x"00", x"00", 
	x"23", x"20", x"01", x"00", x"23", x"20", x"21", x"00", 
	x"67", x"00", x"08", x"00", x"6f", x"f0", x"df", x"f4", 
	x"e3", x"c4", x"f8", x"f4", x"13", x"96", x"17", x"00", 
	x"13", x"06", x"56", x"00", x"6f", x"f0", x"df", x"f3", 
	x"63", x"98", x"16", x"01", x"93", x"97", x"17", x"00", 
	x"33", x"05", x"f5", x"00", x"6f", x"f0", x"df", x"f2", 
	x"e3", x"dc", x"c0", x"ec", x"63", x"1a", x"d6", x"00", 
	x"93", x"85", x"07", x"00", x"e3", x"16", x"08", x"ec", 
	x"13", x"88", x"07", x"00", x"6f", x"f0", x"5f", x"ec", 
	x"e3", x"50", x"d6", x"ec", x"13", x"f7", x"16", x"00", 
	x"e3", x"0c", x"07", x"ea", x"e3", x"da", x"a6", x"ea", 
	x"23", x"80", x"f5", x"00", x"93", x"85", x"15", x"00", 
	x"6f", x"f0", x"9f", x"ea", x"13", x"05", x"00", x"00", 
	x"93", x"06", x"00", x"00", x"93", x"07", x"00", x"00", 
	x"13", x"08", x"10", x"09", x"93", x"08", x"10", x"08", 
	x"13", x"03", x"00", x"09", x"13", x"0e", x"00", x"0a", 
	x"93", x"0e", x"10", x"0b", x"13", x"0f", x"00", x"08", 
	x"73", x"27", x"10", x"c0", x"13", x"57", x"87", x"01", 
	x"23", x"08", x"e0", x"f0", x"03", x"07", x"10", x"b0", 
	x"13", x"77", x"17", x"00", x"e3", x"06", x"07", x"fe", 
	x"03", x"07", x"00", x"b0", x"13", x"77", x"f7", x"0f", 
	x"63", x"00", x"07", x"03", x"63", x"66", x"e8", x"02", 
	x"63", x"0a", x"17", x"07", x"63", x"0e", x"67", x"00", 
	x"13", x"06", x"40", x"00", x"63", x"00", x"e7", x"05", 
	x"67", x"00", x"00", x"00", x"6f", x"f0", x"5f", x"fc", 
	x"93", x"87", x"06", x"00", x"6f", x"f0", x"df", x"fb", 
	x"13", x"85", x"06", x"00", x"6f", x"f0", x"5f", x"fb", 
	x"63", x"08", x"c7", x"0b", x"e3", x"12", x"d7", x"ff", 
	x"37", x"04", x"00", x"08", x"b7", x"04", x"00", x"01", 
	x"33", x"f1", x"86", x"00", x"33", x"61", x"91", x"00", 
	x"93", x"00", x"00", x"00", x"67", x"80", x"06", x"00", 
	x"6f", x"f0", x"9f", x"fc", x"93", x"96", x"86", x"00", 
	x"03", x"07", x"10", x"b0", x"13", x"77", x"17", x"00", 
	x"e3", x"0c", x"07", x"fe", x"03", x"07", x"00", x"b0", 
	x"13", x"77", x"f7", x"0f", x"13", x"06", x"f6", x"ff", 
	x"b3", x"06", x"d7", x"00", x"e3", x"10", x"06", x"fe", 
	x"6f", x"f0", x"9f", x"f6", x"13", x"86", x"07", x"00", 
	x"13", x"07", x"40", x"00", x"93", x"5f", x"86", x"01", 
	x"83", x"05", x"10", x"b0", x"93", x"f5", x"45", x"00", 
	x"e3", x"9c", x"05", x"fe", x"23", x"00", x"f0", x"b1", 
	x"13", x"07", x"f7", x"ff", x"13", x"16", x"86", x"00", 
	x"e3", x"12", x"07", x"fe", x"6f", x"f0", x"df", x"f3", 
	x"13", x"96", x"17", x"00", x"93", x"d7", x"f7", x"01", 
	x"b3", x"e7", x"c7", x"00", x"03", x"06", x"10", x"b0", 
	x"13", x"76", x"16", x"00", x"e3", x"0c", x"06", x"fe", 
	x"03", x"06", x"00", x"b0", x"b3", x"05", x"d7", x"00", 
	x"23", x"80", x"c5", x"00", x"13", x"76", x"f6", x"0f", 
	x"b3", x"07", x"f6", x"00", x"13", x"07", x"17", x"00", 
	x"e3", x"18", x"a7", x"fc", x"6f", x"f0", x"5f", x"f0", 
	x"93", x"07", x"00", x"00", x"13", x"07", x"00", x"00", 
	x"6f", x"f0", x"1f", x"ff", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	others => (others => '0')
    );
end package;
    
