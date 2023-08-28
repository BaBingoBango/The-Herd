//
//  BlockedUsersView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/25/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct BlockedUsersView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    
    // MARK: View Body
    var body: some View {
        ForEach(currentUser.blockedUserIDs, id: \.self) { eachBlockedID in
            let eachBlockedUserInfo = currentUser.blockDetails[eachBlockedID]
            
            HStack {
                ZStack {
                    Circle()
                        .foregroundColor(eachBlockedUserInfo?.color ?? .gray)
                        .frame(height: 50)
                    
                    Text(eachAddress.userEmoji)
                        .font(.system(size: 27.5))
                }
                .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    Text(eachAddress.nickname)
                        .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !eachAddress.comment.isEmpty {
                        Text(eachAddress.comment)
                            .dynamicFont(.body, minimumScaleFactor: 0.9, padding: 0)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct BlockedUsersView_Previews: PreviewProvider {
    static var previews: some View {
        BlockedUsersView(currentUser: .getSample())
    }
}

// MARK: Support Views
// Support views go here! :)
