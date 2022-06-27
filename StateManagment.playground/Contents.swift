import SwiftUI

private func ordinal(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: number) ?? ""
}

private func isPrime(_ number: Int) -> Bool {
    if number <= 1 { return false }
    if number <= 3 { return true }
    for index in 2...Int(sqrtf(Float(number))) {
        if number % index == 0 { return false }
    }
    
    return true
}

struct WolframAlphaResponse: Decodable {
    let queryresult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPods]
            
            struct SubPods: Decodable {
                let plaintext: String
            }
        }
    }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResponse?) -> Void) -> Void {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: "6H69Q3-828TKQJ4EP")
    ]
    
    URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
        callback(data.flatMap{ try? JSONDecoder().decode(WolframAlphaResponse.self, from: $0) })
    }.resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
    wolframAlpha(query: "prime \(n)") { result in
        callback(
            result.flatMap{
                $0.queryresult
                    .pods
                    .first(where: { $0.primary == .some(true) })?
                    .subpods
                    .first?
                    .plaintext
            }
            .flatMap(Int.init)
        )
    }
}

struct PrimeValue: Identifiable {
    var id: Int { value }
    let value: Int
}

// TODO: BindableObject - check (ObservableObject)
import Combine

// AppState like a class in first videos

//    class AppState: ObservableObject {
//        // this is old boilerplate, in old swiftUI, nice to know
//        // right now we can use @Published instead.
//        //    let objectWillChange = PassthroughSubject<Void, Never>()
//
//        //    var count = 0 {
//        //        willSet { self.objectWillChange.send(()) }
//        //    }
//        //    var favoritePrimes: [Int] = [] {
//        //        willSet { self.objectWillChange.send(()) }
//        //    }
//
//        @Published var count = 0
//        @Published var favoritePrimes: [Int] = []
//        @Published var loggedInUser: User?
//        @Published var activityFeed: [Activity] = []
//
//        struct Activity {
//            let timestamp: Date
//            let type: ActivityType
//
//            enum ActivityType {
//                case addedFavoritePrime(Int)
//                case removedFavoritePrime(Int)
//            }
//        }
//
//        struct User {
//            let id: Int
//            let name: String
//            let bio: String
//        }
//    }

// MARK: - STATE
// AppState as a struct
struct AppState {
    var count = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []

    struct Activity {
        let timestamp: Date
        let type: ActivityType

        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }

    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

//struct FavoritePrimeState {
//    var favoritePrimes: [Int] = []
//    var activityFeed: [AppState.Activity] = []
//}

//extension AppState {
//    var favoritePrimesState: [FavoritePrimeState] {
//        get {
//            return FavoritePrimeState(
//                favoritePrimes: self.favoritePrimes, activityFeed: self.activityFeed
//            )
//        }
//        set {
//            self.favoritePrimes = newValue.favoritePrimes
//            self.activityFeed = newValue.activityFeed
//        }
//    }
//}


// Actions
enum CounterAction {
    case decrTapped
    case incrTapped
}

enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

enum FavoritePrimesAction {
    case deleteFavoritePrime(IndexSet)
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrime(FavoritePrimesAction)
    
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil}
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
    
    var favoritePrime: FavoritePrimesAction? {
        get {
            guard case let .favoritePrime(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrime = self, let newValue = newValue else { return }
            self = .favoritePrime(newValue)
        }
    }
}

/*
 reducer name because it looks like method .reduce
 [1, 2, 3].reduce(
   <#initialResult: Result#>,
   <#nextPartialResult: (Result, Int) throws -> Result#>
 )
 */

/*
 counterReducer function only represents one single mutation at a time,
 and it takes you from one state to the next state
 */


/*
 rewriting with `inout`
 
 (A) -> A == (inout A) -> Void
 (A, B) -> (A, C) == (inout A, B) -> (C)
 
 (Value, Action) -> Value ~> (inout Value, Action) -> Void
 в случае слева мы возвращает новую переменую типа Value
 в случае справа мы изменяем непосредственно передаваемую переменную типа Value
 */

//func counterReducer(state: inout AppState, action: CounterAction) {
//    switch action {
//    case .decrTapped: state.count -= 1
//    case .incrTapped: state.count += 1
//    }
//}


// old version of appReducer with all Actions inside.
//func appReducer(state: inout AppState, action: AppAction) {
//    switch action {
//    case .counter(.decrTapped): state.count -= 1
//    case .counter(.incrTapped): state.count += 1
//    case .primeModal(.saveFavoritePrimeTapped):
//        state.favoritePrimes.append(state.count)
//        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
//    case .primeModal(.removeFavoritePrimeTapped):
//        state.favoritePrimes.removeAll(where: { $0 == state.count })
//        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
//    case let .favoritePrime(.deleteFavoritePrime(indexSet)):
//        for index in indexSet {
//            let prime = state.favoritePrimes[index]
//            state.favoritePrimes.remove(at: index)
//            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
//        }
//    }
//}

// MARK: - new reducer, handler reducers using combine method

// counter reducer
func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped: state -= 1
    case .incrTapped: state += 1
    }
}

