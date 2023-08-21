//
//  FontPreference.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/20/23.
//

import Foundation
import SwiftUI

enum FontPreference {
    case regular
    case rounded
    case serif
    case monospace
    
    func toFontDesign() -> Font.Design {
        switch self {
        case .regular:
            return .default
        case .rounded:
            return .rounded
        case .serif:
            return .serif
        case .monospace:
            return .monospaced
        }
    }
    
    func toString() -> String {
        switch self {
        case .regular:
            return "default"
        case .rounded:
            return "rounded"
        case .serif:
            return "serif"
        case .monospace:
            return "monospace"
        }
    }
    
    static func fromString(_ string: String) -> FontPreference {
        switch string {
        case "default": return .regular
        case "rounded": return .rounded
        case "serif": return .serif
        case "monospace": return .monospace
        default: return .regular
        }
    }
}
