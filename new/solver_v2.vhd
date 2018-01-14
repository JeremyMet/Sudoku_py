----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.12.2017 17:17:33
-- Design Name: 
-- Module Name: solver - Behavioral
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

entity solver_v2 is
--  Port ( );
end solver_v2;

architecture Behavioral of solver_v2 is
    type fsm is (idle, constraint_write, constraint_load_addresses, constraint_load_data, tracking_load_addresses, tracking_load_data, tracking_process, tracking_write) ; 
    
    --------------------------------------
    component constraint_memory is
      Port ( 
        clk : in std_logic ; 
        addr : in std_logic_vector(3 downto 0) ;
        wr   : std_logic ; 
        data_in : in std_logic_vector(8 downto 0) ;
        data_out : out std_logic_vector(8 downto 0)  
        );
    end component constraint_memory;    
    --------------------------------------    
    component ROM is
            port(
                clk : in std_logic ;             
                addr : in std_logic_vector(6 downto 0) ;
                data : out std_logic_vector(4 downto 0)   
            ) ;         
    end component ROM;
    
    --------------------------------------    
    component RAM is
        port(
            clk : in std_logic ;             
            addr : in std_logic_vector(6 downto 0) ;
            wr   : in std_logic ; 
            data_in : in std_logic_vector(4 downto 0) ; 
            data : out std_logic_vector(4 downto 0) := "00000"  
        ) ;         
    end component RAM;    
    
    --------------------------------------
    component clock is
        generic(
            period : time := 100 ns   
        ) ;         
        port(
            clk : out std_logic 
            ) ;
    end component clock;
    --------------------------------------
    component area_rom is
      Port ( 
        clk : in std_logic ; 
        addr : in std_logic_vector(6 downto 0) ;
        data  : out std_logic_vector(11 downto 0) 
       ) ; 
    end component area_rom;
    --------------------------------------
    component find_candidate is
        Port (
            A : in std_logic_vector(8 downto 0) ; -- from Rows
            B : in std_logic_vector(8 downto 0) ; -- from Columns
            C : in std_logic_vector(8 downto 0) ; -- from Areas
            D : in std_logic_vector(8 downto 0) ; -- min candidate
            Candidate : out std_logic_vector(3 downto 0) 
         );
    end component find_candidate;
    --------------------------------------
    signal clk : std_logic ;     
    signal ptr : std_logic_vector(6 downto 0) := (others=>'0') ;
    signal ptr_mult : std_logic_vector(6 downto 0) := (others=>'0') ;  
    signal base_ptr : std_logic_vector(6 downto 0) := (others=>'0') ;    
    signal wr_col : std_logic := '0' ;    
    signal wr_row : std_logic := '0' ;
    ------------------------ 
    signal data_in_rom : std_logic_vector(8 downto 0) := (others=>'0') ; 
    signal data_out_rom : std_logic_vector(4 downto 0) ;
    ------------------------
    signal constraint_memory_column_in  : std_logic_vector(8 downto 0) := (others=>'0') ;   
    signal constraint_memory_column_out : std_logic_vector(8 downto 0) := (others=>'0') ;
    ------------------------
    signal cpt_row : std_logic_vector(8 downto 0) := "100000000" ; 
    signal cpt_col : std_logic_vector(9 downto 0) := "1000000000" ;
    signal cpt_row_addr : std_logic_vector(3 downto 0) ;  
    signal cpt_col_addr : std_logic_vector(3 downto 0) ;
    signal cpt_area_addr : std_logic_vector(3 downto 0) ;
    signal data_out_col : std_logic_vector(8 downto 0) ;
    ------------------------
    signal data_out_area : std_logic_vector(8 downto 0) ;
    signal wr_area : std_logic := '0' ;  
    ------------------------        
    signal data_out_row : std_logic_vector(8 downto 0) ;
    signal row_bit : std_logic_vector(8 downto 0) ;
    signal row_buffer : std_logic_vector(8 downto 0) := (others=>'0') ;
    ------------------------    
    signal in_logic_row : std_logic_vector(8 downto 0) ;
    signal in_logic_col : std_logic_vector(8 downto 0) ;
    signal in_logic_area : std_logic_vector(8 downto 0) ;
    ------------------------
    signal output_area_rom : std_logic_vector(11 downto 0) ;
    signal area_rom_ptr : std_logic_vector(6 downto 0) := (others=>'0') ;   
    ------------------------
    signal current_fsm : fsm := idle ;
    signal next_state : fsm := idle ;      
    signal scanned_grid : std_logic := '0' ;         
    ------------------------
    signal latency : std_logic := '0' ;
    ------------------------
    signal candidate : std_logic_vector(3 downto 0) := (others=>'0') ;
    signal extended_candidate : std_logic_vector(8 downto 0) ; 
    ------------------------
    signal wr_RAM : std_logic := '0' ; 
    signal data_in_RAM : std_logic_vector(4 downto 0) := (others=>'0') ;
    ------------------------     
    signal wr_constraint : std_logic := '0' ; 
    
    signal back : std_logic := '0' ;  
    signal sig_candidate : std_logic_vector(4 downto 0) ; 
    
    signal constraint_processed : std_logic := '0' ; 
    signal tracking_processed : std_logic := '0' ;
    
    signal tracking : std_logic := '0' ;
    signal del : std_logic := '0' ;
       
        
    
    
    
