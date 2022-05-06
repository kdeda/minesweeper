////
////  AppState.swift
////  MineSweeper
////
////  Created by Klajd Deda on 5/6/22.
////
//
//import Foundation
//import SwiftUI
//import ComposableArchitecture
//
//struct AppState: Equatable {
//    static var cellSize: CGFloat = 24
//
//    var matrix = Matrix(3, 4)
//    var rows: Int {
//        matrix.rows
//    }
//    var columns: Int {
//        matrix.columns
//    }
//    var clockWiseError = ""
//    var cells: [[GridCell]]
//    
//    init() {
//        self.cells = matrix.map { row, column in
//            GridCell(row: row, column: column)
//        }
//    }
//}
//
//enum AppAction {
//    case reset
//    case flipCorners
//    case clockWise
//    case updatedCell(GridCell)
//}
//
//struct AppEnvironement {
//    struct FlipCornersID: Hashable {}
//    
//    var mainQueue: AnySchedulerOf<DispatchQueue>
//    var uuid: () -> UUID
////
////    // 1) reset all to gray
////    // 2) start at 0.0 and go clockwise
////    func clockWise(fps: Int = 6) {
////        reset()
////
////        var currentMove = Move(minRows: 0, maxRows: rows, minColumns: 0, maxColumns: columns, row: 0, column: 0, direction: .right)
////        var orderedCells = [self.cells[currentMove.row][currentMove.column]]
////        var working = true
////        repeat {
////            let newMove = currentMove.nextClockWiseMove
////
////            if newMove.row == 2 && newMove.column == 1 {
////                // debug ...
////            }
////            if currentMove == newMove {
////                working = false
////            } else {
////                orderedCells.append(self.cells[newMove.row][newMove.column])
////                currentMove = newMove
////            }
////        } while working
////
////        if rows * columns != orderedCells.count {
////            clockWiseError = "expected: \(rows * columns) and got: \(orderedCells.count)"
////        }
////        // clockWiseError = "expected: \(rows * columns) and got: \(orderedCells.count)"
////        orderedCells.animateChangesV1(fps: fps)
////            .sink(receiveValue: { cellData in
////                self.cells[cellData.row][cellData.column].cellData = cellData
////            })
////
//////        orderedCells.animateChanges(fps: fps)
//////            .receive(on: DispatchQueue.main)
//////            .sink(receiveValue: { cellDatas in
//////                cellDatas.forEach { cellData in
//////                    self.cells[cellData.row][cellData.column].cellData = cellData
//////                }
//////            })
////        .store(in: &cancellables)
////    }
//}
//
//extension GridState {
//    static let reducer = Reducer<GridState, GridAction, GridEnvironement>.combine(
//        Reducer { state, action, environment in
//            // Log4swift[Self.self].info("action: '\(action)'")
//            
//            switch action {
//            case .reset:
//                state.clockWiseError = ""
//                state.matrix.forEach { row, column in
//                    state.cells[row][column].rotation = 0.0
//                    state.cells[row][column].color = Color.gray
//                }
//                return .none
//                
//            case .flipCorners:
//                return environment
//                    .flipCorners(state: &state, fps: 6)
//                    .map(GridAction.updatedCell)
//                
//            case .clockWise:
//                return .none
//                
//            case let .updatedCell(cell):
//                return .none
//
//            }
//        }
//    )
//}
//
//extension GridState {
//    static let defaultStore = Store<GridState, GridAction>(
//        initialState: .init(),
//        reducer: reducer,
//        environment: GridEnvironement(
//            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
//            uuid: UUID.init
//        )
//    )
//}
