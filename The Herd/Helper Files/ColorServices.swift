//
//  ColorServices.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/9/23.
//

import Foundation
import SwiftUI

extension Color: Codable {
    
    enum CodingKeys: CodingKey {
        case red
        case green
        case blue
        case opacity
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(UIColor(self).cgColor.components![0], forKey: .red)
        try container.encode(UIColor(self).cgColor.components![1], forKey: .green)
        try container.encode(UIColor(self).cgColor.components![2], forKey: .blue)
        try container.encode(UIColor(self).cgColor.components![3], forKey: .opacity)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let red = try values.decode(Double.self, forKey: .red)
        let green = try values.decode(Double.self, forKey: .green)
        let blue = try values.decode(Double.self, forKey: .blue)
        let opacity = try values.decode(Double.self, forKey: .opacity)
        
        self = .init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
