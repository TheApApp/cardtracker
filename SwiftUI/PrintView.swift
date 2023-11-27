//
//  PdfView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 11/23/23.
//  Copyright © 2023 Michael Rowe. All rights reserved.
//

import CoreData
import SwiftUI

struct PrintView: View {
    let blankCardFront = UIImage(contentsOfFile: "frontImage")
    var event: Event
    
    init(event: Event) {
        self.event = event
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(uiImage: (event.cardFrontImage ?? blankCardFront)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(width: 130, height: 103)
                HStack {
                    VStack {
                        Text("\(event.event ?? "")")
                        Text("\(event.wrappedEventDate, formatter: ViewEventsView.eventDateFormatter)")
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
        .frame(width: 143, height: 134)
        .mask(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
}
