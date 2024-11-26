//
//  FriendsListSearchView.swift
//  Kem
//
//  Created by Павел Мальков on 09.11.2023.
//

import SwiftUI
import KemUI
import GeneratedApi
import Prefire

struct FriendsListSearchView: View {
    @Environment(\.store) var store: Store
    
    @EnvironmentObject var state: MoneyTransferState
    @EnvironmentObject var friendsState: FriendsState
    @EnvironmentObject var mainState: MainState
    
    @State var searchText: String = ""
    
    var friends: [UserShort] {
        if friendsState.friendsState.isLoading {
            return [mockUserShort1, mockUserShort2, mockUserShort1]
        }
        
        let lowercasedSearchText = searchText.lowercased()
        let friends = friendsState.friendsState.result ?? []
        if lowercasedSearchText.isEmpty {
            return friends
        }
        
        return friends.filter {
            ($0.firstName ?? "").lowercased().contains(lowercasedSearchText) ||
            ($0.lastName ?? "").lowercased().contains(lowercasedSearchText) ||
            ($0.phoneNumber ?? "").lowercased().contains(lowercasedSearchText)
        }
    }
    
    var recentsFriends: [UserShort] {
        if friendsState.recentFriendsState.isLoading {
            return [mockUserShort1, mockUserShort2, mockUserShort1, mockUserShort2]
        }
        
        let lowercasedSearchText = searchText.lowercased()
        let friends = friendsState.recentFriendsState.result ?? []
        if lowercasedSearchText.isEmpty {
            return friends
        }
        
        return friends.filter {
            ($0.firstName ?? "").lowercased().contains(lowercasedSearchText) ||
            ($0.lastName ?? "").lowercased().contains(lowercasedSearchText) ||
            ($0.phoneNumber ?? "").lowercased().contains(lowercasedSearchText)
        }
    }
    
    var contacts: [UserShort] {
        let lowercasedSearchText = searchText.lowercased()
        let contacts = friendsState.contactsState.result ?? []
        if lowercasedSearchText.isEmpty {
            return contacts
        }
        
        return contacts.filter {
            ($0.firstName ?? "").lowercased().contains(lowercasedSearchText) ||
            ($0.lastName ?? "").lowercased().contains(lowercasedSearchText) ||
            ($0.phoneNumber ?? "").lowercased().contains(lowercasedSearchText)
        }
    }
    
