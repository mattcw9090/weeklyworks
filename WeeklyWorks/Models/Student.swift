import SwiftData
import Foundation

@Model
class Student {
    @Attribute(.unique) var id: UUID
    var name: String
    var isMale: Bool
    var trainingSessions: [TrainingSession] = []

    init(name: String, isMale: Bool) {
        self.id = UUID()
        self.name = name
        self.isMale = isMale
    }
}
