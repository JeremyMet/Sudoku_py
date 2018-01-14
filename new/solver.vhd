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

entity solver is
--  Port ( );
end solver;

architecture Behavioral of solver is
    type fsm is (idle, row_constraints, col_constraints, area_constraints, write, back) ; 
    
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
        data  : out std_logic_vector(6 downto 0) 
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
    signal data_out_col : std_logic_vector(8 downto 0) ;
    ------------------------
    signal data_out_area : std_logic_vector(8 downto 0) ;
    signal wr_area : std_logic := '0' ;  
    ------------------------        
    signal data_out_row : std_logic_vector(8 downto 0) ;
    signal row_bit : std_logic_vector(8 downto 0) ;
    signal row_buffer : std_logic_vector(8 downto 0) := (others=>'0') ;    
    signal row_logic : std_logic_vector(8 downto 0) ;
    ------------------------
    signal output_area_rom : std_logic_vector(6 downto 0) ;
    signal area_rom_ptr : std_logic_vector(6 downto 0) := (others=>'0') ;   
    ------------------------
    signal current_fsm : fsm := idle ;
    signal next_state : fsm := row_constraints ;      
    signal scanned_grid : std_logic := '0' ;         
    ------------------------
    signal latency : std_logic := '0' ;
    ------------------------
    signal candidate : std_logic_vector(3 downto 0) := (others=>'0') ;
    ------------------------
    signal wr_RAM : std_logic := '0' ; 
    signal data_in_RAM : std_logic_vector(4 downto 0) := (others=>'0') ;
    ------------------------ 
       
        
    
    
    
