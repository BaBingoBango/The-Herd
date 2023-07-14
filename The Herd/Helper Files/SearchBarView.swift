//
//  SearchBarView.swift
//
//
//  Created by Ethan Marshall on 5/11/22.
//

// This file requires UIKit.
#if canImport(UIKit)

import Foundation
import SwiftUI

/// A search bar view with placeholder text and typed text accessible as a binding.
///
/// > Important: This view relies on UIKit, meaning it cannot be built for a native macOS app. However, it will still work for Mac Catalyst apps or iPad apps run on Apple silicon Macs.
///
/// Keyboard use is included in the view, including reveal and dismissal via the Cancel button. The view also includes an X button to clear any typed text.
struct SearchBarView: View {
    
    // MARK: - View Variables
    /// The text currently typed in the search bar.
    @Binding var text: String
    /// Whether or not the user is currently editing the search bar.
    @State var isEditing = false
    /// The placeholder text to display in the search bar.
    var placeholder = "Search"
    
    // MARK: - View Body
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
    }
}

// The end of the UIKit import requirement.
#endif
