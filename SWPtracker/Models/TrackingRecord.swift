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
		return NSFetchRequest<TrackingRecord>(entityName: String(describing: TrackingRecord.self))
	}

	static func factory(with label: String, _ start: TimeInterval, _ end: TimeInterval) -> TrackingRecord? {
		guard let entity = NSEntityDescription.entity(forEntityName: String(describing: TrackingRecord.self), in: cdContext) else { return nil }
		let trackingRecord = TrackingRecord(entity: entity, insertInto: cdContext)
		trackingRecord.label = label
		trackingRecord.start = start
		trackingRecord.end = end
		return trackingRecord
	}
}
