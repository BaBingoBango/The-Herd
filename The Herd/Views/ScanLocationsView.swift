//
//  ScanLocationsView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/15/23.
//

import SwiftUI
import MapItemPicker

/// An app view written in SwiftUI!
struct ScanLocationsView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    @State var changeLocationChoice = Operation(status: .inProgress)
    @State var changingLocationOption = ""
    @State var showingLocationPicker = false
    @State var showingLocationEditor = false
    
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
                        if currentUser.locationMode != .current {
                            
                            changeLocationChoice.status = .inProgress
                            changingLocationOption = "current"
                            usersCollection.document(currentUser.UUID).updateData([
                                "locationMode" : LocationMode.current.toString()
                            ]) { error in
                                if let error = error {
                                    changeLocationChoice.setError(message: error.localizedDescription)
                                } else {
                                    changeLocationChoice.status = .success
                                }
                            }
                        }
                        
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
                            
                            if changeLocationChoice.status == .inProgress && changingLocationOption == "current" {
                                ProgressView()
                                    .controlSize(.large)
                                    .scaleEffect(0.75)
                            } else {
                                Image(systemName: currentUser.locationMode == LocationMode.current ? "checkmark.circle.fill" : "circle")
                                    .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .modifier(RectangleWrapper(color: .blue, useGradient: true, opacity: 0.15))
                        .padding(.top)
                    }
                    .disabled(changeLocationChoice.status == .inProgress)
                    
                    HStack {
                        Text("Saved")
                            .dynamicFont(.title, padding: 0)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            showingLocationPicker = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                        .disabled(changeLocationChoice.status == .inProgress)
                        .mapItemPicker(isPresented: $showingLocationPicker) { location in
                            if let location = location {
                                
                                changeLocationChoice.status = .inProgress
                                let newLocation = SavedLocation(emoji: "🌎", nickname: location.name ?? "New Location", latitude: location.placemark.coordinate.latitude, longitude: location.placemark.coordinate.longitude)
                                changingLocationOption = newLocation.UUID
                                
                                var newLocationList = currentUser.savedLocations
                                newLocationList[newLocation.UUID] = newLocation
                                usersCollection.document(currentUser.UUID).updateData([
                                    "locationMode" : LocationMode.saved(locationID: newLocation.UUID).toString(),
                                    "savedLocations" : newLocationList.mapValues({ $0.dictify() })
                                ]) { error in
                                    if let error = error {
                                        changeLocationChoice.setError(message: error.localizedDescription)
                                    } else {
                                        changeLocationChoice.status = .success
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    ForEach(Array(currentUser.savedLocations.values.sorted(by: { $0.dateSaved > $1.dateSaved })), id: \.UUID) { eachLocation in
                        Button(action: {
                            showingLocationEditor = true
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
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                    }
                                    
                                    HStack {
                                        Text("LAT")
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.semibold)
                                        
                                        Text(String(eachLocation.latitude).prefix(10))
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.heavy)
                                        
                                        Text("LNG")
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.semibold)
                                        
                                        Text(String(eachLocation.longitude).prefix(10))
                                            .dynamicFont(.callout, fontDesign: .monospaced, lineLimit: 3, padding: 0)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.heavy)
                                    }
                                }
                                
                                Spacer()
                                
                                if changeLocationChoice.status == .inProgress && changingLocationOption == eachLocation.UUID {
                                    ProgressView()
                                        .controlSize(.large)
                                        .scaleEffect(0.75)
                                } else {
                                    Button(action: {
                                        if currentUser.locationMode != .saved(locationID: eachLocation.UUID) {
                                            
                                            changeLocationChoice.status = .inProgress
                                            changingLocationOption = eachLocation.UUID
                                            usersCollection.document(currentUser.UUID).updateData([
                                                "locationMode" : LocationMode.saved(locationID: eachLocation.UUID).toString()
                                            ]) { error in
                                                if let error = error {
                                                    changeLocationChoice.setError(message: error.localizedDescription)
                                                } else {
                                                    changeLocationChoice.status = .success
                                                }
                                            }
                                        }
                                        
                                    }) {
                                        Image(systemName: currentUser.locationMode == .saved(locationID: eachLocation.UUID) ? "checkmark.circle.fill" : "circle")
                                            .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                            .fontWeight(.bold)
                                            .foregroundColor(eachLocation.color)
                                    }
                                    .disabled(changeLocationChoice.status == .inProgress)
                                }
                            }
                            .padding()
                            .modifier(RectangleWrapper(color: eachLocation.color, useGradient: true, opacity: 0.15))
                        }
                        .disabled(changeLocationChoice.status == .inProgress)
                        .sheet(isPresented: $showingLocationEditor) {
                            SavedLocationEditorView(currentUser: currentUser, savedLocationID: eachLocation.UUID, locationName: eachLocation.nickname)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // MARK: Navigation Settings
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
                        changeLocationChoice.status = .success
                    }
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
