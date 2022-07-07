//
//  CounterView.swift
//  StateManagment
//
//  Created by Timur Asayonok on 07/07/2022.
//

import SwiftUI
import ComposableArchitecture
import Counter

struct CounterView: View {
    // state
    // view will be rerendered when state was changed.
    // TODO: check property wrapper
    // @State var count: Int = 0
    
    // TODO: check @ObjectBinding -> @ObservedObject
    @ObservedObject var store: Store<CounterState, AppAction>
    
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
            PrimeModalView(store: self.store.view {
                .init(count: $0.count, favoritePrimes: $0.favoritePrimes)
            })
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
