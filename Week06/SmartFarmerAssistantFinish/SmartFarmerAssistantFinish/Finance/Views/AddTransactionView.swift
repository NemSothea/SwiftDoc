//
//  AddTransactionView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

// Views/AddTransactionView.swift
import SwiftUI
import CoreData

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var amount = ""
    @State private var note = ""
    @State private var selectedType = "expense"
    @State private var selectedExpenseCategory = ExpenseCategory.other.rawValue
    @State private var selectedIncomeCategory = IncomeCategory.other.rawValue
    
    let types = ["expense", "income"]
    
    var body: some View {
        NavigationView {
            Form {
                // Amount Section
                Section(header: Text("ចំនួនទឹកប្រាក់")) {
                    TextField("0", text: $amount)
                        .keyboardType(.numberPad)
                }
                
                // Type Section
                Section(header: Text("ប្រភេទ")) {
                    Picker("ប្រភេទ", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type == "expense" ? "ចំណាយ" : "ចំណូល").tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Category Section
                Section(header: Text("ប្រភេទរង")) {
                    if selectedType == "expense" {
                        Picker("ជ្រើសរើស", selection: $selectedExpenseCategory) {
                            ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                                Text(category.rawValue).tag(category.rawValue)
                            }
                        }
                    } else {
                        Picker("ជ្រើសរើស", selection: $selectedIncomeCategory) {
                            ForEach(IncomeCategory.allCases, id: \.rawValue) { category in
                                Text(category.rawValue).tag(category.rawValue)
                            }
                        }
                    }
                }
                
                // Note Section
                Section(header: Text("កំណត់ចំណាំ")) {
                    TextField("បញ្ចូលកំណត់ចំណាំ...", text: $note)
                }
            }
            .navigationTitle("បន្ថែមប្រតិបត្តិការ")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    saveTransaction()
                }
                .disabled(amount.isEmpty)
            )
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let category = selectedType == "expense" ? selectedExpenseCategory : selectedIncomeCategory
        
        // Create new transaction
        let transaction = Transaction(context: viewContext)
        transaction.amount = amountValue
        transaction.date = Date()
        transaction.note = note
        transaction.type = selectedType
        transaction.category = category
        transaction.id = UUID()
        
        // Save to Core Data
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
}
