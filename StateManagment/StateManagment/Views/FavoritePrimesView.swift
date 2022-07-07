//
//  FavoritePrimesView.swift
//  StateManagment
//
//  Created by Timur Asayonok on 07/07/2022.
//

import SwiftUI
import Combine
import FavoritePrimes
import ComposableArchitecture

struct FavoritePrimesView: View {
    @ObservedObject var store: Store<FavoritePrimesState, AppAction>
    
    var body: some View {
        List {
            ForEach(store.value.favoritePrimes, id: \.self) { number in Text("\(number)") }
            .onDelete { indexSet in store.send(.favoritePrime(.deleteFavoritePrime(indexSet))) }
        }
    }
}
