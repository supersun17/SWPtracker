//
//  TrackingList.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/22/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit
import CoreData


class TrackingList: NSManagedObject {

    @NSManaged private(set) var listName: String!
    @NSManaged private(set) var records: NSSet?

    var allRecords: [TrackingRecord] { records?.allObjects as? [TrackingRecord] ?? []  }
    var numberOfRecords: Int { records?.count ?? 0 }
    var sortedRecords: [TrackingRecord] { allRecords.sorted { $0.start < $1.start } }
    var totalLength: TimeInterval { allRecords.reduce(0, { $0 + $1.end - $1.start }) }


    convenience init?(withListName listName: String) {
        guard !listName.isEmpty,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: TrackingList.self),
                                                      in: Self.cdContext) else {
            return nil
        }
        self.init(entity: entity, insertInto: Self.cdContext)
        self.listName = listName
        do {
            try Self.cdContext.save()
        } catch {
            print("TrackingList saving failed: \(error.localizedDescription)")
            return nil
        }
    }

    func saveRecord(startTime: TimeInterval, endTime: TimeInterval) {
        if let newRecord = TrackingRecord(withLabel: listName, start: startTime, end: endTime) {
            addToRecords(newRecord)
        }
        do {
            try Self.cdContext.save()
        } catch {
            print("TrackingList saving failed: \(error.localizedDescription)")
        }
    }

    func deleteAllRecords() {
        if let records = records {
            removeFromRecords(records)
        }
        do {
            try Self.cdContext.save()
        } catch {
            print("TrackingList saving failed: \(error.localizedDescription)")
        }
    }

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<TrackingList> {
        return NSFetchRequest<TrackingList>(entityName: String(describing: TrackingList.self))
    }

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackingRecord)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackingRecord)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)
}
