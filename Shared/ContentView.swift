//
//  ContentView.swift
//  MineSweeper
//
//  Created by Klajd Deda on 6/30/21.
//
//  Read on:  https://levelup.gitconnected.com/swiftui-minesweeper-cd145f888343
//

import SwiftUI
import Combine

final class Cell: ObservableObject {
    var row: Int
    var column: Int
    @Published var rotation: CGFloat = 0.0
    @Published var color = Color.gray

    init(row: Int,
         column: Int,
         rotation: CGFloat = 0.0,
         color: Color = .gray
    ) {
        self.row = row
        self.column = column
        self.rotation = rotation
        self.color = color
    }
}

extension Cell: CustomStringConvertible {
    var description: String {
        let rowColumn = String(format: "[%2d, %2d]", row, column)
        return "\(rowColumn), rotation: \(rotation), color: \(color)"
    }
}

extension Cell: Identifiable {
    var id: Int {
        row  * 1000 + column
    }
}

fileprivate extension Array where Element == Cell {
    func animateChanges(fps: Int = 30, _ cellChange: @escaping (Cell) -> Void) -> AnyCancellable {
        let publisher = self
            .publisher
            .zip(Timer.publish(every: 1.0 / Double(fps), on: RunLoop.main, in: .common).autoconnect())
            .map { cell, _ in
                cell
            }
            .sink(receiveValue: { cell in
                // NSLog("row: \(cell.row), column: \(cell.column)")
                cellChange(cell)
            })
        return publisher
    }
}

final class GridViewModel: ObservableObject {
    static var rows = 5
    static var columns = 7
    static var cellSize: CGFloat = 32

    @Published var cells: [[Cell]] = [[Cell]]()
    var cancellables = Set<AnyCancellable>()

    init() {
        let newCells = (0 ..< Self.rows).map { row in
            (0 ..< Self.columns).map { column in
                Cell(row: row, column: column)
            }
        }
        self.cells = newCells
    }
    
    
    // cancel all work and reset all
    func reset() {
        cancellables.forEach { $0.cancel() }
        
        self.cells
            .flatMap { $0 }
            .forEach { cell in
                self.cells[cell.row][cell.column].rotation = 0.0
                self.cells[cell.row][cell.column].color = Color.gray
            }
        // self.objectWillChange.send()
    }
    
    // 1) reset all to gray
    // 2) flip the 4 corners
    func flipCorners() {
        reset()

        let cornerCells = cells
            .flatMap { $0 }
            .compactMap { cell -> Cell? in
                let cornerRow = cell.row == 0 || cell.row == Self.rows - 1
                let cornerColumn = cell.column == 0 || cell.column == Self.columns - 1
                
                guard cornerRow && cornerColumn
                else { return nil }
                return cell
            }

        cornerCells.animateChanges(fps: 30) { cell in
            self.cells[cell.row][cell.column].rotation += 90.0
            self.cells[cell.row][cell.column].color = Color.yellow
            // self.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    // 1) reset all to gray
    // 2) start at 0.0 and go clockwise
    func clockWise() {
        reset()

        var currentMove = Move(minRows: 0, maxRows: Self.rows, minColumns: 0, maxColumns: Self.columns, row: 0, column: 0, direction: .right)
        var orderedCells = [self.cells[currentMove.row][currentMove.column]]
        var working = true
        repeat {
            let newMove = currentMove.nextClockWiseMove

            if newMove.row == 2 && newMove.column == 1 {
                // debug ...
            }
            if currentMove == newMove {
                working = false
            } else {
                orderedCells.append(self.cells[newMove.row][newMove.column])
                currentMove = newMove
            }
        } while working

        orderedCells.animateChanges(fps: 6) { cell in
            self.cells[cell.row][cell.column].rotation += 90.0
            self.cells[cell.row][cell.column].color = Color.yellow
        }
        .store(in: &cancellables)
    }
}

struct CellView: View {
    @ObservedObject var cell: Cell
    @State private var rotation: CGFloat = 0.0
    @State private var cellSize: CGFloat = GridViewModel.cellSize
    @State private var cornerRadius: CGFloat = 0.0

    init(cell: Cell) {
        self.cell = cell
        // start with the current cell rotation
        self.rotation = cell.rotation
    }
    
    var body: some View {
        // NSLog("row: \(cell.row), column: \(cell.column)")
        // NSLog("rotation: \(rotation), cell: \(cell)")
        //    if cell.row == 2 && cell.column == 2 {
        //        NSLog("body rotation: \(rotation), cell: \(cell)")
        //    }
        return ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
            // .frame(width: size, height: size)
                .background(cell.color)
                .rotationEffect(.degrees(rotation))
                .onChange(of: cell.rotation) { newValue in
                    // since the cell is Observed
                    // as soon as it changes we hit this
                    // at which case we store the new cell.rotation
                    // we can go from 0 -> 90 or upon reset from 90 -> 0
                    // this adds a cute anim
                    // further more
                    // one or many of the cell state can be changed by the GridViewModel
                    // and than each cell view will animate
                    
                    if cell.rotation != 0 {
                        // we want to animate the rotation and size
                        self.rotation = 0.0
                        self.cellSize = 4
                        self.cornerRadius = 9.0
                    }
                    withAnimation(.linear(duration: 0.25).repeatCount(1, autoreverses: false)) {
                        // NSLog("row: \(cell.row), column: \(cell.column), self.rotation: \(self.rotation), cell.rotation: \(cell.rotation)")
                        self.rotation = 360.0
                        self.cellSize = GridViewModel.cellSize
                        self.cornerRadius = 9.0
                    }
                    withAnimation(.easeOut(duration: 0.125).delay(0.25)) {
                        // self.rotation = 0.0
                        self.cellSize = GridViewModel.cellSize
                        self.cornerRadius = 0.0
                    }
                }
            // .cornerRadius(cornerRadius)
            
            Text("\(cell.row),\(cell.column)")
                .foregroundColor(.secondary)
        }
        .frame(width: GridViewModel.cellSize, height: GridViewModel.cellSize)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = GridViewModel()
    
    var body: some View {
        // NSLog("body")
        return VStack {
            HStack(spacing: 12) {
                Spacer()
                Button(action: {
                    withAnimation {
                        viewModel.clockWise()
                    }
                }, label: {
                    Text("Clock Wise")
                })
                Divider()
                    .frame(height: 12)
                Button(action: {
                    withAnimation {
                        viewModel.flipCorners()
                    }
                }, label: {
                    Text("Flip Corners")
                })
                Divider()
                    .frame(height: 12)
                Button(action: {
                    withAnimation {
                        viewModel.reset()
                    }
                }, label: {
                    Text("Reset")
                })
            }
            .padding()
            .background(Color.init(white: 0.96))

            Spacer()

            VStack(spacing: 1) {
                ForEach(0 ..< GridViewModel.rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0 ..< GridViewModel.columns, id: \.self) { column in
                            CellView(cell: self.viewModel.cells[row][column])
                        }
                    }
                }
            }
            .drawingGroup()
            .padding()
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
