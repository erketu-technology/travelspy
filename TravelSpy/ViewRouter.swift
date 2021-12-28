//
//  ViewRouter.swift
//  TravelSpy
//
//  Created by AlexK on 28/12/2021.
//


import SwiftUI

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .list
}


enum Page {
    case explore
    case list
}
