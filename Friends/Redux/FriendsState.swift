//
//  
//  FriendsState.swift
//  Kem
//
//  Created by Павел Мальков on 04.06.2024.
//
//
import Foundation

import GeneratedApi

final class FriendsState : ObservableObject {
    
    @Published var friendsState: AsyncRequestState<[UserShort]> = .none
    @Published var recentFriendsState: AsyncRequestState<[UserShort]> = .none
    @Published var searchFriendsState: AsyncRequestState<[UserShort]> = .none
    @Published var contactsState: AsyncRequestState<[UserShort]> = .none
    
    func clean() {
        friendsState = .none
        recentFriendsState = .none
        searchFriendsState = .none
        contactsState = .none
    }
}

