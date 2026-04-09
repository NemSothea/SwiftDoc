//
//  GuideModels.swift
//  PestDisease
//

import Foundation

struct GuideBundle: Codable {
    let version: Int
    let crops: [GuideCrop]
    let problems: [GuideProblem]
}

struct GuideCrop: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let sortOrder: Int
}

enum GuideProblemKind: String, Codable {
    case pest
    case disease
}

struct GuideProblem: Codable, Identifiable, Hashable {
    let id: String
    let cropIds: [String]
    let kind: GuideProblemKind
    let name: String
    let summary: String
    let symptoms: [String]
    let causes: String
    let remedies: [String]
    let prevention: [String]
    let imageNames: [String]
}
