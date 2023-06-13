//
//  ProfileView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/12/23.
//

import SwiftUI
import FirebaseAuth

/// An app view written in SwiftUI!
struct ProfileView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var currentUser: User? = nil
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    HStack {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 75))
                                .foregroundColor(currentUser?.color ?? .gray.opacity(0.25))
                            
                            if let currentUser = currentUser {
                                Text(currentUser.emoji)
                                    .font(.system(size: 45))
                            } else {
                                ProgressView()
                            }
                        }
                        .shadow(color: .gray, radius: 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 10) {
                                Label("5000", systemImage: "hand.thumbsup.fill")
                                    .font(.system(size: 22.5, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Label("145", systemImage: "bubble.left.fill")
                                    .font(.system(size: 22.5, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Image(systemName: "laurel.leading")
                                    .font(.system(size: 20, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                Text("Since June 2023")
                                    .font(.system(size: 20, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "laurel.trailing")
                                    .font(.system(size: 20, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Activity")
                            .font(.system(size: 27.5))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.top, 5)
                    
                    Picker(selection: .constant(1), label: Text("")) {
                        Text("Posts").tag(1)
                        Text("Comments").tag(2)
                        Text("Votes").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .fontWeight(.bold)
                    }
                }
            })
        }
        .onAppear {
            // MARK: View Launch Code
            // Add preview data!
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                currentUser = .getSample()
                return
            }
            
            // If we haven't loaded the user's profile yet, transport it!
            if let userID = Auth.auth().currentUser?.uid {
                User.transportUserFromServer(userID,
                                             onError: { error in fatalError(error.localizedDescription) },
                                             onSuccess: { user in currentUser = user })
                
                // Set up a real-time listener for the user's profile!
                usersCollection.document(userID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { currentUser = User.dedictify(snapshotData) }
                    }
                })
            }
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// MARK: Support Views
// Support views go here! :)
