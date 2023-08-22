//
//  EmptyCollectionView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/19/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct EmptyCollectionView: View {
    
    // MARK: View Variables
    var iconName: String
    var heading: String
    var text: String
    
    // MARK: View Body
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: 30))
                .foregroundColor(.secondary)
                .padding(.top)
                .padding(.bottom, 1)
            
            Text(heading)
                .dynamicFont(.title2, lineLimit: 5)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.bottom, 1)
            
            Text(text)
                .dynamicFont(.title2, lineLimit: 10)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct EmptyCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyCollectionView(iconName: "text.book.closed.fill", heading: "No Entries", text: "Add users to your Rolodex to mention and message them!")
    }
}

// MARK: Support Views
// Support views go here! :)
