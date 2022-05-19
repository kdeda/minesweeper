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
                            get: { gridState in
                                gridState.fps
                            },
                            send: { localState in
                                GridAction.updateFPS(localState)
                            }
                        ),
                        in: 3.0 ... 120.0, step: 3) { // TODO: Move this... bindable state....
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

//// key paths
//struct Person {
//  var name: String
//  var age: Int
//
//  func getFooBar(_ string: String) -> (_ int: Int) -> Int {
//    return { intValue in
//      return 22
//    }
//  }
//
////  static func getAge(_ instance: Person) -> Int {
////    return instance.getAge()
////  }
//}
//
//struct Test {
//  func test() {
//    var me = Person(name: "Jesse", age: 22)
//    let age1 = me.age
//    let kp1 = \Person.age
//    let age2 = me[keyPath: kp1]
//    let age3 = kp1(me)
//
//    let kpName = \Person.name.count
//    let kp2 = Person.getFooBar
//    let fookp2 = kp2(me)
//    let fookp21 = me.getFooBar
//    let fookp3 = fookp2("foo")
//    let fookp4 = fookp3(123)
//
//    let kp3 = Person.getAge(me)("123")(123)
//
////    let age2 = Person.age(me)
////
////    Person.age(me, newValue)
////
////    let kv1 = Person.age
////    let age3 = me.kv
//
//  }
//}


struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: GridState.mockStore)
            .environment(\.colorScheme, .light)
    }
}

