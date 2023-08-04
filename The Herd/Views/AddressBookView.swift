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
    @Binding var mentions: [String]
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBarView(text: $searchText, placeholder: "Find People")
                    
                    let filteredAddresses = Array(currentUser.addresses.values).filter({ eachAddress in
                        if searchText.isEmpty { return true
                        } else {
                            return eachAddress.nickname.contains(searchText) || eachAddress.comment.contains(searchText)
                        }
                    })
                    
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
                                    .padding(.leading, 10)
                                
                                Text(eachAddress.userEmoji)
                                    .font(.system(size: 27.5))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(eachAddress.nickname)
                                    .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(eachAddress.comment)
                                    .dynamicFont(.body, minimumScaleFactor: 0.9, padding: 0)
                                    .foregroundColor(.secondary)
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
                                mentions.append(eachAddress.userUUID)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                NavigationLink(destination: AddressEditorView(currentUser: currentUser, addressID: eachAddress.userUUID, enteredNickname: eachAddress.nickname, enteredComment: eachAddress.comment)) {
                                    rowContent
                                }
                            }
                        }
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            
            // MARK: Navigation Settings
            .navigationTitle(!pickerMode ? "Rolodex" : "Mention from Rolodex")
            .navigationBarTitleDisplayMode(!pickerMode ? .automatic : .inline)
            .toolbar(content: {
                ToolbarItem(placement: !pickerMode ? .confirmationAction : .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(!pickerMode ? "Done" : "Cancel")
                            .fontWeight(.bold)
                    }
                }
            })
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct AddressBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddressBookView(currentUser: .getSample(), mentions: .constant([]))
    }
}

// MARK: Support Views
// Support views go here! :)