begin

    inst_clk : clock port map(clk=>clk) ; 
    
    
    inst_RAM : RAM port map(
                    clk => clk,
                    addr => ptr_mult,
                    wr   => wr_RAM,
                    data_in => data_in_RAM,                                             
                    data => data_out_rom) ;
                    
    inst_area_rom : area_rom port map(
                    clk => clk,
                    addr => area_rom_ptr,                                             
                    data => output_area_rom) ;                    
                    
    inst_row_constraint_memory : constraint_memory port map(
        clk => clk,
        addr => cpt_row_addr,     
        wr => wr_row, 
        data_in => row_logic,
        data_out => data_out_row) ;
                
    inst_col_constraint_memory : constraint_memory port map(
                clk => clk,
                addr => cpt_row_addr,     
                wr => wr_col, 
                data_in => row_logic,
                data_out => data_out_col) ;
                
                
    inst_area_constraint_memory : constraint_memory port map(
                clk => clk,
                addr => cpt_row_addr,     
                wr => wr_area, 
                data_in => row_logic,
                data_out => data_out_area) ;                
                

    inst_find_candidate : find_candidate port map(
        A => data_out_row,
        B => data_out_col,
        C => data_out_area, 
        D => row_bit,  
        Candidate => candidate) ; 


        
    -- fsm state management         
        
    process(clk)
    begin
        if rising_edge(clk) then
            if current_fsm = idle then
                current_fsm <= next_state ;                      
            end if ;                             
            if current_fsm = row_constraints or current_fsm = col_constraints or current_fsm = area_constraints then                        
                if cpt_row = "000000000" then    
                    current_fsm <= idle ;                   
                    if current_fsm = row_constraints then
                        next_state <= col_constraints ;
                    elsif current_fsm = col_constraints then
                        next_state <= area_constraints ; 
                    elsif current_fsm = area_constraints then
                        next_state <= idle ;                                                   
                    end if ; -- row, col, area                                          
                end if ; -- cpt_row
            end if ; -- row, col, area
            ----------------------------
            if current_fsm = write then
                if candidate = "0000" then
                    current_fsm <= back ;                 
                end if ;                     
            end if ;
            ----------------------------                 
            if current_fsm = back then
                if candidate /= "0000" and data_out_rom(0)='0' then
                    current_fsm <= write ; 
                end if ;  
            end if ;                            
        end if ; -- rising_edge             
    end process ; 
                 
                 
    -- gestion des ptr                             
    
    process(clk)
    begin
        if rising_edge(clk) then     
            fsm_case : case current_fsm is     
                when idle =>
                    ptr <= (others=>'0') ;
                    area_rom_ptr <= (others=>'0') ; 
                    base_ptr <= "0000001" ;   
                    cpt_col  <= "1000000000" ;    
                    cpt_row  <= "100000000" ;
                    latency <= '0' ;                    
                when row_constraints | col_constraints | area_constraints =>
                    if current_fsm = row_constraints then                                     
                        ptr <= std_logic_vector(unsigned(ptr)+1) ;
                    elsif current_fsm = col_constraints then                           
                        ptr <= std_logic_vector(unsigned(ptr)+9) ;
                    elsif current_fsm = area_constraints then                            
                        area_rom_ptr <= std_logic_vector(unsigned(area_rom_ptr)+1) ;
                        latency <= '1' ;                                          
                    end if ;                                             
                    -- write management ---                                              
                    if current_fsm = row_constraints then
                        if cpt_col = "0000000010" then                        
                            wr_row <= '1' ;
                        else
                            wr_row <= '0' ;
                        end if ; 
                    end if ;
                    -----------------------
                    if current_fsm = col_constraints then
                        if cpt_col = "0000000010" then                        
                            wr_col <= '1' ;
                        else
                            wr_col <= '0' ;
                        end if ; 
                    end if ;
                    -----------------------                    
                    if current_fsm = area_constraints then
                        if cpt_col = "0000000010" then                        
                            wr_area <= '1' ;
                        else
                            wr_area <= '0' ;
                        end if ; 
                    end if ;                                                            
                    ----------------------- 
                    -- ptr manager for columns                                        
                    if current_fsm = col_constraints then
                        if cpt_col = "0000000010" then 
                            base_ptr <= std_logic_vector(unsigned(base_ptr)+1) ;
                            ptr <= base_ptr ; 
                        end if ;                      
                    end if ;                            
                    -----------------------                                
                    if cpt_col = "0000000001" then                        
                        cpt_row <= '0' & cpt_row(8 downto 1) ;
                        cpt_col <= "0100000000" ;                                                     
                    else
                        if current_fsm /= area_constraints or latency = '1' then
                            cpt_col <= '0' & cpt_col(9 downto 1) ;
                        end if ;                                                                                                            
                    end if ; 
                    -----------------------                                                 
                when write =>
                    ptr <= std_logic_vector(unsigned(ptr)+1) ;                     
                when back =>                                     
                    ptr <= std_logic_vector(unsigned(ptr)-1) ;   
                                                                                                                                                                                                      
                when others => null ;                 
            end case fsm_case ;              
        end if ; -- end rising_edge.     
    end process ;
    
    ptr_mult <= output_area_rom when current_fsm = area_constraints else ptr ;    
    wr_RAM <= '1' when (candidate /= "0000" and current_fsm = write and data_out_rom(0)='0' ) else '0' ;  
        
    -- row_buffer logic ; 
    process(clk)
    begin
        if rising_edge(clk) then
            if cpt_col = "0000000001" then
                row_buffer <= (others=>'0') ; 
            else
                row_buffer <= row_logic ; 
            end if ;                 
        end if ;             
    end process ;     
    
    row_logic <= row_bit OR row_buffer ;
    
    cpt_row_addr <= "0000" when cpt_row = "100000000" else
                    "0001" when cpt_row = "010000000" else
                    "0010" when cpt_row = "001000000" else
                    "0011" when cpt_row = "000100000" else
                    "0100" when cpt_row = "000010000" else
                    "0101" when cpt_row = "000001000" else
                    "0110" when cpt_row = "000000100" else
                    "0111" when cpt_row = "000000010" else
                    "1000" when cpt_row = "000000001" ;  
                    
                    
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
