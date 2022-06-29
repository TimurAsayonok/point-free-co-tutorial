//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Timur Asayonok on 29/06/2022.
//

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
