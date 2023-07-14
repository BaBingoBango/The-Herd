//
//  SavedLocationEditorView.swift
//  The Herd
//
//  Created by Ethan Marshall on 7/5/23.
//

import SwiftUI
import MapKit

/// An app view written in SwiftUI!
struct SavedLocationEditorView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User
    var savedLocationID: String
    @State var locationName: String
    @State var color: Color
    @State var emoji: String
    @State var showingEmojiPicker = false
    @State var showingLocationPicker = false
    @State var deleteLocation = Operation()
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            Group {
                if deleteLocation.status == .inProgress {
                    ProgressView()
                        .controlSize(.large)
                    
                } else {
                    Form {
                        HStack {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 75))
                                    .foregroundColor(currentUser.savedLocations[savedLocationID]!.color)
                                
                                Text(currentUser.savedLocations[savedLocationID]!.emoji)
                                    .font(.system(size: 50))
                            }
                            .shadow(color: .gray, radius: 5)
                            
                            TextEditor(text: $locationName)
                                .dynamicFont(.title)
                                .fontWeight(.bold)
                                .onSubmit {
                                    
                                    var newLocations = currentUser.savedLocations
                                    newLocations[savedLocationID]!.nickname = locationName
                                    usersCollection.document(currentUser.UUID).updateData([
                                        "savedLocations" : newLocations.mapValues({ $0.dictify() })
                                    ]) { _ in }
                                    
                                }
                                .modifier(RectangleWrapper(opacity: 0.1, cornerRadius: 10))
                        }
                        .listRowInsets(EdgeInsets())
                        .background(Color(UIColor.systemGroupedBackground))
                        
                        Section {
                            HStack {
                                Text("Color")
                                
                                ColorPicker("", selection: $color)
                                    .onChange(of: color) { _ in
                                        var newLocations = currentUser.savedLocations
                                        newLocations[savedLocationID]!.color = color
                                        usersCollection.document(currentUser.UUID).updateData([
                                            "savedLocations" : newLocations.mapValues({ $0.dictify() })
                                        ]) { _ in }
                                    }
                            }
                            
                            Button(action: {
                                showingEmojiPicker = true
                            }) {
                                HStack {
                                    Text("Icon")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(emoji)
                                }
                            }
                            .sheet(isPresented: $showingEmojiPicker) {
                                EmojiPickerView(roomColor: color, enteredIcon: $emoji)
                            }
                            .onChange(of: emoji) { _ in
                                var newLocations = currentUser.savedLocations
                                newLocations[savedLocationID]!.emoji = emoji
                                usersCollection.document(currentUser.UUID).updateData([
                                    "savedLocations" : newLocations.mapValues({ $0.dictify() })
                                ]) { _ in }
                            }
                        }
                        
                        Section() {
                            let location = CLLocationCoordinate2D(latitude: currentUser.savedLocations[savedLocationID]!.latitude,
                                                                  longitude: currentUser.savedLocations[savedLocationID]!.longitude)
                            
                            Button(action: {
                                let mapsURL = URL(string: "maps://?saddr=&daddr=\(location.latitude),\(location.longitude)")!
                                if UIApplication.shared.canOpenURL(mapsURL) {
                                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                                }
                                
                            }) {
                                Map(coordinateRegion: .constant(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))), annotationItems: [Taylor()]) { eachLocation in
                                    MapMarker(coordinate: location)
                                }
                                .disabled(true)
                            }
                            .frame(height: 150)
                            .listRowInsets(EdgeInsets())
                            .background(Color(UIColor.systemGroupedBackground))
                            
                            Button(action: {
                                showingLocationPicker = true
                            }) {
                                Text("Change Location...")
                            }
                            .mapItemPicker(isPresented: $showingLocationPicker) { chosenLocation in
                                if let chosenLocation = chosenLocation {
                                    
                                    var newLocations = currentUser.savedLocations
                                    newLocations[savedLocationID]!.latitude = chosenLocation.placemark.coordinate.latitude
                                    newLocations[savedLocationID]!.longitude = chosenLocation.placemark.coordinate.longitude
                                    usersCollection.document(currentUser.UUID).updateData([
                                        "savedLocations" : newLocations.mapValues({ $0.dictify() })
                                    ]) { _ in }
                                }
                            }
                        }
                        
                        Section {
                            Button(action: {
                                deleteLocation.status = .inProgress
                                
                                var newLocations = currentUser.savedLocations
                                newLocations.removeValue(forKey: savedLocationID)
                                usersCollection.document(currentUser.UUID).updateData([
                                    "savedLocations" : newLocations.mapValues({ $0.dictify() }),
                                    "locationMode" : currentUser.locationMode == .saved(locationID: savedLocationID) ? LocationMode.current.toString() : currentUser.locationMode.toString()
                                ]) { error in
                                    if let error = error {
                                        deleteLocation.setError(message: error.localizedDescription)
                                    } else {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }) {
                                Text("Delete Location")
                            }
                            .alert(isPresented: $deleteLocation.isShowingErrorMessage) {
                                Alert(title: Text("Couldn't Delete Location"),
                                      message: Text(deleteLocation.errorMessage),
                                      dismissButton: .default(Text("Close")))
                            }
                        }
                    }
                }
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Edit Saved Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        var newLocations = currentUser.savedLocations
                        newLocations[savedLocationID]!.nickname = locationName
                        usersCollection.document(currentUser.UUID).updateData([
                            "savedLocations" : newLocations.mapValues({ $0.dictify() })
                        ]) { _ in }
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                    .disabled(deleteLocation.status == .inProgress)
                }
            })
        }
        .onAppear {
            // MARK: View Launch Code
            // Set up a real-time listener for the user's profile!
            usersCollection.document(currentUser.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data(), let savedLocation = currentUser.savedLocations[savedLocationID] {
                        currentUser.replaceFields(User.dedictify(snapshotData))
                        locationName = savedLocation.nickname
                        color = savedLocation.color
                        emoji = savedLocation.emoji
                    }
                }
            })
        }
        .interactiveDismissDisabled(deleteLocation.status == .inProgress)
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct SavedLocationEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SavedLocationEditorView(currentUser: .getSample(),
                                savedLocationID: "E1974DB9-5198-409C-9707-599C56AB84A7-D8C69522-5B0F-4106-9149-A4CA2420F027-3105478D-4B1E-4A08-8AD2-989E41EB2096",
                                locationName: User.getSample().savedLocations["E1974DB9-5198-409C-9707-599C56AB84A7-D8C69522-5B0F-4106-9149-A4CA2420F027-3105478D-4B1E-4A08-8AD2-989E41EB2096"]!.nickname,
                                color: User.getSample().savedLocations["E1974DB9-5198-409C-9707-599C56AB84A7-D8C69522-5B0F-4106-9149-A4CA2420F027-3105478D-4B1E-4A08-8AD2-989E41EB2096"]!.color,
                                emoji: User.getSample().savedLocations["E1974DB9-5198-409C-9707-599C56AB84A7-D8C69522-5B0F-4106-9149-A4CA2420F027-3105478D-4B1E-4A08-8AD2-989E41EB2096"]!.emoji)
    }
}

// MARK: Support Views
// Support views go here! :)
