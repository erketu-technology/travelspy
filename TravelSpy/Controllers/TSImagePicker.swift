//
//  PhotosFusuma.swift
//  TravelSpy
//
//  Created by AlexK on 19/12/2021.
//

import Foundation
import SwiftUI
import YPImagePicker

struct TSImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    enum TSImageType {
        case post
        case account
    }

    var imageType: TSImageType = .post
    
    class Coordinator: YPImagePickerDelegate {
        var parent: TSImagePicker
        var imageType: TSImageType = .post
        
        init(_ parent: TSImagePicker, imageType: TSImageType) {
            self.parent = parent
            self.imageType = imageType
        }
        
        func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
            
        }
        
        func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
            return true
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, imageType: imageType)
    }
    
    func makeUIViewController(context: Context) -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        
        config.onlySquareImagesFromCamera = true
        config.screens = [.library, .photo]
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = YPPickerScreen.library
        config.maxCameraZoomFactor = 2.0
        
//        config.showsCrop = .rectangle(ratio: 1.0)
        config.targetImageSize = .cappedTo(size: 600.0)
//        config.icons.capturePhotoImage =
        
        config.library.onlySquare = true
        config.library.isSquareByDefault = true
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        
        
        let picker = YPImagePicker(configuration: config)

        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            var selectedPhoto = Photo()
            if let photo = items.singlePhoto {
//                print("AAAA didFinishPicking")
//                print(photo.fromCamera) // Image source (camera or library)
//                print(photo.image) // Final image selected by the user
//                print(photo.originalImage) // original image selected by the user, unfiltered
//                print(photo.modifiedImage) // Transformed image, can be nil
//                print(photo.exifMeta) // Print exif meta data of original image.            
                
                selectedPhoto.original = photo.originalImage
                selectedPhoto.cropped = photo.modifiedImage ?? photo.image
                selectedPhoto.asset = photo.asset
            }

            var nextVC: UIHostingController<AnyView>

            if imageType == .post {
                nextVC = UIHostingController(rootView: AnyView(UploadView(selectedPhoto: selectedPhoto)))
            } else {
                nextVC = UIHostingController(rootView: AnyView(AccountImageUpload(selectedPhoto: selectedPhoto)))
            }
            
            if cancelled {
                presentationMode.wrappedValue.dismiss()
            } else {
                picker.pushViewController(nextVC, animated: false)
            }
        }

        return picker
    }
    
    func updateUIViewController(_ uiViewController: YPImagePicker, context: Context) {
        
    }
}