// prime reducer
func primeModalReducer(state: inout AppState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)
        
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
    }
}

// favoritePtime reducer
func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrime(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}



// MARK: - STORE

/// Combine method:  combine 2 reducers
/// second reducer will use value that was changed in first reducer
func combine<Value, Action>(
    _ first: @escaping (inout Value, Action) -> Void,
    _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    return { value, action in
        first(&value, action)
        second(&value, action)
    }
}

/// Combine method: combine list of reducers
/// will work the same like Combine method for 2 reducers
func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

/// Pullback method:
/// we want to take a reducer on a small piece of substate and transform it into a reducer that works on global state, of which the substate embeds inside it.
/// `Function` that can transform a reducer on local state into one on global state
///
/// problem of this func that GlobalValue won't be changed back
func pullback<LocalValue, GlobalValue, Action>(
    _ reducer: @escaping(inout LocalValue, Action) -> Void,
    _ f: @escaping(GlobalValue) -> LocalValue
) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        var localValue = f(globalValue)
        reducer(&localValue, action)
    }
}

/// Pullback method,
///  will get local value from global value and will put to reducer,
///  after reducer this method will set local value to global value back
func pullback<LocalValue, GlobalValue, Action> (
    _ reducer: @escaping (inout LocalValue, Action) -> Void,
    get: @escaping(GlobalValue) -> LocalValue,
    set: @escaping(inout GlobalValue, LocalValue) -> Void
) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        var localValue = get(globalValue)
        reducer(&localValue, action)
        set(&globalValue, localValue)
    }
}
// pullback(counterReducer, get: { $0.count }, set: { $0.count = $1 }),

/// Pullback methond.
/// we will use KeyPath from Swift
func pullback<LocalValue, GlobalValue, Action>(
    _ reducer: @escaping (inout LocalValue, Action) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        reducer(&globalValue[keyPath: value], action)
    }
}


/// Pullback method
/// we will use KeyPath for Pullback Actions
func pullback<Value, GlobalAction, LocalAction>(
    _ reducer: @escaping (inout Value, LocalAction) -> Void,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout Value, GlobalAction) -> Void {
    return { value, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&value, localAction)
    }
}

/// END!!
/// Main Pullback Method with GlobalState and GlobalAction to work with local state and local action
func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], localAction)
    }
}

// MARK: - Hight Order Reducers

func activityFeed(
    _ reducer: @escaping(inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counter(_): break
        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(
                .init(
                    timestamp: Date(),
                    type: .removedFavoritePrime(state.count)
                )
            )
        case .primeModal(.saveFavoritePrimeTapped):
            state.activityFeed.append(
                .init(
                    timestamp: Date(),
                    type: .addedFavoritePrime(state.count)
                )
            )
            
        case let .favoritePrime(.deleteFavoritePrime(indexSet)):
            for index in indexSet {
                state.activityFeed.append(
                    .init(
                        timestamp: Date(),
                        type: .removedFavoritePrime(state.favoritePrimes[index])
                    )
                )
            }
        }
        // do something
        reducer(&state, action)
    }
}


/// Logging Method
/// takes reducer and print action and state as a log
func logging(
    _ reducer: @escaping(inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { value, action in
        reducer(&value, action)
        print("Action: \(action)")
        print("State: ", value)
        dump(value)
        print("---")
    }
}

func filterActions<Value, Action>(_ predicate: @escaping (Action) -> Bool)
  -> (@escaping (inout Value, Action) -> Void)
  -> (inout Value, Action) -> Void {
      return { reducer in
          return { state, action in
              if predicate(action) {
                  reducer(&state, action)
              }
          }
      }
}

// Undo action
struct UndoState<Value> {
    var value: Value
    var history: [Value]
    var undone: [Value]
    var canUndo: Bool { !history.isEmpty }
    var canRedo: Bool { !history.isEmpty }
}

enum UndoAction<Action> {
    case action(Action)
    case undo
    case redo
}

func undo<Value, Action>(
    _ reducer: @escaping(inout Value, Action) -> Void,
    limit: Int
) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
    return { undoState, undoAction in
        switch undoAction {
        case let .action(action):
            var currentState = undoState.value
            reducer(&currentState, action)
            undoState.history.append(currentState)
            undoState.undone = []
            
            if undoState.history.count < limit {
                undoState.history.removeFirst()
            }
        case .undo:
            guard undoState.canUndo else { return }
            undoState.undone.append(undoState.value)
            undoState.value = undoState.history.removeLast()
        case .redo:
            guard undoState.canRedo else { return }
            undoState.history.append(undoState.value)
            undoState.value = undoState.undone.removeFirst()
            
        }
    }
}


