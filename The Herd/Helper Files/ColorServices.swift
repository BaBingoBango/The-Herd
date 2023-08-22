//
//  ColorServices.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/9/23.
//

import Foundation
import SwiftUI

extension Color: Codable, Transportable {
    
    static func calculateRatioColor(count: Int, maximum: Double) -> Color {
        let ratio = min(Double(count) / maximum, 1.0)
        return Color(hue: ratio * 0.82, saturation: 1, brightness: 1)
    }
    
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
    
    func dictify() -> [String : Any] {
        return [
            "red" : Double(UIColor(self).cgColor.components![0]),
            "green" : Double(UIColor(self).cgColor.components![1]),
            "blue" : Double(UIColor(self).cgColor.components![2]),
            "alpha" : Double(UIColor(self).cgColor.components![3])
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Self {
        return Color(cgColor: .init(red: dictionary["red"] as! Double, green: dictionary["green"] as! Double, blue: dictionary["blue"] as! Double, alpha: dictionary["alpha"] as! Double))
    }
    
    func toString() -> String {
        switch self {
        case .blue: return "blue"
        case .brown: return "brown"
        case .cyan: return "cyan"
        case .green: return "green"
        case .indigo: return "indigo"
        case .mint: return "mint"
        case .orange: return "orange"
        case .pink: return "pink"
        case .purple: return "purple"
        case .red: return "red"
        case .teal: return "teal"
        case .yellow: return "yellow"
        default: return "unknown"
        }
    }
    
    static func fromString(_ string: String) -> Color {
        switch string {
        case "blue": return .blue
        case "brown": return .brown
        case "cyan": return .cyan
        case "green": return .green
        case "indigo": return .indigo
        case "mint": return .mint
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        case "teal": return .teal
        case "yellow": return .yellow
        default: return .clear
        }
    }
}