begin

    inst_clk : clock port map(clk=>clk) ; 
    
    
    inst_RAM : RAM port map(
                    clk => clk,
                    addr => ptr,
                    wr   => wr_RAM,
                    data_in => sig_candidate,                                             
                    data => data_out_rom) ;
                    
    inst_area_rom : area_rom port map(
                    clk => clk,
                    addr => ptr,                                             
                    data => output_area_rom) ;
                                        
-------------------------
-- Constraint Memories --
-------------------------                    
    inst_row_constraint_memory : constraint_memory port map(
        clk => clk,
        addr => cpt_row_addr,     
        wr => wr_constraint, 
        data_in => in_logic_row,
        data_out => data_out_row) ;
                
    inst_col_constraint_memory : constraint_memory port map(
                clk => clk,
                addr => cpt_col_addr,     
                wr => wr_constraint, 
                data_in => in_logic_col,
                data_out => data_out_col) ;
                
                
    inst_area_constraint_memory : constraint_memory port map(
                clk => clk,
                addr => cpt_area_addr,     
                wr => wr_constraint, 
                data_in => in_logic_area,
                data_out => data_out_area) ;
                
                
    in_logic_row <= (data_out_row   OR row_bit) when tracking = '0' else
                    (data_out_row  XOR row_bit) when (del = '1' or back = '1') else
                    (data_out_row   OR extended_candidate) ;
                    
    in_logic_col <= (data_out_col   OR row_bit) when tracking = '0' else
                    (data_out_col  XOR row_bit) when (del = '1' or back = '1') else
                    (data_out_col   OR extended_candidate) ;    
    
    in_logic_area <= (data_out_area   OR row_bit) when tracking = '0' else
                    (data_out_area  XOR row_bit) when (del = '1' or back = '1') else
                    (data_out_area   OR extended_candidate) ;    
    
                                                                            
    
    cpt_col_addr  <= output_area_rom(11 downto 8) ; 
    cpt_row_addr  <= output_area_rom(7 downto 4) ; 
    cpt_area_addr <= output_area_rom(3 downto 0) ;
                
--------------------
-- find_candidate --
--------------------

    inst_find_candidate : find_candidate port map(
        A => data_out_row,
        B => data_out_col,
        C => data_out_area, 
        D => row_bit,  
        Candidate => candidate) ; 


 
