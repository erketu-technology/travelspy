//
//  UploadView.swift
//  TravelSpy
//
//  Created by AlexK on 01/12/2021.
//

import SwiftUI

import CloudKit

struct UploadView: View {
    @AppStorage("isShowPostCreation") public var isShowPostCreation = false
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var postsModel: PostsModel
    
    @State var selectedPhoto: Photo
    @State private var postContent: String = ""
    @State private var placeholderText: String = "Add content. (min 100 characters)"
    @State private var showingLocationsSearch = false
    @State private var locationItem: Location?
    
    @ObservedObject var locationSearchService = LocationSearchService()
    @State private var progressValue: Double = 0.0
    @State private var isUploading = false
    
    let MIN_POST_CONTENT_SIZE = 100
    
    var body: some View {
        VStack {
            ProgressView(value: progressValue, total: 2.0)
                .progressViewStyle(.linear)
                .opacity(isUploading ? 1 : 0)
            HStack {
                Image(uiImage: selectedPhoto.cropped)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(3.0)
                    .padding(.leading, 10)
                
                ZStack {
                    if postContent.isEmpty {
                        TextEditor(text: $placeholderText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .disabled(true)
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 0,
                                maxHeight: 100,
                                alignment: .leading
                            )
                            .padding()
                    }
                    TextEditor(text: $postContent)
                        .opacity(postContent.isEmpty ? 0.25 : 1)
                        .font(.subheadline)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: 100,
                            alignment: .leading
                        )
                        .padding()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Divider()
            Group {
                Text(locationItem?.countryAndCity ?? "")
                    .padding(.leading)
                Text("tap to choose location")
                    .italic()
                    .foregroundColor(.secondary)
                    .font(Font.subheadline)
                    .padding(.leading)
                    .font(.subheadline)
                Divider()
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                showingLocationsSearch = true
            }
            .fullScreenCover(isPresented: $showingLocationsSearch, content: {
                HStack {
                    Button {
                        showingLocationsSearch.toggle()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(width: 25, height: 20)
                            .padding(.leading, 20)
                            .onTapGesture {
                                showingLocationsSearch.toggle()
                            }
                    }
                    Spacer()
                }
                
                SearchBar(text: $locationSearchService.searchQuery)
                
                List(locationSearchService.completions) { completion in
                    VStack(alignment: .leading) {
                        Text(completion.title)
                        Text(completion.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .onTapGesture(perform: {
                        locationSearchService.getLocationObject(for: completion) { locItem in
                            locationItem = locItem
                            locationSearchService.searchQuery = ""
                            locationSearchService.completions.removeAll()
                            showingLocationsSearch = false
                        }
                    })
                }.id(UUID())
            })
            
            Button(action: {
                isUploading = true
                guard let location = locationItem else { return }
                
                PostsModel().addPost(content: postContent,
                                     locationItem: location,
                                     selectedPhoto: selectedPhoto,
                                     progressBlock: { progress in
                    self.progressValue = progress.croppedImageUpload + progress.originalImageUpload + progress.postUpload
                }, onComplete: { error in
                    isUploading = false
                    
                    if error != nil {
                        print("SHARE POST \(String(describing: error?.localizedDescription))")
                    }
                    Task {
                        await postsModel.fetchNextPosts()
                    }
                    viewRouter.currentPage = .list
                    
                    isShowPostCreation = false
                })
            }) {
                Text("Share")
                    .padding(.horizontal, 30.0)
                    .padding(/*@START_MENU_TOKEN@*/.vertical, 10.0/*@END_MENU_TOKEN@*/)
                    .background((isUploading || !canUpload) ? Color.gray : Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke((isUploading || !canUpload) ? Color.gray : Color.blue, lineWidth: 1)
                    )
            }
            .padding(.top, 20.0)
            .font(.headline)
            .disabled((isUploading || !canUpload) ? true : false)
            
            Spacer()
        }
        .onAppear(perform: getLocation)
    }
    
    var canUpload: Bool {
        let postLength = postContent.trimmingCharacters(in: .whitespacesAndNewlines).count
        return !postContent.isEmpty && postLength >= MIN_POST_CONTENT_SIZE && locationItem != nil && !locationItem!.countryAndCity.isEmpty
    }
    
    func getLocation() {
        Task {
            self.locationItem = await selectedPhoto.getLocation()
        }
    }
}

#if DEBUG
struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        let image = UIImage(systemName: "wind.snow")
        let selectedPhoto = Photo(original: image!, cropped: image!)
        UploadView(selectedPhoto: selectedPhoto)
    }
}
#endif
