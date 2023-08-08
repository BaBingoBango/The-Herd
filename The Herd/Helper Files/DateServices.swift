//
//  DateServices.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import Foundation
import FirebaseFirestore

extension Date {
    static func decodeDate(_ firebaseDate: Any) -> Date {
        return (firebaseDate as? Timestamp)?.dateValue() ?? {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
            return formatter.date(from: firebaseDate as! String)!
        }()
    }
    
    static func randomBackdate() -> Date {
        return Date() - TimeInterval((60 * Int.random(in: 0...500)))
    }
}
