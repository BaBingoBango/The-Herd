//
//  SavedLocationEditorView.swift
//  The Herd
//
//  Created by Ethan Marshall on 7/5/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct SavedLocationEditorView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    var savedLocationID: String
    @State var locationName: String
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(currentUser.savedLocations[savedLocationID]!.color)
                        
                        Text(currentUser.savedLocations[savedLocationID]!.emoji)
                            .font(.system(size: 60))
                    }
                    .shadow(color: .gray, radius: 5)
                    
                    TextField("Location Name", text: $locationName)
                        .dynamicFont(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .onSubmit {
                            
                            usersCollection.document(currentUser.UUID).updateData([
                                "savedLocations" : // TODO: NEXT: finish this! :)
                            ]) { error in
                                
                            }
                            
                        }
                        .padding(.vertical)
                        .modifier(RectangleWrapper(opacity: 0.1, cornerRadius: 10))
                        .padding(.horizontal)
                }
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Edit Saved Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            })
        }
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
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct SavedLocationEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SavedLocationEditorView(currentUser: .getSample(),
                                savedLocationID: "E1974DB9-5198-409C-9707-599C56AB84A7-D8C69522-5B0F-4106-9149-A4CA2420F027-3105478D-4B1E-4A08-8AD2-989E41EB2096",
                                locationName: User.getSample().savedLocations["E1974DB9-5198-409C-9707-599C56AB84A7-D8C69522-5B0F-4106-9149-A4CA2420F027-3105478D-4B1E-4A08-8AD2-989E41EB2096"]!.nickname)
    }
}

// MARK: Support Views
// Support views go here! :)
