import SwiftData
import Foundation

@Model
class TrainingSession {
    @Attribute(.unique) var id: UUID
    @Relationship(inverse: \Student.trainingSessions) var student: Student
    var courtLocation: String
    var courtNumber: Int
    var time: String
    var isMessaged: Bool
    var isBooked: Bool

    init(student: Student, courtLocation: String, courtNumber: Int, time: String, isMessaged: Bool = false, isBooked: Bool = false) {
        self.id = UUID()
        self.student = student
        self.courtLocation = courtLocation
        self.courtNumber = courtNumber
        self.time = time
        self.isMessaged = isMessaged
        self.isBooked = isBooked
    }
}
