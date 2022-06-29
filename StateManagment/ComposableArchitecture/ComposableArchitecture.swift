//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Timur Asayonok on 29/06/2022.
//

import Combine
import SwiftUI

/*
 Now if we form something like:

 Store<AppState>
 
 We will get an observable object that notifies that something changed as soon as any mutation is made to `AppState`.
 And doing that we will see changes for all struct not just for one property
 
 Better to rename Value to the State!
 */
public final class Store<Value, Action>: ObservableObject {
    private let reducer: (inout Value, Action) -> Void
    @Published public private(set) var value: Value
    
    public init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.reducer = reducer
        self.value = initialValue
    }
    
    public func send(_ action: Action) {
        reducer(&value, action)
    }
}

// MARK: - STORE
/// Combine method: combine list of reducers
/// will work the same like Combine method for 2 reducers
public func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

/// Pullback method:
/// we want to take a reducer on a small piece of substate and transform it into a reducer that works on global state, of which the substate embeds inside it.
/// `Function` that can transform a reducer on local state into one on global state
///
/// problem of this func that GlobalValue won't be changed back

/// Main Pullback Method with GlobalState and GlobalAction to work with local state and local action
public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], localAction)
    }
}

/// Logging Method
/// takes reducer and print action and state as a log
public func logging<AppState, AppAction>(
    _ reducer: @escaping(inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { value, action in
        reducer(&value, action)
        print("Action: \(action)")
        print("State: ", value)
        dump(value)
        print("---")
    }
}
