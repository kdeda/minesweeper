//
//  Model.swift
//  MineSweeper
//
//  Created by Klajd Deda on 5/3/22.
//

import Foundation

enum Direction {
    case up
    case down
    case left
    case right
}

struct Move: Equatable {
    var minRows: Int
    var maxRows: Int
    var minColumns: Int
    var maxColumns: Int
    var row: Int
    var column: Int
    var direction: Direction
}

extension Move {
    // return an inset Move
    var inset: Move {
        var newMove = self
        
        newMove.minRows += 1
        newMove.maxRows -= 1
        newMove.minColumns += 1
        newMove.maxColumns -= 1
        return newMove
    }
    
    // given my current Move i will give you the next Move
    // in a clockwise fashion
    // top leading is 0, 0
    // if the same move is returned, than stop all
    var nextClockWiseMove: Move {
        var newMove = self
        
        switch direction {
        case .up:
            if (row - 1) > minRows {
                // we can still move up
                newMove.row -= 1
            } else {
                // we came back to the top leading
                if minRows < maxRows {
                    newMove = newMove.inset
                    newMove.row = newMove.minRows
                    newMove.column = newMove.minColumns
                    newMove.direction = .right

                    NSLog("newMove: \(newMove)")
                    if newMove.column >= newMove.maxColumns {
                        // there is no room to go right
                        newMove = self
                    }
                }
            }
            
        case .down:
            if (row + 1) < maxRows {
                // we can still move down
                newMove.row += 1
            } else if column > minColumns {
                // there is room to go left
                newMove.direction = .left
                newMove = newMove.nextClockWiseMove
            }
            
        case .left:
            if (column - 1) >= minColumns {
                newMove.column -= 1
            } else if (row - 1) > minRows {
                // there is room to go up
                newMove.direction = .up
                newMove = newMove.nextClockWiseMove
            }
            
        case .right:
            if (column + 1) < maxColumns {
                // we can still move right
                newMove.column += 1
            } else if row < maxRows {
                // there is room to go down
                newMove.direction = .down
                newMove = newMove.nextClockWiseMove
            }
        }
        return newMove
    }
}

