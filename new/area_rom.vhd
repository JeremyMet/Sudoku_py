----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.07.2017 17:49:21
-- Design Name: 
-- Module Name: ROM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use std.textio.all;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity area_rom is
    port(
        clk : in std_logic ;             
        addr : in std_logic_vector(6 downto 0) ;         
        data : out std_logic_vector(11 downto 0) := "000000000000"  
    ) ;         
end area_rom;

architecture Behavioral of area_rom is

    type ram_type is array(0 to 127) of std_logic_vector(11 downto 0) ;         
    signal internal_data : std_logic_vector(11 downto 0) ; 
    
    impure function InitRomFromFile (RomFileName : in string) return ram_type is
        FILE romfile : text is in RomFileName;
        variable RomFileLine : line;
        variable ram : ram_type;
        variable tmp : std_logic_vector(11 downto 0) ; 
        begin
            for i in ram_type'range loop
                readline(romfile, RomFileLine);
                hread(RomFileLine, tmp);
                ram(i) := tmp(11 downto 0) ;                                     
            end loop;
        return ram;
    end function;
    
    signal internal_rom : ram_type := InitRomFromFile("D:\Documents\Projets\Python\sudoku\area_rom.hex")  ;
             
    

begin
    process(clk)
    begin
        if rising_edge(clk) then            
            internal_data <= internal_rom(to_integer(unsigned(addr))) ;             
        end if ;     
    end process ;          
    data <= internal_data ;         


end Behavioral;
