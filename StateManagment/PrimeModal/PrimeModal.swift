//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Timur Asayonok on 29/06/2022.
//

import SwiftUI
import ComposableArchitecture
import Combine

// View
public struct PrimeModalView: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            if isPrime(self.store.value.count) {
                Text("\(self.store.value.count) is prime =)")
                
                if self.store.value.favoritePrimes.contains(self.store.value.count) {
                    Button("Remove from favorite primes") {
                        store.send(.removeFavoritePrimeTapped)
                    }
                } else {
                    Button("Add to favorite primes") {
                        store.send(.saveFavoritePrimeTapped)
                    }
                }
            } else {
                Text("\(self.store.value.count) is not prime =(")
            }
        }

    }
}

// State
public struct PrimeModalState {
    public var count: Int
    public var favoritePrimes: [Int]
    
    public init(count: Int, favoritePrimes: [Int]) {
        self.count = count
        self.favoritePrimes = favoritePrimes
    }
}

// Action
public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

// prime reducer
public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)
        
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
    }
}

func isPrime(_ number: Int) -> Bool {
    if number <= 1 { return false }
    if number <= 3 { return true }
    for index in 2...Int(sqrtf(Float(number))) {
        if number % index == 0 { return false }
    }
    
    return true
}
