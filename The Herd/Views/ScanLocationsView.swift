//
//  ScanLocationsView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/15/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct ScanLocationsView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .dynamicFont(.system(size: 50), padding: 0)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading) {
                            Text("Scan Locations")
                                .dynamicFont(.title, padding: 0)
                                .fontWeight(.bold)
                            
                            Text("You'll be able to see posts within five miles of your scan location!")
                                .dynamicFont(.body, lineLimit: 7, padding: 0)
                        }
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        let newUserObject = currentUser
                        newUserObject.locationMode = .current
                        newUserObject.transportToServer(path: usersCollection, documentID: currentUser.UUID, operation: nil, onError: nil, onSuccess: nil)
                        
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Current Location")
                                    .dynamicFont(.title2, fontDesign: .rounded, lineLimit: 4, padding: 0)
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                                
                                Text("Use your device to update your location every time you scan for posts!")
                                    .dynamicFont(.callout, lineLimit: 4, padding: 0)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            Image(systemName: currentUser.locationMode == LocationMode.current ? "checkmark.circle.fill" : "circle")
                                .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .modifier(RectangleWrapper(color: .blue, useGradient: true, opacity: 0.15))
                        .padding(.top)
                    }
                    
                    HStack {
                        Text("Saved")
                            .dynamicFont(.title, padding: 0)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    ForEach(Array(currentUser.savedLocations.values), id: \.UUID) { eachLocation in
                        Button(action: {
                            let newUserObject = currentUser
                            newUserObject.locationMode = .saved(locationID: eachLocation.UUID)
                            newUserObject.transportToServer(path: usersCollection, documentID: currentUser.UUID, operation: nil, onError: nil, onSuccess: nil)
                            
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(eachLocation.emoji)
                                            .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                        
                                        Text(eachLocation.nickname)
                                            .dynamicFont(.title3, fontDesign: .rounded, lineLimit: 4, padding: 0)
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                    }
                                    
                                    HStack {
                                        Text("LAT")
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.semibold)
                                        
                                        Text(String(eachLocation.latitude))
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.heavy)
                                        
                                        Text("LNG")
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.semibold)
                                        
                                        Text(String(eachLocation.longitude))
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.heavy)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: currentUser.locationMode == .saved(locationID: eachLocation.UUID) ? "checkmark.circle.fill" : "circle")
                                    .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                            }
                            .padding()
                            .modifier(RectangleWrapper(color: .accentColor, useGradient: true, opacity: 0.15))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // MARK: Navigation Settings
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
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
                    if let snapshotData = snapshot.data() { currentUser.replaceFields(User.dedictify(snapshotData)) }
                }
            })
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct ScanLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        ScanLocationsView(currentUser: .getSample())
    }
}

// MARK: Support Views
// Support views go here! :)
