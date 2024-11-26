//
//  FriendCell.swift
//  Kem
//
//  Created by Павел Мальков on 06.02.2023.
//

import SwiftUI
import KemUI
import GeneratedApi

struct FriendCell: View {
    let model: FriendCellViewModel
    let rightImage: Image?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let image = model.image {
                Image(asset: image)
                    .resizable()
                    .clipShape(Circle())
            } else {
                ProfileURLImage(url: model.imageUrl, name: model.title, contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 0) {
                if let title = model.title, !title.isEmpty {
                    Text(title)
                        .font(.headline6Medium)
                        .foregroundColor(KA.text.swiftUIColor)
                }
                if let username = model.userName, !username.isEmpty {
                    Text("@" + username)
                        .foregroundColor(KA.lightGreen.swiftUIColor)
                        .font(.body2Medium)
                        .padding(.top, 6)
                } else if let phone = model.phoneNumber, !phone.isEmpty {
                    Text(phone)
                        .foregroundColor(KA.smallButtons.swiftUIColor)
                        .font(.body3Regular)
                }
            }
            Spacer(minLength: 12)
            rightImage
                .foregroundColor(KA.smallButtons.swiftUIColor)
        }
    }
}

struct FriendCell_Previews: PreviewProvider {
    
    static var previews: some View {
        FriendCell(model: FriendCellViewModel(user: mockUserShort1), rightImage: KemUIAsset.Assets.icArrow.swiftUIImage)
    }
}
