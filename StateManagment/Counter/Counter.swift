//
//  Counter.swift
//  Counter
//
//  Created by Timur Asayonok on 29/06/2022.
//

// Actions
public enum CounterAction {
    case decrTapped
    case incrTapped
}

public struct CounterState {
    public let count: Int
    public let favoritePrimes: [Int]
    
    public init(count: Int, favoritePrimes: [Int]) {
        self.count = count
        self.favoritePrimes = favoritePrimes
    }
}

// counter reducer
public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped: state -= 1
    case .incrTapped: state += 1
    }
}
