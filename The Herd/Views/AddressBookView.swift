//
//  AddressBookView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/2/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct AddressBookView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    @State var searchText = ""
    var pickerMode = false
    @Binding var mentions: [ChatMember]
    var pickerAction = "Mention"
    var excludedUserIDs: [String]
    var locationManager = LocationManager()
    @State var showingProfileView = false
    @State var showingInfoView = false
    @Binding var newlyCreatedPost: Post
    
    // MARK: View Body
    var body: some View {
        let viewBody = ScrollView {
            VStack {
                SearchBarView(text: $searchText, placeholder: "Find People")
                
                let filteredAddresses = Array(currentUser.addresses.values).filter({ eachAddress in
                    if searchText.isEmpty { return true
                    } else {
                        return eachAddress.nickname.lowercased().contains(searchText.lowercased()) || eachAddress.comment.lowercased().contains(searchText.lowercased())
                    }
                })
                .filter({ !excludedUserIDs.contains($0.userUUID) })
                .filter({ $0.userUUID != currentUser.UUID })
                
                if !currentUser.blockedUserIDs.isEmpty {
                    HStack {
                        Text("\(currentUser.blockedUserIDs.count) Blocked User\(currentUser.blockedUserIDs.count == 1 ? "" : "s")")
                            .dynamicFont(.body, padding: 0)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .modifier(RectangleWrapper(color: .red, opacity: 0.15, cornerRadius: 15))
                }
                
                if filteredAddresses.isEmpty {
                    Image(systemName: "text.book.closed.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                        .padding(.top)
                        .padding(.bottom, 1)
                    
                    Text("No Entries")
                        .dynamicFont(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 1)
                    
                    Text("Add users to your Rolodex to mention and message them!")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                ForEach(filteredAddresses, id: \.UUID) { eachAddress in
                    let rowContent = HStack {
                        ZStack {
                            Circle()
                                .foregroundColor(eachAddress.userColor)
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
                    .modifier(RectangleWrapper(fixedHeight: 75, color: eachAddress.userColor, opacity: 0.05))
                    
                    if !pickerMode {
                        NavigationLink(destination: AddressEditorView(currentUser: currentUser, addressID: eachAddress.userUUID, enteredNickname: eachAddress.nickname, enteredComment: eachAddress.comment)) {
                            rowContent
                        }
                    } else {
                        Button(action: {
                            mentions.append(.init(userID: eachAddress.userUUID, emoji: eachAddress.userEmoji, color: eachAddress.userColor ))
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            rowContent
                        }
                    }
                }
                
                if !filteredAddresses.isEmpty {
                    HStack {
                        Button(action: {
                            showingInfoView = true
                        }) {
                            VStack(alignment: .leading, spacing: 2.5) {
                                Text("Some users may have changed their identity since you saved them.")
                                    .dynamicFont(.body, lineLimit: 10, padding: 0)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 5) {
                                    Text("Learn More")
                                        .dynamicFont(.body, padding: 0)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                        .multilineTextAlignment(.leading)
                                    
                                    Image(systemName: "chevron.right")
                                        .dynamicFont(.body, padding: 0)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .sheet(isPresented: $showingInfoView) {
                            AddressBookInfoView()
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .modifier(RectangleWrapper(color: .gray, opacity: 0.25))
                }
            }
            .padding([.leading, .bottom, .trailing])
        }
        
        // MARK: Navigation Settings
        .navigationTitle(!pickerMode ? "Rolodex" : "\(pickerAction) from Rolodex")
        .navigationBarTitleDisplayMode(!pickerMode ? .automatic : .inline)
        .toolbar(content: {
            if !pickerMode {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfileView = true
                    }) {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(currentUser.color)

                            Text(currentUser.emoji)
                                .font(.system(size: 20))
                        }
                    }
                    .sheet(isPresented: $showingProfileView) {
                        ProfileView(currentUser: currentUser, locationManager: locationManager, newlyCreatedPost: $newlyCreatedPost)
                    }
                }
            }
            
            if pickerMode {
                ToolbarItem(placement: !pickerMode ? .confirmationAction : .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(!pickerMode ? "Done" : "Cancel")
                            .fontWeight(.bold)
                    }
                }
            }
        })
        
        if !pickerMode {
            NavigationView {
                viewBody
            }
        } else {
            NavigationStack {
                viewBody
            }
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct AddressBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddressBookView(currentUser: .getSample(), mentions: .constant([]), excludedUserIDs: [], newlyCreatedPost: .constant(.sample))
    }
}

// MARK: Support Views
struct AddressBookInfoView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.2.crop.square.stack")
                    .fontWeight(.semibold)
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                    .padding(.top)
                
                Text("Rolodex and Privacy")
                    .dynamicFont(.title)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                    .padding(.bottom)
                
                InformationalRowView(iconName: "person.text.rectangle.fill", text: "The Rolodex stores copies of users' emoji, color, and private ID, allowing you to mention or message specific users.", color: .accentColor)
                    .padding(.bottom)
                
                InformationalRowView(iconName: "arrow.triangle.2.circlepath", text: "To protect changed identities, Rolodex entries won't be modified or removed if someone changes their emoji or color.", color: .accentColor)
                    .padding(.bottom)
                
                InformationalRowView(iconName: "exclamationmark.bubble.fill", text: "If a user changes their emoji or color, messages or mentions sent to their old identity won't be received.", color: .accentColor)
                
                Spacer()
            }
            .padding(.horizontal)
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
    }
}
struct AddressBookInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AddressBookInfoView()
    }
}
