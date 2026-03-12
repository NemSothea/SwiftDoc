//
//  PestType.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//


// Models/Pest.swift
import Foundation
import SwiftData

enum PestType: String, CaseIterable {
    case insect = "សត្វល្អិត"      // Insect
    case fungal = "ផ្សិត"           // Fungal
    case bacterial = "បាក់តេរី"     // Bacterial
    case viral = "មេរោគ"            // Viral
}

@Model
class Pest {
    var name: String
    var pestType: String
    var symptoms: String
    var treatment: String
    var prevention: String
    var imageName: String?
    var isFavorite: Bool
    
    init(name: String, pestType: String, symptoms: String, treatment: String, prevention: String = "", imageName: String? = nil, isFavorite: Bool = false) {
        self.name = name
        self.pestType = pestType
        self.symptoms = symptoms
        self.treatment = treatment
        self.prevention = prevention
        self.imageName = imageName
        self.isFavorite = isFavorite
    }
}