import SwiftUI
import ComposableArchitecture

struct GridView: View {
    let store: Store<GridState, GridAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 1) {
                Text("\(viewStore.cells.rows) by \(viewStore.cells.cols)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 6)
                
                // TODO: Figure this out. Need identified array of?
                ForEach(0 ..< viewStore.cells.rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEachStore(self.store.scope(
                            state: \.cells.entries[row],
                            action: GridAction.cell
                        )) { childStore in
                            GridCellView(store: childStore)
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
            .drawingGroup() // TODO: Why use this?
            .padding(.all, 6)
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(store: GridState.mockStore)
            .environment(\.colorScheme, .light)
    }
}
