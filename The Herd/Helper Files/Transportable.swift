//
//  Transportable.swift
//  CORE
//
//  Created by Ethan Marshall on 5/6/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore

/// An object that can be transported to and from the Firestore server.
///
/// A data type that is `Transportable` is one that can be easily sent to the server and requested from the server using two functions, `transportToServer` and `transportFromServer`!
///
/// To be able to be moved in this way, the type must implement `dictify()` and transform itself into type `[String : Any]`.
///
/// The functions will call standard Firebase functions on the caller's behalf, and will optionally update an `Operation` object along the way. They also support success and failure callbacks.
protocol Transportable {
    /// Prepares the object to be transported by transforming it into a dictionary.
    func dictify() -> [String : Any]
    
    /// Transforms a dictionary version of the type to object form.
    /// - Parameter dictionary: The dictionary representing the Firestore object from the server.
    /// - Returns: The object form of the Firestore dictionary.
    static func dedictify(_ dictionary: [String : Any]) -> Self
}

extension Transportable {
    /// Transports this object to the specified path on the Firestore server.
    /// - Parameters:
    ///   - path: The path at which to place the object.
    ///   - documentID: The ID to use for the document. If left blank, the current date/time will be used.
    ///   - operation: An `Operation` object which is keeping track of the transport.
    ///   - onError: Code to execute if the transport fails.
    ///   - onSuccess: Code to execute if the transport succeeds.
    func transportToServer(path: CollectionReference, documentID: String?, operation: Binding<Operation>?, onError: ((Error) -> ())?, onSuccess: (() -> ())?) {
        
        // Declare the operation in-progress, if there is one!
        operation?.wrappedValue.status = .inProgress
        
        // Call the standard Firestore functions!
        if let documentID = documentID {
            path.document(documentID).setData(self.dictify()) { error in
                if let error = error {
                    // If there was an error, report on the operation and call the callback!
                    operation?.wrappedValue.setError(message: "There was an error connecting to the network. Please check your Internet connection and try again!")
                    onError?(error)
                    
                } else {
                    // If we succeed, report on the operation and call the callback!
                    operation?.wrappedValue.status = .success
                    onSuccess?()
                }
            }
        } else {
            path.addDocument(data: self.dictify()) { error in
                if let error = error {
                    // If there was an error, report on the operation and call the callback!
                    operation?.wrappedValue.setError(message: "There was an error connecting to the network. Please check your Internet connection and try again!")
                    onError?(error)
                    
                } else {
                    // If we succeed, report on the operation and call the callback!
                    operation?.wrappedValue.status = .success
                    onSuccess?()
                }
            }
        }
    }
    
    /// Transports a server document from the Firebase server.
    /// - Parameters:
    ///   - path: The path at which to find the document.
    ///   - operation: An `Operation` object which is keeping track of the transport.
    ///   - onError: Code to execute if the transport fails.
    ///   - onSuccess: Code to execute if the transport succeeds.
    static func transportFromServer(path: DocumentReference, operation: Binding<Operation>?, onError: ((Error) -> ())?, onSuccess: ((Self) -> ())?) {
        
        // Declare the operation in-progress, if there is one!
        operation?.wrappedValue.status = .inProgress
        
        // Call the standard Firestore function!
        path.getDocument { document, error in
            if let error = error {
                // If there was an error, report on the operation and call the callback!
                operation?.wrappedValue.setError(message: "There was an error connecting to the network. Please check your Internet connection and try again!")
                onError?(error)
                
            } else if let document = document, document.exists {
                // If we succeed, report on the operation and call the callback!
                operation?.wrappedValue.status = .success
                onSuccess?(Self.dedictify(document.data()!))
                
            } else {
                // If the document doesn't exist, report on the operation and call the callback!
                operation?.wrappedValue.setError(message: "There was an error connecting to the network. Please check your Internet connection and try again!")
                onError?(NSError(domain: "The requested document does not exist.", code: 1))
            }
        }
    }
    
    /// Transports an entire collection of server documents from the Firebase server.
    /// - Parameters:
    ///   - path: The path at which to find the collection.
    ///   - operation: An `Operation` object which is keeping track of the transport.
    ///   - onError: Code to execute if the transport fails.
    ///   - onSuccess: Code to execute if the transport succeeds.
    static func transportCollectionFromServer(path: CollectionReference, operation: Binding<Operation>?, onError: ((Error) -> ())?, onSuccess: (([Self]) -> ())?) {
        
        // Declare the operation in-progress, if there is one!
        operation?.wrappedValue.status = .inProgress
        
        // Call the standard Firestore function!
        path.getDocuments { documents, error in
            if let error = error {
                // If there was an error, report on the operation and call the callback!
                operation?.wrappedValue.setError(message: "There was an error connecting to the network. Please check your Internet connection and try again!")
                onError?(error)
                
            } else if let documents = documents {
                // If we succeed, report on the operation and call the callback!
                operation?.wrappedValue.status = .success
                onSuccess?(documents.documents.map { Self.dedictify($0.data()) })
                
            } else {
                // If the document doesn't exist, report on the operation and call the callback!
                operation?.wrappedValue.setError(message: "There was an error connecting to the network. Please check your Internet connection and try again!")
                onError?(NSError(domain: "The requested collection does not exist.", code: 1))
            }
        }
    }
}
