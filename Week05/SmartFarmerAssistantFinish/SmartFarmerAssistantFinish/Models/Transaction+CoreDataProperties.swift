//
//  Transaction+CoreDataProperties.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var type: String?
    @NSManaged public var category: String?
    @NSManaged public var id: UUID?

}

extension Transaction : Identifiable {

}