---------    
-- fsm --
---------
-- I could have merged some states but I think It is not worth the deal as it would be a bit "harder" to read. 


    process(clk)
    begin    
        if rising_edge(clk) then
        states : case current_fsm is
                when idle  =>
                    ptr <= (others=>'0') ;
                    if constraint_processed = '0' then 
                        current_fsm <= constraint_load_addresses ; -- for debug purpose only.
                    else
                        if tracking_processed ='0' then
                            current_fsm <= tracking_load_addresses ; -- for debug purpose only.
                        end if ;                             
                    end if ;                          
                when constraint_load_addresses =>
                    current_fsm <= constraint_load_data ;
                    wr_constraint <= '1' ;
                when constraint_load_data => 
                    current_fsm <= constraint_write ;                                    
                when constraint_write =>
                    wr_constraint <= '0' ;                  
                    if ptr = "1010000" then
                        current_fsm <= idle ;
                        constraint_processed <= '1' ;   
                    else
                        ptr <= std_logic_vector(unsigned(ptr)+1) ;
                        current_fsm <= constraint_load_addresses ;
                    end if ;
                --------------------------------------------
                -- Processing ------------------------------
                --------------------------------------------                           
                when tracking_load_addresses =>
                    tracking <= '1' ; 
                    current_fsm <= tracking_load_data ; 
                when tracking_load_data =>
                    current_fsm <= tracking_process  ;
                when tracking_process =>
                    if data_out_rom(0) = '0' then -- we modify internal register only if the case is writtable ;)                        
                        wr_constraint <= '1' ;                                                                  
                        if candidate = "0000" then                            
                                back <= '1' ;  
                                wr_RAM <= '1' ;                                                                                                   
                        else
                            back <= '0' ;
                            if back = '1' then
                                del <= '1' ;
                                wr_RAM <= '0' ;
                            else                             
                                wr_RAM <= '1' ;                                                            
                            end if ;                                                                                                                                                                                                                           
                        end if ;                      
                    end if ;
                    current_fsm <= tracking_write  ;                              
                when tracking_write =>
                    del <= '0' ; 
                    wr_RAM <= '0' ; 
                    wr_constraint <= '0' ;                    
                    if del = '0' then 
                        if back = '1' then
                            ptr <= std_logic_vector(unsigned(ptr)-1) ;
                        else 
                            ptr <= std_logic_vector(unsigned(ptr)+1) ;
                        end if ;
                    end if ;                        
                    if ptr = "1010000" then -- potentiel bug ici ;)
                        current_fsm <= idle ;
                        tracking <= '0' ;
                        tracking_processed <= '1' ;   
                    else
                        current_fsm <= tracking_load_addresses ; 
                    end if ;                               
                                                                                                                                      
                when others => null ;         
            end case states ;
        end if ; -- fin de condition sur clk.
    end process ;
              
              
    sig_candidate <= candidate & '0' ;               
    
    
    
    extended_candidate <= "100000000" when candidate = "0001" else                   
                          "010000000" when candidate = "0010" else
                          "001000000" when candidate = "0011" else               
                          "000100000" when candidate = "0100" else
                          "000010000" when candidate = "0101" else
                          "000001000" when candidate = "0110" else               
                          "000000100" when candidate = "0111" else
                          "000000010" when candidate = "1000" else
                          "000000001" when candidate = "1001" else
                          "000000000" ;                                 
    
    
                    
                    
    row_bit <= "100000000" when data_out_rom(4 downto 1) = "0001" else                   
               "010000000" when data_out_rom(4 downto 1) = "0010" else
               "001000000" when data_out_rom(4 downto 1) = "0011" else               
               "000100000" when data_out_rom(4 downto 1) = "0100" else
               "000010000" when data_out_rom(4 downto 1) = "0101" else
               "000001000" when data_out_rom(4 downto 1) = "0110" else               
               "000000100" when data_out_rom(4 downto 1) = "0111" else
               "000000010" when data_out_rom(4 downto 1) = "1000" else
               "000000001" when data_out_rom(4 downto 1) = "1001" else
               "000000000" ;                                 

end Behavioral;
