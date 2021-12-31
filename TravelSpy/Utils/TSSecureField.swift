//
//  TSSecureField.swift
//  TravelSpy
//
//  Created by AlexK on 30/12/2021.
//

import SwiftUI

struct TSSecureField: View {
    var placeholder: String
    var text: Binding<String>
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
    
    var body: some View {
        VStack {
            SecureField(placeholder, text: text)
            Divider()
        }
        .padding(.bottom, 7)
    }
}

struct TSSecureField_Previews: PreviewProvider {
    static var previews: some View {
        TSSecureField("placeholder", text: .constant(""))
    }
}
