// Journal/Models/JournalEntry+CoreDataProperties.swift
import Foundation
import CoreData

extension JournalEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntry> {
        NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var weather: String?
    @NSManaged public var location: String?
    @NSManaged public var photos: NSObject?
}

extension JournalEntry: Identifiable {}
