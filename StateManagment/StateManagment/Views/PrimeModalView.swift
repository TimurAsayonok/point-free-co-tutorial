//
//  PrimeModalView.swift
//  StateManagment
//
//  Created by Timur Asayonok on 07/07/2022.
//

import SwiftUI
import Combine
import ComposableArchitecture
import PrimeModal

struct PrimeModalView: View {
    @ObservedObject var store: Store<PrimeModalState, AppAction>
    
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
