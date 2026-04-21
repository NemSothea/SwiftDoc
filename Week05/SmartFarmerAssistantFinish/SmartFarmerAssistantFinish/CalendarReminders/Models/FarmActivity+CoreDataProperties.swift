//
//  FarmActivity+CoreDataProperties.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
//

import Foundation
import CoreData


extension FarmActivity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FarmActivity> {
        return NSFetchRequest<FarmActivity>(entityName: "FarmActivity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var activityType: String?
    @NSManaged public var date: Date?
    @NSManaged public var notes: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var reminderEnabled: Bool

}

extension FarmActivity: Identifiable {

}
