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
    @State var getDrafts = Operation(status: .inProgress)
    @State var userDrafts: [Draft] = []
    var locationManager: LocationManager
    @State var showingNewPostView = false
    var repost: Post?
    var mentions: [ChatMember] = []
    @State var deleteDraft = Operation()
    @Binding var newlyCreatedPost: Post
    
    // MARK: View Body
    var body: some View {
        ScrollView {
            VStack {
                switch getDrafts.status {
                case .failure:
                    EmptyCollectionView(iconName: "wifi.slash", heading: "Couldn't Retrieve Drafts", text: getDrafts.errorMessage)
                    
                case .success:
                    if userDrafts.isEmpty {
                        EmptyCollectionView(iconName: "doc.text", heading: "No Drafts", text: "Create drafts to save your posts for just the right moment!")
                    } else {
                        ForEach(userDrafts, id: \.UUID) { eachDraft in
                            Button(action: {
                                showingNewPostView = true
                            }) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        Text(eachDraft.dateCreated.formatted())
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                        
                                        Text(eachDraft.text)
                                            .dynamicFont(.title2, lineLimit: 100, padding: 0)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    if deleteDraft.status != .inProgress {
                                        Button(action: {
                                            deleteUserDraft(eachDraft.UUID)
                                        }) {
                                            Image(systemName: "trash.fill")
                                                .dynamicFont(.title3, padding: 0)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding()
                                .modifier(RectangleWrapper(color: deleteDraft.status != .inProgress ? .accentColor : .gray, opacity: 0.15))
                                .padding(.horizontal)
                            }
                            .sheet(isPresented: $showingNewPostView) {
                                NewPostView(draftID: eachDraft.UUID, enteredText: eachDraft.text, enteredMentions: mentions, currentUser: currentUser, locationManager: locationManager, repost: eachDraft.repost.first, newlyCreatedPost: $newlyCreatedPost)
                                    .dismissalButton()
                            }
                            .disabled(deleteDraft.status == .inProgress)
                        }
                    }
                    
                default:
                    ProgressView()
                        .controlSize(.large)
                        .padding(.top, 20)
                }
            }
            .padding(.vertical)
            .alert(isPresented: $deleteDraft.isShowingErrorMessage) {
                Alert(title: Text("Couldn't Delete Drafts"),
                      message: Text(deleteDraft.errorMessage),
                      dismissButton: .default(Text("Close")))
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for the user's drafts!
            usersCollection.document(currentUser.UUID).collection("drafts").addSnapshotListener({ snapshots, error in
                if let error = error {
                    getDrafts.setError(message: error.localizedDescription)
                }
                
                if let snapshots = snapshots {
                    userDrafts = (snapshots.documents.map { Draft.dedictify($0.data()) }).sorted(by: { $0.dateCreated > $1.dateCreated })
                    getDrafts.status = .success
                }
            })
        }
    }
    
    // MARK: View Functions
    func deleteUserDraft(_ draftID: String) {
        deleteDraft.status = .inProgress
        
        usersCollection.document(currentUser.UUID).collection("drafts").document(draftID).delete() { error in
            if let error = error { deleteDraft.setError(message: error.localizedDescription ); return }
            deleteDraft.status = .success
        }
    }
}

// MARK: View Preview
struct DraftsView_Previews: PreviewProvider {
    static var previews: some View {
        DraftsView(locationManager: LocationManager(), newlyCreatedPost: .constant(.sample))
    }
}

// MARK: Support Views
// Support views go here! :)
