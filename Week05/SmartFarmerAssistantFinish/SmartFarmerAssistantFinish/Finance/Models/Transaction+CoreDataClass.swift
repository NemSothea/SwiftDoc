//
//  Transaction+CoreDataClass.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {

    var isExpense: Bool { type == "expense" }
    var isIncome: Bool { type == "income" }

    var categoryName: String {
        category ?? ""
    }
}
