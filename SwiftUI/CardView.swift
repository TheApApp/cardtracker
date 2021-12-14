//
//  CardView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 12/14/20.
//  Copyright © 2020 Michael Rowe. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @Environment(\.presentationMode) var presentationMode
    var cardImage: UIImage
    @State private var zoomed = true

    init(cardImage: UIImage) {
        let navBarApperance = UINavigationBarAppearance()
        navBarApperance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 35)!
        ]
        navBarApperance.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 20)!
        ]

        UINavigationBar.appearance().standardAppearance = navBarApperance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarApperance
        UINavigationBar.appearance().compactAppearance = navBarApperance
        self.cardImage = cardImage
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(uiImage: cardImage)
                    .resizable()
                    .aspectRatio(contentMode: zoomed ? .fit : .fill)
                    .onTapGesture {
                        withAnimation {
                            zoomed.toggle()
                        }
                    }
                    .ignoresSafeArea(edges: [.vertical, .bottom])
                Spacer()
            }
            .navigationBarItems(trailing:
                                    HStack {
                                        Button(action: {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            Image(systemName: "chevron.down.circle.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(.green)
                                        })
                                    }
            )
        }
    }
}

class SheetDismisserProtocol: ObservableObject {
    weak var host: UIHostingController<AnyView>?

    func dismiss() {
        host?.dismiss(animated: true)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView( cardImage: UIImage(imageLiteralResourceName: "frontImage"))
    }
}
