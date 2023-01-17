//
//  TrackingDataBase.swift
//  SWPtracker
//
//  Created by Ming Sun on 1/17/23.
//  Copyright © 2023 Ming Sun. All rights reserved.
//

import UIKit
import CoreData


class TrackingDataBase {

    private(set) var lists: [TrackingList] = []
    private(set) var listNames: [String] = []


    func createList(with listName: String) -> TrackingList? {
        guard !listName.isEmpty,
              !listNames.contains(listName) else {
            return nil
        }
        let trackingList = TrackingList(withListName: listName)
        do {
            try NSManagedObject.cdContext.save()
        } catch {
            print("TrackingList saving failed: \(error.localizedDescription)")
            return nil
        }
        if let list = trackingList {
            lists.append(list)
            listNames.append(list.listName)
        }
        return trackingList
    }

    func fetchAllList() -> [TrackingList] {
        var trackingLists: [TrackingList] = []
        do {
            trackingLists = try NSManagedObject.cdContext.fetch(TrackingList.fetchRequest())
        } catch {
            print("TrackingLists fetching failed: \(error.localizedDescription)")
            return []
        }
        trackingLists.forEach {
            lists.append($0)
            listNames.append($0.listName)
        }
        return trackingLists
    }

    func delete(withListName listName: String) {
        var trackingList: [TrackingList] = []
        do {
            let request = TrackingList.fetchRequest()
            request.predicate = NSPredicate(format: "listName LIKE %@", listName)
            trackingList = try NSManagedObject.cdContext.fetch(request)
        } catch {
            print("TrackingList search failed: \(error.localizedDescription)")
        }
        trackingList.forEach { NSManagedObject.cdContext.delete($0) }
        do {
            // TODO: if cdContext.hasChanges is false, throw error
            try NSManagedObject.cdContext.save()
        } catch {
            print("TrackingList deletion commit failed: \(error.localizedDescription)")
        }
        listNames.removeAll { $0 == listName }
    }
    func delete(_ list: TrackingList) {
        NSManagedObject.cdContext.delete(list)
        do {
            // TODO: if cdContext.hasChanges is false, throw error
            try NSManagedObject.cdContext.save()
        } catch {
            print("TrackingList deletion commit failed: \(error.localizedDescription)")
        }
        listNames.removeAll { $0 == list.listName }
    }
}
