//
//  
//  FriendsReducer.swift
//  Kem
//
//  Created by Павел Мальков on 04.06.2024.
//
//
import ReSwift

extension ReducerContainer {
    static let FriendsReducer: Reducer<FriendsState> = { action, state in
        var state = state ?? FriendsState()
        guard let action = action as? FriendsAction else { return state }
        
        switch action {
        case .clean:
            state.clean()
        }
        return state
    }
}

