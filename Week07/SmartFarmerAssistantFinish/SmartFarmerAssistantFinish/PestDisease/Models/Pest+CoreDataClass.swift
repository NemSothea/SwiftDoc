//
//  Pest+CoreDataClass.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
//

import Foundation
import CoreData

@objc(Pest)
public class Pest: NSManagedObject {

    var displayName: String { name ?? "" }

    var hasImage: Bool {
        guard let imageName, !imageName.isEmpty else { return false }
        return true
    }
}
