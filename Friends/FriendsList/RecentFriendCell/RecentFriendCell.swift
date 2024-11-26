//
//  RecentFriendCell.swift
//  Kem
//
//  Created by Павел Мальков on 06.02.2023.
//

import SwiftUI
import KemUI

struct RecentFriendCell: View {
    let model: RecentFriendCellViewModel
    
    var body: some View {
        VStack(spacing: 6) {
            ProfileURLImage(url: model.imageUrl, name: model.title, contentMode: .fill)
                .frame(width: 64, height: 64)
                .clipShape(Circle())
            Text(model.title)
                .font(.headline6Medium)
                .foregroundColor(KA.text.swiftUIColor)
        }
    }
}

struct RecentFriendCell_Previews: PreviewProvider {
    static var previews: some View {
        RecentFriendCell(model: RecentFriendCellViewModel(user: mockUserShort1))
    }
}
