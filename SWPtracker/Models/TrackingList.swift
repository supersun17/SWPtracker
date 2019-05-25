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
	static private var listNameSet: Set<String> = []
	private var cachedTimeFragmentsTotalLength: (count: Int, time: TimeInterval) = (0,0)

	@NSManaged public var listName: String!
	@NSManaged public var listOrder: Int16
	@NSManaged public var records: NSSet?

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TrackingList> {
		return NSFetchRequest<TrackingList>(entityName: "TrackingList")
	}

	static func factory(with listName: String) -> TrackingList? {
		if !TrackingList.listNameSet.insert(listName).inserted || listName.isEmpty {
			return nil
		} else {
			guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
			let context = appDelegate.persistentContainer.viewContext
			guard let entity = NSEntityDescription.entity(forEntityName: "TrackingList", in: context) else { return nil }
			let trackingList = TrackingList.init(entity: entity, insertInto: context)
			trackingList.listOrder = Int16(TrackingList.listNameSet.count - 1)
			trackingList.listName = listName

			do {
				try context.save()
			} catch {
				print("TrackingList saveing failed: \(error.localizedDescription)")
				return nil
			}

			return trackingList
		}
	}

	static func fetchAllList() -> [TrackingList] {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
		let context = appDelegate.persistentContainer.viewContext

		var trackingList: [TrackingList] = []
		do {
			let result = try context.fetch(fetchRequest())
			if let list = result as? [TrackingList] {
				trackingList = list
			}
		} catch {
			print("TrackingList saveing failed: \(error.localizedDescription)")
			return []
		}

		return trackingList
	}

	func getRecordsArray() -> [TrackingRecord] {
		if let recordsArray = records?.allObjects as? [TrackingRecord] {
			return recordsArray.sorted { $0.start < $1.start }
		} else {
			return []
		}
	}

	func getTimeFragmentsTotalLength() -> TimeInterval {
		let recordsArray = getRecordsArray()
		if cachedTimeFragmentsTotalLength.count != recordsArray.count {
			let timeFragmentsTotalLength = recordsArray.reduce(0, { (result, record) -> TimeInterval in
				return result + record.end - record.start
			})
			cachedTimeFragmentsTotalLength.count = recordsArray.count
			cachedTimeFragmentsTotalLength.time = timeFragmentsTotalLength
			return timeFragmentsTotalLength
		} else {
			return cachedTimeFragmentsTotalLength.time
		}
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
