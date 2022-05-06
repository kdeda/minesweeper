//
//  Grid+Model.swift
//  MineSweeper
//
//  Created by Klajd Deda on 5/6/22.
//

import Foundation
import SwiftUI

struct GridCell: Equatable {
    static let viewSize: CGFloat = 24
    
    var row: Int
    var column: Int
    var rotation: CGFloat = 0.0
    var color = Color.gray
}

extension GridCell: CustomStringConvertible {
    var description: String {
        let rowColumn = String(format: "[%2d, %2d]", row, column)
        return "\(rowColumn), rotation: \(rotation), color: \(color)"
    }
}

extension GridCell: Identifiable {
    var id: Int {
        row  * 1_000_000 + column
    }
}

struct Matrix: Equatable {
    var rows: Int
    var columns: Int
    
    init(_ rows: Int, _ columns: Int) {
        self.rows = rows
        self.columns = columns
    }
}

extension Matrix {
    func forEach(_ transform: (_ row: Int, _ column: Int) -> ()) {
        (0 ..< rows).forEach { row in
            (0 ..< columns).forEach { column in
                transform(row, column)
            }
        }
    }
    
    func map<T>(_ transform: (_ row: Int, _ column: Int) -> (T)) -> [[T]] {
        (0 ..< rows).map { row in
            (0 ..< columns).map { column in
                transform(row, column)
            }
        }
    }
}
