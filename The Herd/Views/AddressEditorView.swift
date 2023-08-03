//
//  AddressEditorView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/2/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct AddressEditorView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    var addressID: String
    @State var enteredNickname: String
    @State var enteredComment: String
    @State var deleteAddress = Operation()
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            Group {
                Form {
                    HStack {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 75))
                                .foregroundColor(currentUser.addresses[addressID]!.userColor)
                            
                            Text(currentUser.addresses[addressID]!.userEmoji)
                                .font(.system(size: 50))
                        }
                        .shadow(color: .gray, radius: 5)
                        
                        TextEditor(text: $enteredNickname)
                            .dynamicFont(.title)
                            .fontWeight(.bold)
                            .onSubmit {
                                var newAddresses = currentUser.addresses
                                newAddresses[addressID]!.nickname = enteredNickname
                                usersCollection.document(currentUser.UUID).updateData([
                                    "addresses" : newAddresses.mapValues({ $0.dictify() })
                                ]) { _ in }
                                
                            }
                            .modifier(RectangleWrapper(opacity: 0.1, cornerRadius: 10))
                    }
                    .listRowInsets(EdgeInsets())
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    Section(header: Text("Comment")) {
                        TextEditor(text: $enteredComment)
                            .frame(height: 150)
                            .onSubmit {
                                var newAddresses = currentUser.addresses
                                newAddresses[addressID]!.comment = enteredComment
                                usersCollection.document(currentUser.UUID).updateData([
                                    "addresses" : newAddresses.mapValues({ $0.dictify() })
                                ]) { _ in }
                            }
                    }
                    
                    Section {
                        Button(action: {
                            deleteAddress.status = .inProgress
                            
                            var newAddresses = currentUser.addresses
                            newAddresses.removeValue(forKey: addressID)
                            usersCollection.document(currentUser.UUID).updateData([
                                "addresses" : newAddresses.mapValues({ $0.dictify() }),
                            ]) { error in
                                if let error = error {
                                    deleteAddress.setError(message: error.localizedDescription)
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            Text("Delete Address")
                        }
                        .alert(isPresented: $deleteAddress.isShowingErrorMessage) {
                            Alert(title: Text("Couldn't Delete Rolodex Entry"),
                                  message: Text(deleteAddress.errorMessage),
                                  dismissButton: .default(Text("Close")))
                        }
                    }
                }
                
                // MARK: Navigation Settings
                .navigationTitle("Edit Entry")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            var newAddresses = currentUser.addresses
                            newAddresses[addressID]!.nickname = enteredNickname
                            newAddresses[addressID]!.comment = enteredComment
                            usersCollection.document(currentUser.UUID).updateData([
                                "addresses" : newAddresses.mapValues({ $0.dictify() })
                            ]) { _ in }
//
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .fontWeight(.bold)
                        }
                        .disabled(deleteAddress.status == .inProgress)
                    }
                })
            }
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct AddressDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AddressEditorView(currentUser: .getSample(), addressID: "randomlol", enteredNickname: "a friend!", enteredComment: "comment! comment! comment! what a great, long comment this is!")
    }
}

// MARK: Support Views
// Support views go here! :)
