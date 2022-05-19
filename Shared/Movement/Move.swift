import Foundation

enum Direction {
    case up
    case down
    case left
    case right
}

struct Move: Equatable {
    // Bounding box.
    var minRows: Int
    var maxRows: Int
    var minColumns: Int
    var maxColumns: Int
    
    // Current position and direction in bounding box.
    var row: Int
    var column: Int
    var direction: Direction
}

extension Move {
    
    var rowColumn: String {
        return String(format: "[%2d, %2d]", row, column)
    }
    
    var debugString: String {
        return "\(rowColumn), direction: \(direction)"
    }
    
    var canMoveRight: Bool {
        (column + 1) < maxColumns
    }
    
    var canMoveLeft: Bool {
        (column - 1) >= minColumns
    }
    
    var canMoveUp: Bool {
        (row - 1) > minRows
    }
    
    var canMoveDown: Bool {
        (row + 1) < maxRows
    }
    
    var inset: Move {
        var newMove = self
        newMove.minRows += 1
        newMove.maxRows -= 1
        newMove.minColumns += 1
        newMove.maxColumns -= 1
        return newMove
    }
    
    /**
     Given current move:
     1. give next move in clockwise fashion
     2. top leading is (0, 0)
     3. if same move is returned, stop all
     */
    var nextClockWiseMove: Move {
        var newMove = self
        switch direction {
        case .up:
            if canMoveUp {
                newMove.row -= 1
            }
            else { // We came back to the top leading.
                if minRows < maxRows {
                    newMove = newMove.inset
                    newMove.row = newMove.minRows
                    newMove.column = newMove.minColumns
                    newMove.direction = .right
                    
                    // There is no room to go right.
                    if newMove.column >= newMove.maxColumns {
                        newMove = self
                    }
                }
            }
        case .down:
            if canMoveDown {
                newMove.row += 1
            }
            else if canMoveLeft {
                newMove.direction = .left
                newMove = newMove.nextClockWiseMove
            }
        case .left:
            if canMoveLeft {
                newMove.column -= 1
            }
            else if canMoveUp {
                newMove.direction = .up
                newMove = newMove.nextClockWiseMove
            }
        case .right:
            if canMoveRight {
                newMove.column += 1
            }
            else if canMoveDown {
                newMove.direction = .down
                newMove = newMove.nextClockWiseMove
            }
        }
        return newMove
    }
}
