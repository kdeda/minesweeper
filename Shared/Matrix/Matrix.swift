import Foundation

struct Matrix<T: Equatable>: Equatable {
    public private(set) var entries: [[T]]
    let rows: Int
    let cols: Int

    init(_ rows: Int, _ cols: Int, _ transform: (_ row: Int, _ column: Int) -> (T)) {
        self.rows = rows
        self.cols = cols

        self.entries = (0..<rows).map { row in
            (0..<cols).map { col in
                transform(row, col)
            }
        }
    }

    mutating func replaceAt(row: Int, col: Int, entry: T) { entries[row][col] = entry }
    func at(_ row: Int, _ col: Int) -> T { entries[row][col] }
}

extension Matrix {
    func forEach(_ transform: (_ row: Int, _ column: Int) -> Void) {
        (0 ..< rows).forEach { row in
            (0 ..< cols).forEach { col in
                transform(row, col)
            }
        }
    }

    func map<V>(_ transform: (_ row: Int, _ column: Int) -> (V)) -> Matrix<V> where V: Equatable {
//        var entries: [[V]] = []
//
//        (0 ..< rows).map { row in
//            var row = [V]
//            (0 ..< cols).map { col in
//                row.append(transform(row, col))
//            }
//            entries.append(row)
//        }
        return Matrix<V>(rows, cols, transform)
    }
}
