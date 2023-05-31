//
//  The_HerdApp.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions

@main
struct The_HerdApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Text("hello, old yak!")
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // TODO: App Launch Code
                    // Upload a bunch of test posts to the posts directory!
                    if false {
                        for eachIndex in 1...30 {
                            let newPost = Post(author: .init(UUID: "USER-ID-2", phoneNumber: "313-605-9030", emoji: "📡", color: .cyan), text: Taylor.lyrics.randomElement()!, votes: [
                                "VOTE-ID" : .init(UUID: "VOTE-ID", userUUID: "USER-ID-2", isUpvote: true, timePosted: Date())
                            ], timePosted: Date(), latitude: 32.50802, longitude: 73.40223)
                            
                            newPost.transportToServer(path: Firestore.firestore().collection("posts"),
                                                      documentID: newPost.UUID,
                                                      operation: nil,
                                                      onError: { error in fatalError("post upload error! - \(error.localizedDescription)")},
                                                      onSuccess: { print("post \(eachIndex) uploaded successfully!") })
                        }
                    }
                    
                    // Check downloading posts!
                    if true {
                        // Call the cloud function!
                        Functions.functions().httpsCallable("testFunction").call(["latitude" : "32.50802", "longitude" : "73.40223"]) { result, error in
                            
                            // Check for errors!
                            if let error = error {
                                fatalError(error.localizedDescription)
                            } else {
                                
                                // Print the result!
                                print((result!.data as! [String : Any])["message"]!)
                            }
                        }
                    }
                }
        }
    }
}

// MARK: App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: App Launch Code
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Start up Firebase!
        FirebaseApp.configure()

        // We did it!
        return true
    }
}
