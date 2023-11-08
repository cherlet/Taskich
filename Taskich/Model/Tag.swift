import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {}

extension Tag {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: String
}

extension Tag : Identifiable {}
