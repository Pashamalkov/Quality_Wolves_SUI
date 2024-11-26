//
//  GetFriends+Thnk.swift
//  Kem
//
//  Created by Павел Мальков on 15.04.2023.
//

import Foundation

import GeneratedApi

extension FriendsAction {
    
    private static let numbersPattern = "0123456789"
    
    static var getFriends = AsyncThunkWithResolver<AppState> { dispatch, getState, resolver in
        guard
            let state = getState()?.mainState.friendsState,
            let mainState = getState()?.mainState,
            let networkService = resolver.resolve(NetworkServiceProtocol.self),
            mainState.isUser
        else {
            return
        }

        let userId = mainState.session.user.userId
        
        state.friendsState = .loading
        
        let request = GeneratedApi.Identity.GetFriendsV1.Request(userId: userId)
        let result = await networkService.request(request)
        
        parseResult(result) { successValue in
            state.friendsState = .success(successValue.users)
        } onError: { errorMessage in
            state.friendsState = .error(errorMessage)
            dispatch(MainAction.showError(errorMessage))
        }
    }
    
    static var getRecentFriends = AsyncThunkWithResolver<AppState> { dispatch, getState, resolver in
        guard
            let state = getState()?.mainState.friendsState,
            let mainState = getState()?.mainState,
            let networkService = resolver.resolve(NetworkServiceProtocol.self)
        else {
            return
        }

        let userId = mainState.session.user.userId
        
        state.recentFriendsState = .loading
        
        let request = GeneratedApi.Identity.GetRecentUsersV1.Request()
        let result = await networkService.request(request)
        
        parseResult(result) { successValue in
            state.recentFriendsState = .success(successValue.users.filter({ $0.firstName?.isEmpty == false }))
        } onError: { errorMessage in
            state.recentFriendsState = .error(errorMessage)
            dispatch(MainAction.showError(errorMessage))
        }
    }
    
    static var getContacts = AsyncThunkWithResolver<AppState> { dispatch, getState, resolver in
        guard
            let state = getState()?.mainState.friendsState
        else {
            return
        }
        
        let contacts = FetchedContacts()
        
        state.contactsState = .loading
        
        contacts.fetchContacts { result in
            switch result {
            case .success(let contacts):
                if contacts.isEmpty {
                    state.contactsState = .success([])
                    return
                }
                let filteredContacts = contacts.filter {
                    $0.phoneNumbers.first?.filter(numbersPattern.contains).starts(with: "965") ?? false
                }
                if filteredContacts.isEmpty {
                    state.contactsState = .success([])
                    return
                }
                let users = filteredContacts.map(UserShort.init(from:))
                
                let phoneNumbers = filteredContacts.flatMap({
                    $0.phoneNumbers.compactMap({ phone in
                        return "+" + phone.filter(numbersPattern.contains)
                    })
                })
                dispatch(FriendsAction.getUsersByPhone(phoneNumbers: phoneNumbers, users: users))
            case .failure(let error):
                state.contactsState = .error(error.localizedDescription)
            }
        }
    }
    
    static func getUsersByPhone(phoneNumbers: [String], users: [UserShort]) -> AsyncThunkWithResolver<AppState> {
        return AsyncThunkWithResolver<AppState> { dispatch, getState, resolver in
            guard
                let state = getState()?.mainState.friendsState,
                let networkService = resolver.resolve(NetworkServiceProtocol.self)
            else {
                return
            }
            
            let request = GeneratedApi.Identity.GetUsersByPhoneListV1.Request(body: GetUsersByPhonesRequest(phones: phoneNumbers))
            let result = await networkService.request(request)
            
            parseResult(result) { successValue in
                let otherUsers = users.filter { user in
                    !successValue.users.contains(where: {
                        ($0.phoneNumber ?? "").filter(numbersPattern.contains) == user.phoneNumber?.filter(numbersPattern.contains)
                    })
                }
                var newArray = successValue.users + otherUsers
                state.contactsState = .success(newArray)
            } onError: { errorMessage in
                state.contactsState = .success(users)
                dispatch(MainAction.showError(errorMessage))
            }
        }
    }
    
    static func searchFriends(query: String) -> AsyncThunkWithResolver<AppState> {
        
        return AsyncThunkWithResolver<AppState> { dispatch, getState, resolver in
            guard
                let state = getState()?.mainState.friendsState,
                let networkService = resolver.resolve(NetworkServiceProtocol.self)
            else {
                return
            }
            
            guard query.count > 3 else {
                state.searchFriendsState = .none
                return
            }
            
            state.searchFriendsState = .loading
            
            let request = GeneratedApi.Identity.SearchUsersV1.Request(query: query)
            let result = await networkService.request(request)
            
            parseResult(result) { successValue in
                var newUsers = successValue.users.sorted { user1, user2 in
                    return user1.username != nil && user2.username == nil
                }
                state.searchFriendsState = .success(newUsers)
            } onError: { errorMessage in
                state.searchFriendsState = .success([])
                dispatch(MainAction.showError(errorMessage))
            }
        }
    }
}

extension UserShort {
    convenience init(from contact: Contact) {
        self.init(
            id: UUID().uuidString, avatarPath: nil,
            firstName: contact.firstName,
            lastName: contact.lastName,
            middleName: nil,
            phoneNumber: "+" + (contact.phoneNumbers.first ?? "").filter("0123456789".contains),
            username: nil
        )
    }
}
