import SwiftUI
import ComposableArchitecture

extension View {
    func log(_ logMessage: String) -> EmptyView {
        NSLog(logMessage)
        return EmptyView()
    }
}

struct GridCellView: View {
    let store: Store<GridCellState, GridCellAction>
    @State var rotation: CGFloat = 0
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            log("GridCellView.body state: \(viewStore)")
            
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: GridCellState.viewSize, height: GridCellState.viewSize)
                    .background(viewStore.color)
                    .animation(.linear(duration: 2.0), value: viewStore.color)
                
                    .rotationEffect(.degrees(viewStore.rotation))
                    .animation(.linear(duration: 2.0), value: viewStore.rotation)
                
//                    .onChange(of: viewStore.rotation) { newValue in
//                        log("GridCellView.body rotation: \(viewStore.state)")
//                        log("GridCellView.body rotation: \(self.rotation) cell.rotation: \(viewStore.rotation)")
//                        withAnimation(.linear(duration: 2.0)) {
//                            self.rotation += newValue
//                        }
//                    }
                //                    .onChange(of: viewStore.color) { newValue in
                //                        log("GridCellView.body color: \(viewStore.state)")
                ////                        log("GridCellView.body rotation: \(self.rotation) cell.rotation: \(viewStore.rotation)")
                ////                        withAnimation {
                ////                            self.rotation += newValue
                ////                        }
                //                    }
                
                Text("\(viewStore.row),\(viewStore.col)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(width: GridCellState.viewSize, height: GridCellState.viewSize)
        }
    }
}

struct GridCellView_Previews: PreviewProvider {
    static var previews: some View {
        GridCellView(store: GridCellState.mockStore)
    }
}
