//
//  PestDTO.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import Foundation

struct PestBundle: Codable {
    let version: Int
    let pests: [PestDTO]
}

struct PestDTO: Codable {
    let id: String
    let name: String
    let pestType: String?
    let symptoms: String
    let treatment: String
    let prevention: String?
    let imageName: String?
    let photoCredit: String?
}
