//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Timur Asayonok on 29/06/2022.
//

// Actions
public enum FavoritePrimesAction {
    case deleteFavoritePrime(IndexSet)
}

public struct FavoritePrimesState {
    public let favoritePrimes: [Int]
    
    public init(favoritePrimes: [Int]) {
        self.favoritePrimes = favoritePrimes
    }
}

// favoritePtime reducer
public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrime(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}
