//
//  AlertViewModel.swift
//  TravelSpy
//
//  Created by AlexK on 03/01/2022.
//

import Foundation
import AlertToast
import SwiftUI

class AlertViewModel: ObservableObject {
    enum AlertStatus {
        case success
        case error
    }
    
    private var status: AlertStatus = .success
    
    @Published var show = false
    @Published var alertToast = AlertToast(type: .regular, title: "") {
        didSet {
            show = true
        }
    }
    
    func setAlert(status: AlertStatus, title: String) {
        var type: AlertToast.AlertType
        var style: AlertToast.AlertStyle = .style(backgroundColor: .white, titleFont: .system(size: 13))
        
        switch status {
        case .success:
            type = .complete(.green)            
        case .error:
            type = .error(.red)
            style = .style(backgroundColor: .red, titleColor: .white, titleFont: .system(size: 13))
        }
        
        alertToast = AlertToast(displayMode: .banner(.slide), type: type, title: title, style: style)
    }
    
}
