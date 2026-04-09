//
//  UserDataActions.swift
//  PestDisease
//

import CoreData
import Foundation

enum UserDataActions {
    static func isFavorite(problemID: String, context: NSManagedObjectContext) -> Bool {
        let request = SavedProblem.fetchRequest()
        request.predicate = NSPredicate(format: "problemID == %@", problemID)
        request.fetchLimit = 1
        return (try? context.count(for: request)) ?? 0 > 0
    }

    static func toggleFavorite(
        problemID: String,
        cropID: String?,
        context: NSManagedObjectContext
    ) throws {
        let request = SavedProblem.fetchRequest()
        request.predicate = NSPredicate(format: "problemID == %@", problemID)
        request.fetchLimit = 1
        if let existing = try context.fetch(request).first {
            context.delete(existing)
        } else {
            let saved = SavedProblem(context: context)
            saved.problemID = problemID
            saved.cropID = cropID
            saved.savedAt = Date()
        }
        if context.hasChanges {
            try context.save()
        }
    }

    static func noteBody(problemID: String, context: NSManagedObjectContext) -> String? {
        let request = ProblemNote.fetchRequest()
        request.predicate = NSPredicate(format: "problemID == %@", problemID)
        request.fetchLimit = 1
        guard let note = try? context.fetch(request).first else { return nil }
        return note.body
    }

    static func saveNote(problemID: String, body: String, context: NSManagedObjectContext) throws {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        let request = ProblemNote.fetchRequest()
        request.predicate = NSPredicate(format: "problemID == %@", problemID)
        request.fetchLimit = 1
        if trimmed.isEmpty {
            if let existing = try context.fetch(request).first {
                context.delete(existing)
            }
        } else if let existing = try context.fetch(request).first {
            existing.body = trimmed
            existing.updatedAt = Date()
        } else {
            let note = ProblemNote(context: context)
            note.problemID = problemID
            note.body = trimmed
            note.updatedAt = Date()
        }
        if context.hasChanges {
            try context.save()
        }
    }
}
