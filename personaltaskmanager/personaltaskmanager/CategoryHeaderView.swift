//
//  CategoryHeaderView.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//

import SwiftUI
import SwiftData

struct CategoryHeaderView: View {
    let category: Category
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: category.color))
                .frame(width: 12, height: 12)
            
            Text(category.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("\(category.tasks?.count ?? 0) tasks")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            
            Menu {
                Button("Edit Category") {
                    showingEditSheet = true
                }
                
                Button("Delete Category", role: .destructive) {
                    deleteCategory(category)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCategoryView(category: category)
        }
    }
    
    private func deleteCategory(_ category: Category) {
        modelContext.delete(category)
    }
}
