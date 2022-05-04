//
//  ContentView.swift
//  MineSweeper
//
//  Created by Klajd Deda on 6/30/21.
//

import SwiftUI
import Combine

struct CellV1: Hashable {
    var row: Int
    var column: Int
    var rotation: CGFloat = 0.0
    var color = Color.gray
}

extension CellV1: Identifiable {
    var id: Int {
        row  * 1000 + column
    }
}

struct CellViewV1: View {
    var size: CGFloat = 32
    var cell: CellV1
    @State private var rotation = 0.0

    init(cell: CellV1) {
        self.cell = cell
        self.rotation = cell.rotation
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: size, height: size)
            .background(cell.color)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation {
                    self.rotation = cell.rotation
                }
            }
    }
}

final class GridViewModelV1: ObservableObject {
    var rows = 6
    var colums = 6
    @Published var cells: [[CellV1]] = [[CellV1]]()
    var cancellables = Set<AnyCancellable>()

    init() {
        let newCells = (0 ..< rows)
            .map { row in
                (0 ..< colums).map { column in
                    CellV1(row: row, column: column)
                }
            }
        self.cells = newCells
    }
    
    // start a publisher that changes the cells
    func startAnimation() {
        cancellables.forEach { $0.cancel() }
        
        (0 ..< rows)
            .map { row in
                (0 ..< colums).map { column in
                    self.cells[row][column].rotation = 0.0
                    self.cells[row][column].color = Color.gray
                }
            }
        
        let foo = (0 ..< rows)
            .map { row in
                (0 ..< colums).map { column in
                    (row: row, column: column)
                }
            }
            .flatMap { $0 }
            .sorted(by: { lhs, rhs in
                lhs.column < rhs.column
            })
            // .shuffled()
            .publisher
            .zip(Timer.publish(every: 0.333, on: RunLoop.main, in: .common).autoconnect())
            .map { rowColumn, _ in
                rowColumn
            }
            .sink(receiveValue: { rowColumn in
                let row = rowColumn.row
                let column = rowColumn.column
                // var newCells = self.cells

                // NSLog("row: \(row), column: \(column)")
                var newCell = self.cells[row][column]

                newCell.rotation = 90
                newCell.color = Color.yellow
                self.cells[row][column] = newCell
                NSLog("row: \(row), column: \(column) cell: \(self.cells[row][column])")
                // self.cells = newCells
            })
            .store(in: &cancellables)
    }
}

struct ContentViewV1: View {
    @ObservedObject var viewModel = GridViewModelV1()
    
    var body: some View {
        NSLog("body")
        return VStack {
            VStack(spacing: 2) {
                ForEach(self.viewModel.cells, id: \.self) { rows in
                    HStack(spacing: 2) {
                        ForEach(rows) { cell in
                            CellViewV1(cell: cell)
                        }
                    }
                }
            }
            .padding()
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        viewModel.startAnimation()
                    }
                }, label: {
                    Text("Start")
                })
            }
            .padding()
        }
    }
}

struct ContentViewV1_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewV1()
    }
}
