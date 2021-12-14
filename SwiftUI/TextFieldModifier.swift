//
//  TextFieldModifier.swift
//  Card Tracker
//
//  Created by Michael Rowe on 3/2/21.
//  Copyright © 2021 Michael Rowe. All rights reserved.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    let borderWidth: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .padding(10)
            .font(Font.system(size: 15, weight: .medium, design: .serif))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: borderWidth))
    }
}

extension View {
    func customTextField() -> some View {
        self.modifier(TextFieldModifier())
    }
}
