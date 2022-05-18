import SwiftUI
import ComposableArchitecture

struct GridState: Equatable {
  static var cellSize: CGFloat = 24.0
  let fpsCorners: Double = 20.0
  var fps: Double = 20
  var cells: Matrix<GridCellState>
  
  init(rows: Int = 3, cols: Int = 4) {
    self.cells = Matrix(rows, cols) { row, column in
      GridCellState(row: row, column: column)
    }
  }
}

enum GridAction {
  case reset
  case resetCells
  case flipCorners
  case clockWise
  case updatedCell(GridCellState)
  case cell(id: GridCellState.ID, action: GridCellAction)
  case updateFPS(Double)
}

struct GridEnvironement {
  struct FlipCornersID: Hashable {}
  struct ClockWiseID: Hashable {}
  
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var uuid: () -> UUID
  
  func reset(state: inout GridState) { // TODO: Mutability is allowed here?
    state.cells = state.cells.map { GridCellState(row: $0, column: $1) }
  }
  
  // Turn all cells gray, start at(0,0), turn corner cells yellow in coordinated fashion.
  func flipCorners(state: inout GridState, fps: Int = 6) -> Effect<GridCellState, Never> {
    reset(state: &state)
    let publisher = state.cells.entries
      .flatMap { $0 }
      .compactMap { cell -> GridCellState? in
        let cornerRow = cell.row == 0 || cell.row == state.cells.rows - 1
        let cornerColumn = cell.column == 0 || cell.column == state.cells.cols - 1
        return cornerRow && cornerColumn ? cell : nil
      }
      .publisher
      .zip(Effect.timer(id: FlipCornersID(), every: .seconds(1.0 / Double(fps)), on: mainQueue))
      .map { cell, _ -> GridCellState in
        GridCellState(row: cell.row, column: cell.column, rotation: cell.rotation + 90.0, color: .yellow)
      }
      .eraseToAnyPublisher()
      .eraseToEffect()
    return publisher
  }
  
  func cancelFlipCorners() -> Effect<GridAction, Never> {
    Effect.cancel(id: FlipCornersID())
  }
  
  // Turn all cells gray, start at(0,0), move in clockwise fashion, turn visited cells yellow.
  func clockWise(state: inout GridState, fps: Int = 6) -> Effect<GridCellState, Never> {
    
    // Prepare to move.
    var currentMove = Move(
      minRows: 0, maxRows: state.cells.rows,
      minColumns: 0, maxColumns: state.cells.cols,
      row: 0, column: 0, direction: .right
    )
    var orderedCells = [state.cells.at(currentMove.row,currentMove.column)]
    var working = true
    
    // Reset grid.
    reset(state: &state)
    
    // Move until complete.
    repeat {
      let newMove = currentMove.nextClockWiseMove
      if currentMove == newMove { working = false }
      else {
        orderedCells.append(state.cells.at(newMove.row, newMove.column))
        currentMove = newMove
      }
    } while working
    
    // Animate.
    let publisher = orderedCells
      .publisher
      .zip(Effect.timer(id: ClockWiseID(), every: .seconds(1.0 / Double(fps)), on: mainQueue))
      .map { cell, _ -> GridCellState in
        GridCellState(row: cell.row, column: cell.column, rotation: cell.rotation + 90.0, color: .yellow)
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
            .flipCorners(state: &state, fps: Int(state.fps))
            .map(GridAction.updatedCell)
        )
        
      case .clockWise:
        return .merge(
          environment.cancelFlipCorners(),
          environment.cancelClockWise(),
          environment.clockWise(state: &state, fps: Int(state.fps))
            .map(GridAction.updatedCell)
        )
        
      case let .updatedCell(cell):
        state.cells.replaceAt(row: cell.row, col: cell.column, entry: cell)
        return .none
        
      // TODO: Handle this.
      case .cell(id: let id, action: let action):
        return .none
        
      case let .updateFPS(newFPS):
        state.fps = newFPS
        return .none
      }
    }
  )
}

extension GridState {
  static let liveStore = Store<GridState, GridAction>(
    initialState: .init(rows: 11, cols: 15),
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
