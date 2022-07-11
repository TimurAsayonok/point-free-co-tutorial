//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Timur Asayonok on 29/06/2022.
//

import SwiftUI
import Combine
import ComposableArchitecture

// View
public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(store.value, id: \.self) { number in Text("\(number)") }
            .onDelete { indexSet in store.send(.deleteFavoritePrime(indexSet)) }
        }
    }
}

// Actions
public enum FavoritePrimesAction {
    case deleteFavoritePrime(IndexSet)
}

// State
//public struct FavoritePrimesState {
//    public var favoritePrimes: [Int]
//    
//    public init(favoritePrimes: [Int]) {
//        self.favoritePrimes = favoritePrimes
//    }
//}

// Reducer
public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrime(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}
