//
//  MemoEntity+CoreDataProperties.swift
//  CloudNotes
//
//  Created by YongHoon JJo on 2021/09/15.
//
//

import Foundation
import CoreData

extension MemoEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoEntity> {
        return NSFetchRequest<MemoEntity>(entityName: "Memo")
    }

    @NSManaged public var title: String
    @NSManaged public var body: String
    @NSManaged public var lastModified: Double
}

extension MemoEntity: Identifiable {

}

extension MemoEntity {
    var currentTime: TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    var formatedLastModified: String? {
        let date = Date(timeIntervalSince1970: lastModified)
        return date.transformFormattedType()
    }
}
