//
//  PestDataLoader.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import Foundation
import CoreData

/// Loads the bundled `pests.json` into Core Data the first time the app launches.
/// Once the preload has run, the `kPestsPreloaded` flag is set in UserDefaults so
/// we don't re-seed on every launch. After the first run the module is fully
/// offline — reads and writes go through the local Core Data store.
enum PestDataLoader {

    private static let preloadKey = "kPestsPreloaded"
    private static let bundledResource = "pests"
    private static let bundledExtension = "json"

    /// Call on app startup. No-op after the first successful run.
    static func preloadIfNeeded(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        guard !UserDefaults.standard.bool(forKey: preloadKey) else { return }

        do {
            let dtos = try loadBundledDTOs()
            try insert(dtos, into: context)
            UserDefaults.standard.set(true, forKey: preloadKey)
        } catch {
            // Don't flip the preload flag on failure — retry next launch.
            print("PestDataLoader: preload failed — \(error)")
        }
    }

    // MARK: - JSON

    private static func loadBundledDTOs() throws -> [PestDTO] {
        guard let url = Bundle.main.url(forResource: bundledResource,
                                        withExtension: bundledExtension) else {
            throw NSError(domain: "PestDataLoader",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "pests.json not found in bundle"])
        }
        let data = try Data(contentsOf: url)
        let bundle = try JSONDecoder().decode(PestBundle.self, from: data)
        return bundle.pests
    }

    // MARK: - Core Data

    private static func insert(_ dtos: [PestDTO], into context: NSManagedObjectContext) throws {
        for dto in dtos {
            let pest = Pest(context: context)
            pest.id         = UUID(uuidString: dto.id) ?? UUID()
            pest.name       = dto.name
            pest.symptoms   = dto.symptoms
            pest.treatment  = dto.treatment
            pest.imageName   = dto.imageName
            pest.pestType    = dto.pestType
            pest.prevention  = dto.prevention
            pest.photoCredit = dto.photoCredit
            pest.isFavorite  = false
        }
        if context.hasChanges {
            try context.save()
        }
    }
}
