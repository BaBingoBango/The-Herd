//
//  DraftsView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/20/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct DraftsView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User = .getSample()
    @State var getDrafts = Operation()
    @State var userDrafts: [Draft] = []
    var locationManager: LocationManager
    @State var showingNewPostView = false
    
    // MARK: View Body
    var body: some View {
        ScrollView {
            VStack {
                ForEach(userDrafts, id: \.UUID) { eachDraft in
                    Button(action: {
                        showingNewPostView = true
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(eachDraft.dateCreated.formatted())
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                
                                Text("These are some test drafts. Wheee! Beep beep beep! Thoughts?")
                                    .dynamicFont(.title2, lineLimit: 100, padding: 0)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .modifier(RectangleWrapper(color: .accentColor, opacity: 0.15))
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showingNewPostView) {
                        // TODO: pass in a draft ID optionally and then delete it if the post is made, or edit it if the draft text is changed!
                        NavigationView {
                            NewPostView(enteredText: eachDraft.text, locationManager: locationManager)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for the user's drafts!
            usersCollection.document(currentUser.UUID).collection("drafts").addSnapshotListener({ snapshots, error in
                if let snapshots = snapshots {
                    userDrafts = snapshots.documents.map { Draft.dedictify($0.data()) }
                    getDrafts.status = .success
                }
            })
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct DraftsView_Previews: PreviewProvider {
    static var previews: some View {
        DraftsView(locationManager: LocationManager())
    }
}

// MARK: Support Views
// Support views go here! :)
