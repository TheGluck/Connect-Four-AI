#= ======= FUNCTIONS =============================================== =#
function printBoard(board :: Array{Int, 2}) :: Void
    show(IOContext(STDOUT, limit=true), "text/plain", map((x -> (x == 0) ? '_'  :  ((x == 1) ? 'X' : 'O')), board))
    println()
end

# Board and Last Played Column -> isGameActive and Winner
function winState(board :: Array{Int, 2}, lastCol :: Int)
    # Look to see if board is filled
    ! (0 in board) && return true, 0
    (board == zeros(board)) && return false, 0

    lastRow = findlast(board[:,lastCol], 0) + 1  # Last row used
    player = board[lastRow,lastCol]  # Player in lastCol,lastRow

    # Search down for verticle win
    if lastRow <= 4 && all( x -> x == player, board[lastRow:(lastRow + 4)])
        return true, player
    end

    isWin = false

    # Fluff Matrix time
    # Extend matrix by two on all sides
    # Embed board in large board
    fluff = zeros(Int,(12,13))
    fluff[4:9,4:10] = board[:]

    # Shift location
    lastRow += 3
    lastCol += 3

    # Slice possible win paths
    downDiagLists = [[fluff[lastRow - 3 + i + j, lastCol - 3 + i + j] for i in 0:3] for j in 0:3]
    horizLists = [fluff[lastRow,(lastCol-3+i):(lastCol + i)] for i in 0:3]
    upDiagLists = [[fluff[lastRow + 3 - i - j, lastCol - 3 + i + j] for i in 0:3] for j in 0:3]
    lists = vcat(vcat(downDiagLists, horizLists), upDiagLists)
    
    if any(x -> all(y -> y == player, x), lists)
        return true, player
    end
    
    return false, 0
end

function place!(board :: Array{Int, 2}, player :: Int, colNum :: Int) :: Void
    column = board[:,colNum]
    @assert 0 in column "Error: Tried to place outside the board."
    board[findlast(column, 0), colNum] = player
    return nothing
end

#=
randomChoice( board )
Takes a board as a matrix,
returns a randod valid move
=#
function randomChoice(board :: Array{Int, 2}) :: Int
    return rand([col for col in 1:size(board,2) if 0 in board[:,col]])
end

#= ================================================================= =#


# MAIN
# Initialize the board
board = Array{Int, 2}(6, 7)
board = zeros(board)

#Initialize the game
player1 = 1
player2 = -1
currentPlayer = player1
lastMove = 0
printBoard(board)

while !winState(board, lastMove)[1]
    lastMove = randomChoice(board)
    place!(board, currentPlayer, lastMove)
    printBoard(board)
    currentPlayer *= -1
end

println(currentPlayer != 1 ? 'X' : 'O', " wins")
