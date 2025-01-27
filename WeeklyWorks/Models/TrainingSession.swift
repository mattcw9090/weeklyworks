import SwiftData
import Foundation

enum DayOfWeek: String, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

extension DayOfWeek {
    var order: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }
}

enum CourtLocation: String, CaseIterable {
    case canningvale = "PBA Canningvale"
    case malaga = "PBA Malaga"
}

@Model
class TrainingSession {
    @Attribute(.unique) var id: UUID
    var student: Student?
    var courtLocationRaw: String
    var courtNumber: Int?
    var startTimeRaw: Date
    var endTimeRaw: Date
    var dayOfWeekRaw: String
    var isMessaged: Bool
    var isBooked: Bool

    var courtLocation: CourtLocation {
        get {
            CourtLocation(rawValue: courtLocationRaw) ?? .canningvale
        }
        set {
            courtLocationRaw = newValue.rawValue
        }
    }

    var dayOfWeek: DayOfWeek {
        get {
            DayOfWeek(rawValue: dayOfWeekRaw) ?? .monday
        }
        set {
            dayOfWeekRaw = newValue.rawValue
        }
    }

    var startTime: Date {
        get {
            startTimeRaw
        }
        set {
            startTimeRaw = newValue
        }
    }

    var endTime: Date {
        get {
            endTimeRaw
        }
        set {
            endTimeRaw = newValue
        }
    }

    init(student: Student?, courtLocation: CourtLocation, courtNumber: Int? = nil, startTime: Date, endTime: Date,
         dayOfWeek: DayOfWeek, isMessaged: Bool = false, isBooked: Bool = false) {
        self.id = UUID()
        self.student = student
        self.courtLocationRaw = courtLocation.rawValue
        self.courtNumber = courtNumber
        self.startTimeRaw = startTime
        self.endTimeRaw = endTime
        self.dayOfWeekRaw = dayOfWeek.rawValue
        self.isMessaged = isMessaged
        self.isBooked = isBooked
    }
}
