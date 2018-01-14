----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.01.2018 21:02:46
-- Design Name: 
-- Module Name: bench_find_candidate - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bench_find_candidate is
--  Port ( );
end bench_find_candidate;

architecture Behavioral of bench_find_candidate is


    component find_candidate is
        Port (
            A : in std_logic_vector(8 downto 0) ; -- from Rows
            B : in std_logic_vector(8 downto 0) ; -- from Columns
            C : in std_logic_vector(8 downto 0) ; -- from Areas
            D : in std_logic_vector(8 downto 0) ; -- min candidate
            Candidate : out std_logic_vector(3 downto 0) 
         );
    end component find_candidate;
    
    signal A : std_logic_vector(8 downto 0) := "001001000" ; 
    signal B : std_logic_vector(8 downto 0) := "000101011" ;
    signal C : std_logic_vector(8 downto 0) := "000011010" ;
    signal D : std_logic_vector(8 downto 0) := "100000000" ;
    signal Candidate : std_logic_vector(3 downto 0) ; 

begin


    inst_find_candidate : find_candidate port map(A, B, C, D, Candidate) ; 



end Behavioral;
