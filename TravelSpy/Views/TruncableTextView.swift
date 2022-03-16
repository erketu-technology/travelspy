//
//  TruncableTextView.swift
//  TravelSpy
//
//  Created by AlexK on 23/12/2021.
//

import SwiftUI

struct TruncableTextView: View {
    let text: Text
    let lineLimit: Int?
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    let isTruncatedUpdate: (_ isTruncated: Bool) -> Void
    
    var body: some View {
        text
            .lineLimit(lineLimit)
            .tsReadSize { size in
                truncatedSize = size
                isTruncatedUpdate(truncatedSize != intrinsicSize)
            }
            .background(
                text
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .tsReadSize  { size in
                        intrinsicSize = size
                        isTruncatedUpdate(truncatedSize != intrinsicSize)
                    }
            )
    }
}

struct TruncableTextView_Previews: PreviewProvider {
    static var previews: some View {
        TruncableTextView(text: Text("Some Text"), lineLimit: 3) { _ in }
    }
}
