
from copy import copy, deepcopy

sample_grid = [[6,0,0,0,0,0,0,0,3],
               [8,0,0,4,5,6,1,0,0],
               [0,5,0,0,0,0,0,0,0],
               [0,1,5,9,0,0,3,0,0],
               [0,0,0,0,1,0,0,0,0],
               [0,6,0,0,8,0,5,0,7],
               [0,0,2,0,0,0,0,0,0],
               [9,0,0,0,0,1,7,4,0],
               [4,7,0,0,9,0,0,0,6]];


nb_grid = [[i*9+j for j in range(9)] for i in range(9)] ;

def display_grid(grid):
    for i in range(9):
        for j in range(9):
            print(str(grid[i][j])+",", end='') ;
        print("") ;

def display_grid_x_y(grid, x, y):
    for i in range(9):
        for j in range(9):
            if i==x and j==y:
                print("["+str(grid[i][j])+"],", end='') ;
            else:
                print(str(grid[i][j])+",", end='') ;
        print("") ;         
                    

def build_rows_from_grid(grid):
    rows = [[0 for i in range(9)] for j in range(9)] ;
    for i in range(9):
        for  j in range(9):
            if grid[i][j] != 0:
                rows[i][grid[i][j]-1]=1 ;
    return rows ;                 

def build_columns_from_grid(grid):
    columns = [[0 for i in range(9)] for j in range(9)] ;
    for j in range(9):
        for  i in range(9):
            if grid[i][j] != 0:
                columns[j][grid[i][j]-1]=1 ;
    return columns ;        

def build_blocks_from_grid(grid):
    blocks = [[0 for i in range(9)] for j in range(9)] ;
    for i in range(9):
        base_x = (i%3)*3 ;
        base_y = (i//3)*3 ; 
        for j in range(9):
            x = base_x+(j%3) ;
            y = base_y+j//3 ;
            if grid[x][y] != 0:
                blocks[i][grid[x][y]-1]=1 ;
    return blocks ;                             


def get_candidate(rows, columns, blocks, indice, i, j):
    logical = True ;
    k = (i//3)+(j//3)*3 ; 
    while logical and indice <= 9:
        logical = rows[i][indice-1] | columns[j][indice-1] | blocks[k][indice-1] ;        
        indice = indice+1 ;
    return -1 if logical else (indice-1) ;




def sudoku_solver(grid):
    grid_copy = deepcopy(grid) ; 
    rows = build_rows_from_grid(grid) ;
    columns = build_columns_from_grid(grid) ;
    blocks = build_blocks_from_grid(grid) ; 
    indices = [1 for i in range(81)] ; 
    ptr = 0 ;
    back = False ; 
    while(ptr < 81):
        i = (ptr%9) ;
        j = (ptr//9) ;
        k = (i//3)+(j//3)*3 ;        
        if grid[i][j] == 0:
            previous_candidate = grid_copy[i][j] ; 
            if back:                
                rows[i][previous_candidate-1] = 0 ;
                columns[j][previous_candidate-1] = 0 ;
                blocks[k][previous_candidate-1] = 0 ; 
            candidate = get_candidate(rows, columns, blocks, previous_candidate+1, i, j) ;                                
            if candidate == -1:                           
                ptr = ptr-1 ;
                back = True ;
                grid_copy[i][j]  = 0 ;                                
            else:
                grid_copy[i][j]  = candidate ;                                
                rows[i][candidate-1] = 1 ;
                columns[j][candidate-1] = 1 ;
                blocks[k][candidate-1] = 1 ;
                back = False ; 
                ptr = ptr+1 ;            
        else:
            if back:
                ptr = ptr-1 ;                
            else:
                ptr = ptr+1 ; 
    return grid_copy ;                 
                
                
        
        