// pullback(counterReducer, value: \.count)
//like a setter
//print(AppAction.counter(CounterAction.incrTapped))
//// like a getter
////let action = AppAction.favoritePrime(.deleteFavoritePrime([1]))
//let action = AppAction.counter(.incrTapped)
//let favoritePrimesAction: FavoritePrimesAction?
//
//switch action {
//case let .favoritePrime(action):
//    favoritePrimesAction = action
//default: favoritePrimesAction = nil
//}
//print(favoritePrimesAction)

/// new way of getting value from enums
//let action = AppAction.counter(.incrTapped)
//action.counter
//action.favoritePrime
//\AppAction.counter

//var appReducer = combine(counterReducer, primeModalReducer)
let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.self, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrime)
)

let appReducer = logging(_appReducer)

/*
 Now if we form something like:

 Store<AppState>
 
 We will get an observable object that notifies that something changed as soon as any mutation is made to `AppState`.
 And doing that we will see changes for all struct not just for one property
 
 Better to rename Value to the State!
 */
final class Store<Value, Action>: ObservableObject {
    let reducer: (inout Value, Action) -> Void
    @Published private(set) var value: Value
    
    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.reducer = reducer
        self.value = initialValue
    }
    
    func send(_ action: Action) {
        reducer(&value, action)
    }
}

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Counter Demo") {
                    CounterView(store: self.store)
                        .navigationTitle(Text("Counter demo"))
                }
                NavigationLink("Favorite Primes") {
                    FavoritePrimesView(store: self.store)
                        .navigationTitle(Text("Favorite Primes"))
                }
            }
            .navigationTitle(Text("State Managment"))
        }
    }
}

struct CounterView: View {
    // state
    // view will be rerendered when state was changed.
    // TODO: check property wrapper
    // @State var count: Int = 0
    
    // TODO: check @ObjectBinding -> @ObservedObject
    @ObservedObject var store: Store<AppState, AppAction>
    
    // added in 2nd video
    @State var isPrimeModalShown = false
    @State var alertNthPrime: PrimeValue?
    @State var isNthPrimeButtonDisabled = false
    
    var body: some View {
        VStack {
            HStack {
                Button("-") {
                    /*
                     last version
                     */
                    
                    self.store.send(.counter(.decrTapped))
                    
                    /*
                     how it was before
                     */
                    //self.store.value = counterReducer(state: self.store.value, action: .decrTapped)
                    //self.store.value.count -= 1
                }
                Text("\(self.store.value.count)")
                Button("+") {
                    self.store.send(.counter(.incrTapped))
                    // self.store.value.count += 1
                }
            }
            Button(action: { self.isPrimeModalShown = true }) {
                Text("Is this Prime?")
            }
            Button(action: self.nthPrimeButtonAction) {
                Text("What is the \(ordinal(self.store.value.count)) prime?")
            }
            .disabled(self.isNthPrimeButtonDisabled)
        }
        .font(.title2)
        .sheet(
            isPresented: $isPrimeModalShown,
            onDismiss: { self.isPrimeModalShown = false }
        ) {
            PrimeModalView(store: self.store)
        }
        .alert(item: $alertNthPrime) { number in
            Alert(title: Text("The \(ordinal(self.store.value.count)) prime is \(number.value)"), dismissButton: .default(Text("Ok")))
        }
    }
    
    func nthPrimeButtonAction() {
        isNthPrimeButtonDisabled = true
        nthPrime(store.value.count) { prime in
            guard let prime = prime else { return }
            alertNthPrime = .init(value: prime)
            isNthPrimeButtonDisabled = false
        }
    }
}

struct PrimeModalView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        VStack {
            if isPrime(self.store.value.count) {
                Text("\(self.store.value.count) is prime =)")
                
                if self.store.value.favoritePrimes.contains(self.store.value.count) {
                    Button("Remove from favorite primes") {
                        store.send(.primeModal(.removeFavoritePrimeTapped))
                    }
                } else {
                    Button("Add to favorite primes") {
                        store.send(.primeModal(.saveFavoritePrimeTapped))
                    }
                }
            } else {
                Text("\(self.store.value.count) is not prime =(")
            }
        }

    }
}

struct FavoritePrimesView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        List {
            ForEach(store.value.favoritePrimes, id: \.self) { number in Text("\(number)") }
            .onDelete { indexSet in store.send(.favoritePrime(.deleteFavoritePrime(indexSet))) }
        }
    }
}

import PlaygroundSupport
// init AppState
PlaygroundPage.current.liveView = UIHostingController(
    rootView: ContentView(
        store: Store(
            initialValue: AppState(),
            reducer: activityFeed(appReducer)
        )
    )
)

