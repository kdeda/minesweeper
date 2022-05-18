import SwiftUI
import ComposableArchitecture

struct AppView: View {
  let store: Store<GridState, GridAction>
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 1) {
        HStack(spacing: 12) {
          Spacer()
          Button(action: {
            withAnimation {
              viewStore.send(.clockWise)
            }
          }, label: {
            Text("Clock Wise")
          })
          Divider()
            .frame(height: 12)
          Button(action: {
            withAnimation {
              viewStore.send(.flipCorners)
            }
          }, label: {
            Text("Flip Corners")
          })
          Divider()
            .frame(height: 12)
          Button(action: {
            withAnimation {
              viewStore.send(.reset)
            }
          }, label: {
            Text("Reset")
          })
        }
        .padding()
        .background(Color.init(white: 0.96))
        Divider()
        
        VStack(spacing: 4) {
          HStack(spacing: 0) {
            Text("Render frames per second: \(Int(viewStore.fps))")
          }
          Slider(
            value: viewStore.binding(
              get: { GridState in
                GridState.fps
              },
              send: GridAction.updateFPS), // TODO: Where is this value coming from? Why don't have I have to give it a double?
            in: 3.0 ... 120.0, step: 3) { // TODO: Move this... bindable state...
              Text("Label") // Where is this displayed ???
            } minimumValueLabel: {
              Image(systemName: "tortoise")
            } maximumValueLabel: {
              Image(systemName: "hare")
            } onEditingChanged: {
              print("\($0)")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
        Divider()
        Spacer()
        GridView(store: store)
        Spacer()
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: GridState.mockStore)
      .environment(\.colorScheme, .light)
  }
}

