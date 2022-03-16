//
//  ViewRouter.swift
//  TravelSpy
//
//  Created by AlexK on 28/12/2021.
//


import SwiftUI
import Firebase

class ViewRouter: ObservableObject {
    @Published var currentPage: TSPage = Auth.auth().currentUser != nil ? .list : .explore
}


enum TSPage {
    case explore
    case list
}
