//
//  Pest+CoreDataProperties.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
//

import Foundation
import CoreData

extension Pest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pest> {
        return NSFetchRequest<Pest>(entityName: "Pest")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var symptoms: String?
    @NSManaged public var treatment: String?
    @NSManaged public var imageName: String?
    @NSManaged public var pestType: String?
    @NSManaged public var prevention: String?
    @NSManaged public var photoCredit: String?
    @NSManaged public var isFavorite: Bool
}

extension Pest: Identifiable {}
