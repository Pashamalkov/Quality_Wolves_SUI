//
//  FriendCellViewModel.swift
//  Kem
//
//  Created by Павел Мальков on 06.02.2023.
//

import Foundation
import GeneratedApi
import KemUI

struct FriendCellViewModel {
    private let user: UserShort
    
    var title: String? {
        var fullName: String = ""
        if let firstName = user.firstName, !firstName.isEmpty {
            fullName = firstName + " "
        }
        if let lastName = user.lastName {
            fullName += lastName
        }
        if fullName.isEmpty {
            return nil
        }
        return fullName
        
    }
    
    var userName: String? {
        return user.username
    }
    
    var phoneNumber: String? {
        return user.phoneNumber
    }
    
    var imageUrl: URL? {
        if let imageUrl = URL(string: user.avatarPath ?? "") {
            return imageUrl
        }
        return nil
    }
    
    var image: KemUIImages? {
        if imageUrl == nil {
            if user.firstName == nil {
                return KA.mockPhoneImage
            }
            return nil
        }
        return nil
    }
    
    init(user: UserShort) {
        self.user = user
    }
}
