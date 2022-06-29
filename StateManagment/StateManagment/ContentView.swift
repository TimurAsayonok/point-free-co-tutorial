//
//  ContentView.swift
//  StateManagment
//
//  Created by Timur Asayonok on 28/06/2022.
//

import Combine
import ComposableArchitecture
import FavoritePrimes
import Counter
import PrimeModal
import SwiftUI

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

extension AppState {
    var primeModal: PrimeModalState {
        get {
            .init(count: self.count, favoritePrimes: self.favoritePrimes)
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
        }
    }
}

// Actions
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

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrime)
)

let appReducer = logging(_appReducer)



// MARK: - View

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
                Button("-") { self.store.send(.counter(.decrTapped)) }
                
                Text("\(self.store.value.count)")
                
                Button("+") { self.store.send(.counter(.incrTapped)) }
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
