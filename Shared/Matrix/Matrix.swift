import Foundation

enum AppError: Error {
    case runtimeError(String)
}

struct Matrix<T: Equatable>: Equatable {
  private var entries: [[T]]
  let rows: Int
  let cols: Int
  init(_ entries: [[T]]) throws {
    if (entries.map { $0.count }.contains { $0 != entries[0].count }) {
      throw AppError.runtimeError("Invalid matrix initialization")
    }
    self.rows = entries.count
    self.cols = entries[0].count
    self.entries = entries
  }
  func getEntries() -> [[T]] { entries }
  mutating func replaceAt(row: Int, col: Int, entry: T) { entries[row][col] = entry }
  func at(_ row: Int, _ col: Int) -> T { entries[row][col] }
}

extension Matrix {
  func forEach(_ transform: (_ row: Int, _ column: Int) -> ()) {
    (0 ..< rows).forEach { row in
      (0 ..< cols).forEach { col in
        transform(row, col)
      }
    }
  }
  func map<T>(_ transform: (_ row: Int, _ column: Int) -> (T)) -> [[T]] {
    (0 ..< rows).map { row in
      (0 ..< cols).map { col in
        transform(row, col)
      }
    }
  }
}
