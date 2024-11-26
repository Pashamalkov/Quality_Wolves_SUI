//
//  RecentFriendCellViewModel.swift
//  Kem
//
//  Created by Павел Мальков on 06.02.2023.
//

import Foundation
import GeneratedApi

struct RecentFriendCellViewModel {
    private let user: UserShort
    
    var title: String {
        return user.firstName ?? ""
    }
    
    var imageUrl: URL? {
        if let imageUrl = URL(string: user.avatarPath ?? "") {
            return imageUrl
        }
        return nil
    }
    
    init(user: UserShort) {
        self.user = user
    }
}
