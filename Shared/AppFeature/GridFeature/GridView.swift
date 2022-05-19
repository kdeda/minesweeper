import SwiftUI
import ComposableArchitecture

struct GridView: View {
    let store: Store<GridState, GridAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 1) {
                ForEach(0 ..< viewStore.cells.rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0 ..< viewStore.cells.cols, id: \.self) { column in
                            GridCellView(store: self.store.scope(
                                state: \.cells[row, column],
                                action: { GridAction.cell(row: row, col: column, action: $0) }
                            ))
                        }
                    }
                }
            }
            Spacer()
            .frame(height: 12)
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(store: GridState.mockStore)
            .environment(\.colorScheme, .light)
    }
}
