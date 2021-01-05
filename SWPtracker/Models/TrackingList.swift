//
//  TrackingList.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/22/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit
import CoreData

public class TrackingList: NSManagedObject {
	@NSManaged public var listName: String!
	@NSManaged public var listOrder: Int16
	@NSManaged public var records: NSSet?
    static private var listNameSet: Set<String> = []
    var sortedRecords: [TrackingRecord] {
        if let recordsArray = records?.allObjects as? [TrackingRecord] {
            return recordsArray.sorted { $0.start < $1.start }
        } else {
            return []
        }
    }
    var numberOfRecords: Int { records?.allObjects.count ?? 0 }
    var totalLength: TimeInterval {
        let recordsArray = records?.allObjects as? [TrackingRecord] ?? []
        return recordsArray.reduce(0, { $0 + $1.end - $1.start })
    }

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TrackingList> {
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


	static func factory(with listName: String) -> TrackingList? {
        guard TrackingList.listNameSet.insert(listName).inserted,
              !listName.isEmpty,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: String(describing: TrackingList.self)), in: cdContext) else {
            return nil
        }
        let trackingList = TrackingList(entity: entity, insertInto: cdContext)
        trackingList.listOrder = Int16(TrackingList.listNameSet.count - 1)
        trackingList.listName = listName
        do {
            try cdContext.save()
        } catch {
            print("TrackingList saving failed: \(error.localizedDescription)")
            return nil
        }

        return trackingList
	}

	static func fetchAllList() -> [TrackingList] {
		var trackingLists: [TrackingList] = []
		do {
			let result = try cdContext.fetch(fetchRequest())
			if let list = result as? [TrackingList] {
				trackingLists = list
			}
		} catch {
			print("TrackingLists fetching failed: \(error.localizedDescription)")
			return []
		}

		return trackingLists
	}
}
