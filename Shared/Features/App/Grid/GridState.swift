//
//  GridState.swift
//  MineSweeper
//
//  Created by Klajd Deda on 5/6/22.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct GridState: Equatable {
    static var cellSize: CGFloat = 24

    var clockWiseError = ""

    var rows: Int { matrix.rows }
    var columns: Int { matrix.columns }
    var matrix: Matrix
    var cells: [[GridCell]]
    
    init(rows: Int = 3, columns: Int = 4) {
        self.matrix = Matrix(rows, columns)
        self.cells = matrix.map { row, column in
            GridCell(row: row, column: column)
        }
    }
}

enum GridAction {
    case reset
    case resetCells
    case flipCorners
    case clockWise
    case updatedCell(GridCell)
}

struct GridEnvironement {
    struct FlipCornersID: Hashable {}
    struct ClockWiseID: Hashable {}
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    
    func reset(state: inout GridState) {
        state.clockWiseError = ""
        state.matrix.forEach { row, column in
            state.cells[row][column].rotation = 0.0
            state.cells[row][column].color = Color.gray
        }
        // or we could re-create the cells
        //    state.cells = state.matrix.map { row, column in
        //        GridCell(row: row, column: column)
        //    }
    }
    
    // 1) reset all to gray
    // 2) flip the 4 corners
    func flipCorners(state: inout GridState, fps: Int = 6) -> Effect<GridCell, Never> {
        reset(state: &state)

        let publisher = state.cells
            .flatMap { $0 }
            .compactMap { cell -> GridCell? in
                let cornerRow = cell.row == 0 || cell.row == state.rows - 1
                let cornerColumn = cell.column == 0 || cell.column == state.columns - 1
                
                guard cornerRow && cornerColumn
                else { return nil }
                return cell
            }
            .publisher
            .zip(Effect.timer(id: FlipCornersID(), every: .seconds(1.0 / Double(fps)), on: mainQueue))
            .map { cell, _ -> GridCell in
                var newValue = cell
                
                newValue.rotation += 90.0
                newValue.color = Color.yellow
                return newValue
            }
            .eraseToAnyPublisher()
            .eraseToEffect()
        return publisher
    }
    
    func cancelFlipCorners() -> Effect<GridAction, Never> {
        Effect.cancel(id: FlipCornersID())
    }
    
    // 1) reset all to gray
    // 2) start at 0.0 and go clockwise
    func clockWise(state: inout GridState, fps: Int = 6) -> Effect<GridCell, Never> {
        let rows = state.rows
        let columns = state.columns
        var currentMove = Move(minRows: 0, maxRows: rows, minColumns: 0, maxColumns: columns, row: 0, column: 0, direction: .right)
        var orderedCells = [state.cells[currentMove.row][currentMove.column]]
        var working = true
        
        reset(state: &state)
        // this will take a jiffy
        repeat {
            let newMove = currentMove.nextClockWiseMove
            
            if newMove.row == 2 && newMove.column == 1 {
                // debug ...
            }
            if currentMove == newMove {
                working = false
            } else {
                orderedCells.append(state.cells[newMove.row][newMove.column])
                currentMove = newMove
            }
        } while working
        
        if rows * columns != orderedCells.count {
            state.clockWiseError = "expected: \(rows * columns) and got: \(orderedCells.count)"
        }
        // clockWiseError = "expected: \(rows * columns) and got: \(orderedCells.count)"
        let publisher = orderedCells
            .publisher
            .zip(Effect.timer(id: ClockWiseID(), every: .seconds(1.0 / Double(fps)), on: mainQueue))
            .map { cell, _ -> GridCell in
                var newValue = cell
                
                newValue.rotation += 90.0
                newValue.color = Color.yellow
                return newValue
            }
            .eraseToAnyPublisher()
            .eraseToEffect()
        return publisher
    }
    
    func cancelClockWise() -> Effect<GridAction, Never> {
        Effect.cancel(id: ClockWiseID())
    }

}

extension GridState {
    static let reducer = Reducer<GridState, GridAction, GridEnvironement>.combine(
        Reducer { state, action, environment in
            // Log4swift[Self.self].info("action: '\(action)'")
            
            switch action {
            case .resetCells:
                environment.reset(state: &state)
                return .none

            case .reset:
                return .merge(
                    environment.cancelFlipCorners(),
                    environment.cancelClockWise(),
                    Effect(value: .resetCells)
                )
                
            case .flipCorners:
                return .merge(
                    environment.cancelFlipCorners(),
                    environment.cancelClockWise(),
                    environment
                        .flipCorners(state: &state, fps: 6)
                        .map(GridAction.updatedCell)
                )
                
            case .clockWise:
                return .merge(
                    environment.cancelFlipCorners(),
                    environment.cancelClockWise(),
                    environment.clockWise(state: &state, fps: 6)
                        .map(GridAction.updatedCell)
                )

            case let .updatedCell(cell):
                state.cells[cell.row][cell.column] = cell
                return .none

            }
        }
    )
}

extension GridState {
    static let liveStore = Store<GridState, GridAction>(
        initialState: .init(rows: 11, columns: 15),
        reducer: reducer,
        environment: GridEnvironement(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            uuid: UUID.init
        )
    )
    
    static let mockStore = Store<GridState, GridAction>(
        initialState: .init(),
        reducer: reducer,
        environment: GridEnvironement(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            uuid: UUID.init
        )
    )
}
