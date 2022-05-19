import SwiftUI
import ComposableArchitecture

struct GridCellState: Equatable {
    static let viewSize: CGFloat = 24
    var row: Int
    var column: Int
    var rotation: CGFloat = 0.0
    var color = Color.gray
}

enum GridCellAction: Equatable {
    case rotate
}

struct GridCellEnvironment {
    
}

extension GridCellState: CustomStringConvertible {
    var description: String {
        let rowColumn = String(format: "[%2d, %2d]", row, column)
        return "\(rowColumn), rotation: \(rotation), color: \(color)"
    }
}

extension GridCellState: Identifiable {
    var id: Int {
        row  * 1_000_000 + column
    }
}

extension GridCellState {
    static let reducer = Reducer<GridCellState, GridCellAction, GridCellEnvironment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .rotate:
                return .none
            }
        }
    )
}

extension GridCellState {
    static let liveStore = Store<GridCellState, GridCellAction>(
        initialState: .init(row: 1, column: 1),
        reducer: reducer,
        environment: GridCellEnvironment()
    )
    static let mockStore = Store<GridCellState, GridCellAction>(
        initialState: .init(row: 1, column: 1),
        reducer: reducer,
        environment: GridCellEnvironment()
    )
}
