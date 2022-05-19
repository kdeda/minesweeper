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
    
    private func indexIsValid(_ row: Int, _ col: Int) -> Bool {
        row >= 0 && row < rows && col >= 0 && col  < cols
    }
    
    subscript(_ row: Int, _ col: Int) -> T {
        get {
            assert(indexIsValid(row, col))
            return entries[row][col]
        }
        set(newValue) {
            assert(indexIsValid(row, col))
            entries[row][col] = newValue
        }
    }
    subscript(_ cell: GridCellState) -> T {
        get {
            assert(indexIsValid(cell.row, cell.col))
            return entries[cell.row][cell.col]
        }
        set(newValue) {
            assert(indexIsValid(cell.row, cell.col))
            entries[cell.row][cell.col] = newValue
        }
    }
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
        return Matrix<V>(rows, cols, transform)
    }
}
