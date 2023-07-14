//
//  EmojiPickerView.swift
//  The Herd
//
//  Created by Ethan Marshall on 7/13/23.
//

import Foundation
import SwiftUI

struct EmojiPickerView: View {
    
    // MARK: - View Variables
    /// The horizontal size class of the current app environment.
    ///
    /// It is only relevant in iOS and iPadOS, since macOS and tvOS feature a consistent layout experience.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var roomColor: Color
    @Binding var enteredIcon: String
    let emojis = Emoji.allEmojis
    @State var searchText = ""
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ScrollView {
                SearchBarView(text: $searchText, placeholder: "Find Emoji")
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: horizontalSizeClass == .compact ? 4 : 6)) {
                    ForEach(emojis.filter({ if searchText.isEmpty { return true } else { return $0 == searchText } }), id: \.self) { eachEmoji in
                        Button(action: {
                            enteredIcon = eachEmoji
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            GeometryReader { geometry in
                                ZStack {
                                    Circle()
                                        .foregroundColor(roomColor)
                                        .opacity(0.3)
                                    
                                    Text(eachEmoji)
                                        .font(.system(size: geometry.size.height > geometry.size.width ? geometry.size.width * 0.6: geometry.size.height * 0.6))
                                        .foregroundColor(.primary)
                                }
                            }
                            .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle("Select Location Icon")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Cancel").fontWeight(.bold) })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EmojiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerView(roomColor: .red, enteredIcon: .constant("🎶"))
    }
}
