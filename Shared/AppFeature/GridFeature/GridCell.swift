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
