import Foundation
import CoreLocation
import SwiftData


@Model
final class AnchorItem {

    var id: UUID
    var title: String
    var note: String
    var latitude: Double
    var longitude: Double
    var date: Date
    var tag: AnchorTag

    var mood: Mood
    var environment: AnchorEnvironment
    var visitCount: Int

    var resolvedAddress: String?


    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var score: Int {
        let base        = 10
        let visitBonus  = min(visitCount * 2, 20)
        let moodBonus   = mood.scoreWeight
        let envBonus    = environment.scoreWeight
        let noteBonus   = note.count > 20 ? 3 : note.isEmpty ? 0 : 1
        let ageWeeks    = Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 0
        let ageBonus    = min(ageWeeks, 5)
        return base + visitBonus + moodBonus + envBonus + noteBonus + ageBonus
    }

    var scoreGrade: String {
        switch score {
        case 35...:  return "S"
        case 28..<35: return "A"
        case 21..<28: return "B"
        case 14..<21: return "C"
        default:     return "D"
        }
    }

    var gradeColor: Color {
        switch scoreGrade {
        case "S": return Color(hex: "#FFD700")
        case "A": return Color(hex: "#00C853")
        case "B": return Color(hex: "#2196F3")
        case "C": return Color(hex: "#FF9800")
        default:  return Color(hex: "#9E9E9E")
        }
    }



    init(
        title: String,
        note: String,
        coordinate: CLLocationCoordinate2D,
        tag: AnchorTag = .memory,
        mood: Mood = .neutral,
        environment: AnchorEnvironment = .unknown
    ) {
        self.id          = UUID()
        self.title       = title
        self.note        = note
        self.latitude    = coordinate.latitude
        self.longitude   = coordinate.longitude
        self.date        = Date()
        self.tag         = tag
        self.mood        = mood
        self.environment = environment
        self.visitCount  = 1
    }
}

import SwiftUI
