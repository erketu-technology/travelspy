//
//  TSTextField.swift
//  TravelSpy
//
//  Created by AlexK on 30/12/2021.
//

import SwiftUI

struct TSTextField: View {
    var placeholder: String
    var text: Binding<String>
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
    
    var body: some View {
        VStack {
            TextField(placeholder, text: text)
            Divider()
        }
        .padding(.bottom, 7)
    }
}

struct TSTextField_Previews: PreviewProvider {
    static var previews: some View {
        TSTextField("placeholder", text: .constant(""))
    }
}
