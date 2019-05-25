//
//  TrackingRecord.swift
//  SWPtracker
//
//  Created by Ming Sun on 5/22/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import UIKit
import CoreData

public class TrackingRecord: NSManagedObject {
	@NSManaged public var label: String?
	@NSManaged public var start: Double
	@NSManaged public var end: Double
	@NSManaged public var trackingList: TrackingList?

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TrackingRecord> {
		return NSFetchRequest<TrackingRecord>(entityName: "TrackingRecord")
	}

	static func factory(with label: String, _ start: TimeInterval, _ end: TimeInterval) -> TrackingRecord? {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
		let context = appDelegate.persistentContainer.viewContext
		guard let entity = NSEntityDescription.entity(forEntityName: "TrackingRecord", in: context) else { return nil }
		let trackingRecord = TrackingRecord.init(entity: entity, insertInto: context)
		trackingRecord.label = label
		trackingRecord.start = start
		trackingRecord.end = end
		return trackingRecord
	}
}
