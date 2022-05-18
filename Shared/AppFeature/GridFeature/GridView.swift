import SwiftUI
import ComposableArchitecture

struct GridView: View {
    let store: Store<GridState, GridAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 1) {
                VStack(spacing: 1) {
                    Text("\(viewStore.cells.rows) by \(viewStore.cells.cols)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 6)
                    
                    ForEach(0 ..< viewStore.cells.rows, id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(0 ..< viewStore.cells.cols, id: \.self) { column in
                                GridCellView(cell: viewStore.cells.at(row, column))
                            }
                        }
                    }
                    
                    HStack(spacing: 2) {
                        Text(Image(systemName: "checkmark.circle.fill"))
                            .font(.caption)
                            .fontWeight(.bold)
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
        self.rotation = cell.rotation // Start with currentt cell rotation.
    }
    
    var body: some View {
        return ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .background(cell.color)
                .rotationEffect(.degrees(rotation))
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
            .environment(\.colorScheme, .light)
    }
}