    var searchFriends: [UserShort] {
        let searchedFriend = friendsState.searchFriendsState.result ?? []
        return searchedFriend.filter { user in
            !contacts.contains(user) && !friends.contains(user)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchBar(text: $searchText, placeholder: KS.search)
                .padding(.bottom, 8)
                .padding(.top, 16)
                .padding(.horizontal, 12)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if searchText.count > 3, (!searchFriends.isEmpty || (PhoneFormatter.isValidPhone(searchText) && searchText != mainState.session.user.phoneNumber.numberString) ) {
                        Section {
                            searchList
                                .padding(.bottom, 28)
                        }
                    }
                    
                    if !recentsFriends.isEmpty {
                        Section {
                            recentFriendsList
                                .padding(.bottom, 24)
                        } header: {
                            Text(KS.transactionFriendsRecents)
                                .font(.headline3Semibold)
                                .foregroundColor(KA.text.swiftUIColor)
                                .padding(.bottom, 20)
                                .padding(.top, 20)
                        }
                    }
                    
                    if mainState.isInternationalTransferAvailable() {
                        Section {
                            Button(action: {
                                store.dispatch(NavigationAction.push(destination: .InternationalTransferView))
                            }) {
                                internalTransferView
                                    .frame(height: 82)
                                    .arrow()
                                    .padding(.horizontal, 12)
                                    .background(KA.componentBg.swiftUIColor)
                                    .cornerRadius(24)
                                    .contentShape(Rectangle())
                                    .shadow()
                            }
                            .padding(.bottom, 24)
                        }
                    }
                    
                    if !friends.isEmpty {
                        Section {
                            friendsList
                                .padding(.bottom, 28)
                        } header: {
                            Text(KS.friendsListTitle)
                                .font(.headline3Semibold)
                                .foregroundColor(KA.text.swiftUIColor)
                                .padding(.bottom, 12)
                        }
                    }
                    
                    if !contacts.isEmpty || friendsState.contactsState.errorMessage == ContactsAccessError.failedToRequestAccess.localizedDescription.capitalized  {
                        Section {
                            if friendsState.contactsState.errorMessage == ContactsAccessError.failedToRequestAccess.localizedDescription.capitalized {
                                contactsAccessView
                            } else {
                                contactList
                            }
                        } header: {
                            Text(KS.transactionFriendsContacts)
                                .font(.headline3Semibold)
                                .foregroundColor(KA.text.swiftUIColor)
                                .padding(.bottom, 4)
                        }
                    }
                    
                }
                .padding(.horizontal, 12)
            }
            .clipped()
            
        }
        .navigationInlinedTitle(getNavigationTitle())
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavigationBackButton() {
            store.dispatch(NavigationAction.dismiss)
        })
        .onChange(of: searchText, debounceTime: .seconds(1), perform: { searchText in
            store.dispatch(FriendsAction.searchFriends(query: searchText))
        })
        .task {
            if !friendsState.recentFriendsState.isLoaded {
                store.dispatch(FriendsAction.getFriends)
            }
            if !friendsState.friendsState.isLoaded {
                store.dispatch(FriendsAction.getRecentFriends)
            }
            if !friendsState.contactsState.isLoaded {
                store.dispatch(FriendsAction.getContacts)
            }
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    var searchList: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if !searchFriends.isEmpty {
                ForEach(searchFriends, id: \.id) { user in
                    Button(action: {
                        presentConfirmation(user: user)
                    }) {
                        FriendCell(model: FriendCellViewModel(user: user), rightImage: nil)
                            .frame(height: 76)
                            .arrow()
                            .divider()
                            .contentShape(Rectangle())
                    }
                }
            } else if PhoneFormatter.isValidPhone(searchText) {
                let user = UserShort(id: UUID().uuidString, phoneNumber: searchText)
                Button(action: {
                    presentConfirmation(user: user)
                }) {
                    FriendCell(model: FriendCellViewModel(user: user), rightImage: nil)
                        .frame(height: 76)
                        .divider()
                        .arrow()
                        .contentShape(Rectangle())
                }
            }
        }
    }
    
    var recentFriendsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 24) {
                ForEach(recentsFriends, id: \.id) { user in
                    Button(action: {
                        presentConfirmation(user: user)
                    }) {
                        RecentFriendCell(model: RecentFriendCellViewModel(user: user))
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .redacted(if: friendsState.recentFriendsState.isLoading)
    }
    
    var internalTransferView: some View {
        HStack(spacing: 12) {
            Image(asset: KA.icPlanetBackground)
                .frame(width: 58, height: 58)
            VStack(alignment: .leading, spacing: 0) {
                Text("International transfer")
                    .font(.body3Regular)
                    .foregroundColor(KemUIAsset.Assets.text.swiftUIColor)
            }
        }
        .contentShape(Rectangle())
    }
    
    var contactList: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(contacts, id: \.phoneNumber) { user in
                Button(action: {
                    presentConfirmation(user: user)
                }) {
                    FriendCell(model: FriendCellViewModel(user: user), rightImage: nil)
                        .frame(height: 82)
                        .arrow()
                        .padding(.horizontal, 12)
                        .background(KA.componentBg.swiftUIColor)
                        .cornerRadius(24)
                        .contentShape(Rectangle())
                        .shadow()
                }
            }
        }
        .redacted(if: friendsState.friendsState.isLoading)
    }
    
    var friendsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(friends, id: \.id) { user in
                Button(action: {
                    presentConfirmation(user: user)
                }) {
                    FriendCell(model: FriendCellViewModel(user: user), rightImage: nil)
                        .frame(height: 82)
                        .arrow()
                        .padding(.horizontal, 12)
                        .background(KA.componentBg.swiftUIColor)
                        .cornerRadius(24)
                        .contentShape(Rectangle())
                        .shadow()
                }
            }
        }
        .redacted(reason: friendsState.friendsState.isLoading ? .placeholder : [])
    }
    
    var contactsAccessView: some View {
        ContactsAccessView {
            // Create the URL that deep links to your app's custom settings.
            if let url = URL(string: UIApplication.openSettingsURLString) {
                // Ask the system to open that URL.
                UIApplication.shared.open(url)
            }
        }
        .frame(height: 152)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
    
    func presentConfirmation(user: UserShort) {
        store.dispatch(MoneyTransferAction.selectUser(user: user))
        store.dispatch(NavigationAction.push(destination: .TransactionConfirmationView))
    }
    
    func getNavigationTitle() -> String {
        var navigationTitle = state.moneyTransferData.moneyTransferType?.navigationTitle ?? ""
        navigationTitle += " \(state.moneyTransferData.amount) KWD"
        return navigationTitle
    }
}

#Preview {
    FriendsListSearchView()
        .environmentObject(mockMainState)
        .environmentObject(mockTransferState)
        .environmentObject(mockFriendsState)
        .previewUserStory(.moneyTransfer)
}
