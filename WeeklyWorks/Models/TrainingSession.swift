import SwiftData
import Foundation

@Model
class TrainingSession {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade, inverse: \Student.trainingSessions)
    var student: Student

    var courtLocation: String
    var courtNumber: Int
    var startTime: String
    var endTime: String
    var isMessaged: Bool
    var isBooked: Bool

    init(student: Student, courtLocation: String, courtNumber: Int, startTime: String, endTime: String,
         isMessaged: Bool = false, isBooked: Bool = false) {
        self.id = UUID()
        self.student = student
        self.courtLocation = courtLocation
        self.courtNumber = courtNumber
        self.startTime = startTime
        self.endTime = endTime
        self.isMessaged = isMessaged
        self.isBooked = isBooked
    }
}
