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

// counter reducer
public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped: state -= 1
    case .incrTapped: state += 1
    }
}
