----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.01.2018 19:39:00
-- Design Name: 
-- Module Name: find_candidate - Behavioral
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

entity find_candidate is
    Port (
        A : in std_logic_vector(8 downto 0) ; -- from Rows
        B : in std_logic_vector(8 downto 0) ; -- from Columns
        C : in std_logic_vector(8 downto 0) ; -- from Areas
        D : in std_logic_vector(8 downto 0) ; -- min candidate
        Candidate : out std_logic_vector(3 downto 0) 
     );
end find_candidate;

architecture Behavioral of find_candidate is

    signal tmp_logic_and_0 : std_logic_vector(8 downto 0) ; 
    signal tmp_logic_or_0  : std_logic_vector(8 downto 0) ;
    
    signal mix_tmp_logic_or : std_logic_vector(8 downto 0) ;
    
                                                        
    signal tmp_res : std_logic_vector(3 downto 0) ;    
    signal mul : std_logic_vector(8 downto 0) ; 
    
    

begin

    tmp_logic_and_0 <= NOT(A) AND NOT(B) AND NOT(C) ;
    

    
    -- logic 1 
    tmp_logic_or_0(8) <= D(8) ; 
    gen_or_1 : for i in 7 downto 0 generate
        tmp_logic_or_0(i) <= tmp_logic_or_0(i+1) or D(i) ; 
    end generate gen_or_1 ;  
    
    mul <= "111111111" when tmp_logic_or_0(0) = '0' else ('0' & tmp_logic_or_0(8 downto 1)) ;  
    
    mix_tmp_logic_or <= tmp_logic_and_0 AND mul ;   
    
    
    tmp_res <=  "0001" when mix_tmp_logic_or(8) = '1' else
                "0010" when mix_tmp_logic_or(7) = '1' else
                "0011" when mix_tmp_logic_or(6) = '1' else
                "0100" when mix_tmp_logic_or(5) = '1' else
                "0101" when mix_tmp_logic_or(4) = '1' else
                "0110" when mix_tmp_logic_or(3) = '1' else
                "0111" when mix_tmp_logic_or(2) = '1' else
                "1000" when mix_tmp_logic_or(1) = '1' else
                "1001" when mix_tmp_logic_or(0) = '1' else                                
                "0000" ; 
                                    
    
    Candidate <= tmp_res ;  
     
    


end Behavioral;
