import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {}

extension Task {
    @NSManaged public var id: UUID
    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isInTrash: Bool
}

extension Task : Identifiable {}
