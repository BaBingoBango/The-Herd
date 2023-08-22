//
//  DataDownloaderView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/20/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct DataDownloaderView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    
    // MARK: View Body
    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.down")
                .fontWeight(.semibold)
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .padding(.top)
            
            Text("Download Your Data")
                .dynamicFont(.title, lineLimit: 5)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .padding(.top, 5)
            
            Spacer()
            
            InformationalRowView(iconName: "text.alignleft", text: "Download a comprehensive .txt file containing all data associated with your account.", color: .blue)
                .padding(.bottom)
            
            InformationalRowView(iconName: "key.fill", text: "Your download will include authentication information. Please handle this data with caution to ensure your account's security.", color: .blue)
                .padding(.bottom)
            
            InformationalRowView(iconName: "hand.raised.square.fill", text: "Some identifiers within your user profile may be redacted to safeguard the privacy of other users.", color: .blue)
                .padding(.bottom)
            
            Spacer()
            
            ShareLink(item: currentUser.generateReport()) {
                Text("Download Data!")
                    .dynamicFont(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .modifier(RectangleWrapper(fixedHeight: 55, color: .blue, opacity: 1))
            }
        }
        .padding([.horizontal, .bottom])
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct DataDownloaderView_Previews: PreviewProvider {
    static var previews: some View {
        DataDownloaderView(currentUser: .getSample())
    }
}

// MARK: Support Views
// Support views go here! :)
