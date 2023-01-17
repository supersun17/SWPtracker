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

	@NSManaged public var listName: String!
	@NSManaged public var listOrder: Int16
	@NSManaged public var records: NSSet?
    static private(set) var listNames: [String] = []
    var allRecords: [TrackingRecord] { records?.allObjects as? [TrackingRecord] ?? []  }
    var sortedRecords: [TrackingRecord] { allRecords.sorted { $0.start < $1.start } }
    var numberOfRecords: Int { allRecords.count }
    var totalLength: TimeInterval { allRecords.reduce(0, { $0 + $1.end - $1.start }) }

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
        guard !listName.isEmpty,
              !Self.listNames.contains(listName),
              let entity = NSEntityDescription.entity(forEntityName: String(describing: TrackingList.self), in: cdContext) else {
            return nil
        }
        let trackingList = TrackingList(entity: entity, insertInto: cdContext)
        trackingList.listOrder = Int16(Self.listNames.count - 1)
        trackingList.listName = listName
        Self.listNames.append(listName)
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
		    trackingLists = try cdContext.fetch(fetchRequest())
            trackingLists.forEach { Self.listNames.append($0.listName) }
		} catch {
			print("TrackingLists fetching failed: \(error.localizedDescription)")
			return []
		}
		return trackingLists
	}

    func delete() {
        let listNameBeforeDeletion = listName!
        Self.cdContext.delete(self)
        do {
            try Self.cdContext.save()
        } catch {
            print("TrackingList saving failed: \(error.localizedDescription)")
        }
        Self.listNames.removeAll { $0 == listNameBeforeDeletion }
    }
}


extension NSManagedObject {

    static var cdContext: NSManagedObjectContext { (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
}
