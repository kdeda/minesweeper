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
    // bounding box
    var minRows: Int
    var maxRows: Int
    var minColumns: Int
    var maxColumns: Int
    
    // current position and direction in it
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
        
        NSLog("nextClockWiseMove: \(rowColumn), moving \(direction)")
        switch direction {
        case .up:
            if canMoveUp {
                // we can still move up
                newMove.row -= 1
            } else {
                // we came back to the top leading
                if minRows < maxRows {
                    newMove = newMove.inset
                    newMove.row = newMove.minRows
                    newMove.column = newMove.minColumns
                    newMove.direction = .right

                    NSLog("nextClockWiseMove: \(newMove.rowColumn), moving \(newMove.direction)")
                    if newMove.column >= newMove.maxColumns {
                        // there is no room to go right
                        newMove = self
                    }
                }
            }
            
        case .down:
            if canMoveDown {
                // we can still move down
                newMove.row += 1
            } else if canMoveLeft {
                // there is room to go left
                newMove.direction = .left
                newMove = newMove.nextClockWiseMove
            }
            
        case .left:
            if canMoveLeft {
                newMove.column -= 1
            } else if canMoveUp {
                // there is room to go up
                newMove.direction = .up
                newMove = newMove.nextClockWiseMove
            }
            
        case .right:
            if canMoveRight {
                // we can still move right
                newMove.column += 1
            } else if canMoveDown {
                // there is room to go down
                newMove.direction = .down
                newMove = newMove.nextClockWiseMove
            }
        }
        
        if self == newMove {
            NSLog("nextClockWiseMove: \(self.rowColumn), unable to move ...")
        } else {
            NSLog("nextClockWiseMove: \(self.rowColumn), moved \(newMove.direction) to: \(newMove.rowColumn)")
        }
        return newMove
    }
}

