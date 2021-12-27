//
//  CameraView.swift
//  TravelSpy
//
//  Created by AlexK on 26/11/2021.
//

import UIKit
import SwiftUI

class CameraState: ObservableObject {
    @Published var photo: UIImage? = nil
}

class ShouldDismiss: ObservableObject {
    @Published var dismiss: Bool = false
}

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var cameraState: CameraState
    @ObservedObject var shouldDismiss: ShouldDismiss
    
    var coordinator: Coordinator!

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIImagePickerController {
        return UIImagePickerController()
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraView>) {
        uiViewController.mediaTypes = ["public.image"]
        uiViewController.delegate = context.coordinator
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            uiViewController.sourceType = .camera
        } else {
            uiViewController.sourceType = .photoLibrary
        }
    }
    
    func makeCoordinator() -> CameraView.Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView
        
        init(_ cameraView: CameraView) {
            parent = cameraView
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.cameraState.photo = nil
            parent.shouldDismiss.dismiss = true
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.cameraState.photo = info[.originalImage] as? UIImage
            parent.shouldDismiss.dismiss = true
        }
    }
}
