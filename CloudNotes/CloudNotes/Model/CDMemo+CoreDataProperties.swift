import Foundation
import CoreData

extension CDMemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMemo> {
        return NSFetchRequest<CDMemo>(entityName: "CDMemo")
    }

    @NSManaged public var body: String?
    @NSManaged public var lastModified: Date?
    @NSManaged public var title: String?

}
