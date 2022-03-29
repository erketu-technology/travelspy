//
//  AboutView.swift
//  TravelSpy
//
//  Created by AlexK on 29/03/2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            List {
                Section("TravelSpy") {
                    Text("Here you can find new and reliable information about different places on our planet.\nYou, like many others, may add incredible places and share them with others.")
                }
                .listRowBackground(Color.clear)

                Section {
                    VStack(alignment: .leading) {
                        Text("The application is open-source, and you always may contribute to the application if you like it!")
                        HStack {
                            Text("[TravelSpy: Github Repo](https://github.com/erketu-technology/travelspy)")
                                .italic()
                                .padding(.top, 10)
                        }                        
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .accentColor(.blue)
        .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
