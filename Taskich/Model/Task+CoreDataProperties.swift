import Foundation
import CoreData

@objc(Taska)
public class Taska: NSManagedObject {}

extension Taska {
    @NSManaged public var id: UUID
    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var isCompleted: Bool
}

extension Taska : Identifiable {

}
