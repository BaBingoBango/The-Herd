//
//  DismissalButton.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/20/23.
//

import Foundation
import SwiftUI

struct DismissalButton: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func body(content: Content) -> some View {
        NavigationStack {
            content
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .fontWeight(.bold)
                        }
                    }
                })
        }
    }
}

extension View {
    func dismissalButton() -> some View {
        modifier(DismissalButton())
    }
}
