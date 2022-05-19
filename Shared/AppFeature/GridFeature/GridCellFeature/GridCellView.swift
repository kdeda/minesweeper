import SwiftUI
import ComposableArchitecture

struct GridCellView: View {
    let store: Store<GridCellState, GridCellAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Rectangle()
                .fill(Color.clear)
                .frame(width: GridCellState.viewSize, height: GridCellState.viewSize)
                .background(viewStore.color)
                .rotationEffect(.degrees(viewStore.rotation))
        }
        .frame(width: GridCellState.viewSize, height: GridCellState.viewSize)
    }
}

struct GridCellView_Previews: PreviewProvider {
    static var previews: some View {
        GridCellView(store: GridCellState.mockStore)
    }
}
