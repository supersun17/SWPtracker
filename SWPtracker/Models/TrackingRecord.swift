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

	@NSManaged var label: String?
	@NSManaged var start: Double
	@NSManaged var end: Double
	@NSManaged var trackingList: TrackingList?


	convenience init?(withLabel label: String, start: TimeInterval, end: TimeInterval){
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: TrackingRecord.self),
                                                      in: Self.cdContext) else {
            return nil
        }
        self.init(entity: entity, insertInto: Self.cdContext)
		self.label = label
		self.start = start
		self.end = end
	}

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<TrackingRecord> {
        return NSFetchRequest<TrackingRecord>(entityName: String(describing: TrackingRecord.self))
    }
}
