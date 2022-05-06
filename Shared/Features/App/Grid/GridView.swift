//
//  GRidView.swift
//  MineSweeper
//
//  Created by Klajd Deda on 5/6/22.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct GridView: View {
    let store: Store<GridState, GridAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 1) {
                VStack(spacing: 1) {
                    Text("\(viewStore.rows) by \(viewStore.columns)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 6)
                    
                    ForEach(0 ..< viewStore.cells.count, id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(0 ..< viewStore.cells[row].count, id: \.self) { column in
                                GridCellView(cell: viewStore.cells[row][column])
                            }
                        }
                    }
                    
                    HStack(spacing: 2) {
                        Text(Image(systemName: "checkmark.circle.fill"))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(viewStore.clockWiseError.isEmpty ? Color.green : Color.red)
                        Text(viewStore.clockWiseError.isEmpty ? "Passed" : "\(viewStore.clockWiseError)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(viewStore.clockWiseError.isEmpty ? Color.green : Color.red)
                    }
                    .padding(.top, 6)
                }
            }
            .drawingGroup()
            .padding(.all, 6)
            .border(Color.gray)
        }
    }
}

struct GridCellView: View {
    var cell: GridCell
    @State private var rotation: CGFloat = 0.0
    @State private var cellSize: CGFloat = GridCell.viewSize
    @State private var cornerRadius: CGFloat = 0.0

    init(cell: GridCell) {
        self.cell = cell
        // start with the current cell rotation
        self.rotation = cell.rotation
    }

    var body: some View {
        return ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .background(cell.color)
                .rotationEffect(.degrees(rotation))
//                .onChange(of: cell.rotation) { newValue in
//                    // since the cell is Observed
//                    // as soon as it changes we hit this
//                    // at which case we store the new cell.rotation
//                    // we can go from 0 -> 90 or upon reset from 90 -> 0
//                    // this adds a cute anim
//                    // further more
//                    // one or many of the cell state can be changed by the GridViewModel
//                    // and than each cell view will animate
//
//                    if cell.rotation != 0 {
//                        // we want to animate the rotation and size
//                        self.rotation = 0.0
//                        self.cellSize = 4
//                        self.cornerRadius = 9.0
//                    }
//                    withAnimation(.linear(duration: 0.25).repeatCount(1, autoreverses: false)) {
//                        // NSLog("row: \(cell.row), column: \(cell.column), self.rotation: \(self.rotation), cell.rotation: \(cell.rotation)")
//                        self.rotation = 360.0
//                        self.cellSize = GridViewModel.cellSize
//                        self.cornerRadius = 9.0
//                    }
//                    withAnimation(.easeOut(duration: 0.125).delay(0.25)) {
//                        // self.rotation = 0.0
//                        self.cellSize = GridViewModel.cellSize
//                        self.cornerRadius = 0.0
//                    }
//                }
            
            Text("\(cell.row),\(cell.column)")
                .font(.caption2)
                .foregroundColor(.white)
        }
        .frame(width: GridCell.viewSize, height: GridCell.viewSize)
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(store: GridState.mockStore)
//            .background(Color(NSColor.windowBackgroundColor))
            .environment(\.colorScheme, .light)
//        GridView(store: GridState.defaultStore)
////            .background(Color(NSColor.windowBackgroundColor))
//            .environment(\.colorScheme, .dark)
    }
}
