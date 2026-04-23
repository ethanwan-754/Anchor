import Foundation
import SwiftUI


enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(AppError)
}

enum AppError: Error, LocalizedError {
    case locationUnavailable
    case locationPermissionDenied
    case geocodingFailed
    case networkUnavailable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .locationUnavailable:      return "Your location is not available right now."
        case .locationPermissionDenied: return "Location access was denied. Enable it in Settings."
        case .geocodingFailed:          return "Could not detect your environment automatically."
        case .networkUnavailable:       return "No internet connection. Some features may be limited."
        case .unknown(let msg):         return msg
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .locationPermissionDenied: return "Go to Settings → Privacy → Location Services"
        case .geocodingFailed:          return "You can still set the environment manually."
        default:                        return nil
        }
    }
}

enum AppFlowState: Equatable {
    case map
    case addAnchor
    case detail(AnchorItem)
    case stats

    static func == (lhs: AppFlowState, rhs: AppFlowState) -> Bool {
        switch (lhs, rhs) {
        case (.map, .map),
             (.addAnchor, .addAnchor),
             (.stats, .stats):
            return true
        case (.detail(let a), .detail(let b)):
            return a.id == b.id
        default:
            return false
        }
    }
}



enum Mood: String, CaseIterable, Codable {
    case joyful     = "Joyful"
    case calm       = "Calm"
    case reflective = "Reflective"
    case anxious    = "Anxious"
    case energized  = "Energized"
    case melancholic = "Melancholic"
    case grateful   = "Grateful"
    case neutral    = "Neutral"

    var emoji: String {
        switch self {
        case .joyful:      return "😄"
        case .calm:        return "😌"
        case .reflective:  return "🤔"
        case .anxious:     return "😰"
        case .energized:   return "⚡️"
        case .melancholic: return "😔"
        case .grateful:    return "🙏"
        case .neutral:     return "😐"
        }
    }

    var scoreWeight: Int {
        switch self {
        case .joyful, .energized, .grateful: return 3
        case .calm, .reflective:             return 2
        case .neutral:                       return 1
        case .melancholic, .anxious:         return 0
        }
    }

    var color: Color {
        switch self {
        case .joyful:      return Color(hex: "#FFD166")
        case .calm:        return Color(hex: "#06D6A0")
        case .reflective:  return Color(hex: "#118AB2")
        case .anxious:     return Color(hex: "#EF476F")
        case .energized:   return Color(hex: "#FF6B35")
        case .melancholic: return Color(hex: "#9B89B4")
        case .grateful:    return Color(hex: "#4ECDC4")
        case .neutral:     return Color(hex: "#A8A8A8")
        }
    }
}



enum AnchorEnvironment: String, CaseIterable, Codable {
    case urban    = "Urban"
    case nature   = "Nature"
    case indoor   = "Indoor"
    case coastal  = "Coastal"
    case suburban = "Suburban"
    case rural    = "Rural"
    case transit  = "Transit"
    case unknown  = "Unknown"

    var systemIcon: String {
        switch self {
        case .urban:    return "building.2.fill"
        case .nature:   return "leaf.fill"
        case .indoor:   return "house.fill"
        case .coastal:  return "water.waves"
        case .suburban: return "house.and.flag.fill"
        case .rural:    return "mountain.2.fill"
        case .transit:  return "tram.fill"
        case .unknown:  return "questionmark.circle.fill"
        }
    }

    var scoreWeight: Int {
        switch self {
        case .nature, .coastal: return 3
        case .rural, .suburban: return 2
        case .indoor, .urban:   return 1
        case .transit, .unknown: return 0
        }
    }

   
    static func detect(from placemarks: [String]) -> AnchorEnvironment {
        let joined = placemarks.joined(separator: " ").lowercased()
        if joined.contains("ocean") || joined.contains("beach") || joined.contains("coast") || joined.contains("bay") {
            return .coastal
        } else if joined.contains("park") || joined.contains("forest") || joined.contains("trail") || joined.contains("nature") {
            return .nature
        } else if joined.contains("mountain") || joined.contains("rural") || joined.contains("farm") {
            return .rural
        } else if joined.contains("airport") || joined.contains("station") || joined.contains("transit") {
            return .transit
        } else if joined.contains("suburb") || joined.contains("residential") {
            return .suburban
        } else if joined.contains("city") || joined.contains("downtown") || joined.contains("street") {
            return .urban
        }
        return .unknown
    }
}



enum AnchorTag: String, CaseIterable, Codable {
    case memory     = "Memory"
    case work       = "Work"
    case food       = "Food"
    case travel     = "Travel"
    case personal   = "Personal"
    case social     = "Social"
    case health     = "Health"
    case inspiration = "Inspiration"

    var systemIcon: String {
        switch self {
        case .memory:      return "heart.fill"
        case .work:        return "briefcase.fill"
        case .food:        return "fork.knife"
        case .travel:      return "airplane"
        case .personal:    return "person.fill"
        case .social:      return "person.2.fill"
        case .health:      return "cross.fill"
        case .inspiration: return "lightbulb.fill"
        }
    }

    var color: Color {
        switch self {
        case .memory:      return Color(hex: "#FF6B6B")
        case .work:        return Color(hex: "#4ECDC4")
        case .food:        return Color(hex: "#FFE66D")
        case .travel:      return Color(hex: "#A8E6CF")
        case .personal:    return Color(hex: "#C3A6FF")
        case .social:      return Color(hex: "#FFB347")
        case .health:      return Color(hex: "#87CEEB")
        case .inspiration: return Color(hex: "#FF85A1")
        }
    }
}
