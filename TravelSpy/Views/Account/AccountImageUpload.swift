//
//  AccountImageUpload.swift
//  TravelSpy
//
//  Created by AlexK on 03/02/2022.
//

import SwiftUI

struct AccountImageUpload: View {
    @EnvironmentObject var sessionStore: SessionStore

    @AppStorage("isShowAccountImageCreation") public var isShowAccountImageCreation = false
    @State var selectedPhoto: Photo

    @State private var isUploading = false
    @State private var updateImage = false
    
    var body: some View {
        VStack {
            Image(uiImage: selectedPhoto.cropped)
                .resizable()
                .frame(width: 200, height: 200)
                .scaledToFill()
                .cornerRadius(100)
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))

            Button {
                isUploading = true
                sessionStore.changeAvatar(photo: selectedPhoto) { profile, error in
                    isUploading = false
                    isShowAccountImageCreation = false
                }
            } label: {
                Text("Upload")
                    .padding(.horizontal, 30.0)
                    .padding(/*@START_MENU_TOKEN@*/.vertical, 10.0/*@END_MENU_TOKEN@*/)
                    .background(isUploading ? Color.gray : Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isUploading ? Color.gray : Color.blue, lineWidth: 1)
                    )
            }
            .padding(.top, 20.0)
            .font(.headline)
            .disabled(isUploading ? true : false)
        }
    }
}

struct AccountImageUpload_Previews: PreviewProvider {
    static var previews: some View {
        AccountImageUpload(selectedPhoto: Photo.template())
    }
}
