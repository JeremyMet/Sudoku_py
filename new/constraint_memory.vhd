----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.12.2017 17:02:53
-- Design Name: 
-- Module Name: constraint_memory - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity constraint_memory is
  Port ( 
    clk : in std_logic ; 
    addr : in std_logic_vector(3 downto 0) ;
    wr   : std_logic ; 
    data_in : in std_logic_vector(8 downto 0) ;
    data_out : out std_logic_vector(8 downto 0)  
    );
end constraint_memory;

architecture Behavioral of constraint_memory is

    subtype word_t is std_logic_vector(8 downto 0);
    type memory_t is array(8 downto 0) of word_t;
    
    signal ram : memory_t := (others=>(others=>'0')) ;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if wr = '1' then
                ram(to_integer(unsigned(addr))) <= data_in ; 
            end if ; 
            data_out <= ram(to_integer(unsigned(addr))) ; 
        end if ; 
    end process ; 


end Behavioral;
