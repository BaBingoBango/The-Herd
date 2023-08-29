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
    @State var unblockUser = Operation()
    
    // MARK: View Body
    var body: some View {
        List {
            ForEach(currentUser.blockedUserIDs.sorted(by: {
                currentUser.blockDetails[$0]?.associatedDate ?? Date() > currentUser.blockDetails[$1]?.associatedDate ?? Date()
            }), id: \.self) { eachBlockedID in
                let eachBlockedUserInfo = currentUser.blockDetails[eachBlockedID]
                
                if let blockedInfo = eachBlockedUserInfo {
                    HStack {
                        ZStack {
                            Circle()
                                .foregroundColor(blockedInfo.color)
                                .frame(height: 40)
                            
                            Text(blockedInfo.emoji)
                                .font(.system(size: 22.5))
                        }
                        .padding(.leading, 10)
                        
                        VStack(alignment: .leading) {
                            Text("Blocked On")
                                .dynamicFont(.callout, fontDesign: .rounded, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            Text("\(blockedInfo.associatedDate.formatted(date: .numeric, time: .shortened))")
                                .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button(role: .destructive, action: {
                                unblockUser.status = .inProgress
                                
                                var newBlocks = currentUser.blockedUserIDs
                                newBlocks.removeAll(where: { $0 == blockedInfo.userID })
                                var newBlockDetails = currentUser.blockDetails
                                newBlockDetails.removeValue(forKey: blockedInfo.userID)
                                usersCollection.document(currentUser.UUID).updateData([
                                    "blockedUserIDs" : newBlocks,
                                    "blockDetails" : newBlockDetails.mapValues({ $0.dictify() })
                                ]) { error in
                                    if let error = error {
                                        unblockUser.setError(message: error.localizedDescription)
                                    } else {
                                        unblockUser.status = .success
                                    }
                                }
                            }) {
                                Label("Unblock User", systemImage: "hand.thumbsup.fill")
                                    .foregroundColor(.red)
                            }
                            
                        } label: {
                            ZStack {
                                Circle()
                                    .foregroundColor(.red)
                                    .opacity(0.15)
                                    .frame(height: 35)
                                
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 18))
                            }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for the user's profile!
            usersCollection.document(currentUser.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data() {
                        currentUser.replaceFields(User.dedictify(snapshotData))
                    }
                }
            })
        }
        
        // MARK: Navigation Settings
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct BlockedUsersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BlockedUsersView(currentUser: .getSample())
        }
    }
}

// MARK: Support Views
// Support views go here! :)
