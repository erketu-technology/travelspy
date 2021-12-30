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
        TextField(placeholder, text: text)
            .padding()
            .autocapitalization(.none)
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0))
            .cornerRadius(12.0)
            .padding(.bottom, 10)
    }
}

struct TSTextField_Previews: PreviewProvider {
    static var previews: some View {
        TSTextField("placeholder", text: .constant(""))
    }
}
