//
//  EditTransactionView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

struct EditTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var viewModel: FinanceViewModel

    let transaction: Transaction

    @State private var amount: String
    @State private var note: String
    @State private var selectedType: String
    @State private var selectedExpenseCategory: String
    @State private var selectedIncomeCategory: String

    let types = ["expense", "income"]

    init(transaction: Transaction) {
        self.transaction = transaction
        _amount = State(initialValue: String(transaction.amount))
        _note = State(initialValue: transaction.note ?? "")
        _selectedType = State(initialValue: transaction.type ?? "expense")
        _selectedExpenseCategory = State(initialValue:
            transaction.type == "expense" ? (transaction.category ?? ExpenseCategory.other.rawValue) : ExpenseCategory.other.rawValue)
        _selectedIncomeCategory = State(initialValue:
            transaction.type == "income" ? (transaction.category ?? IncomeCategory.other.rawValue) : IncomeCategory.other.rawValue)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ចំនួនទឹកប្រាក់")) {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("ប្រភេទ")) {
                    Picker("ប្រភេទ", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type == "expense" ? "ចំណាយ" : "ចំណូល").tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

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

                Section(header: Text("កំណត់ចំណាំ")) {
                    TextField("បញ្ចូលកំណត់ចំណាំ...", text: $note)
                }
            }
            .navigationTitle("កែប្រែប្រតិបត្តិការ")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    saveChanges()
                }
                .disabled(amount.isEmpty)
            )
        }
    }

    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        let category = selectedType == "expense" ? selectedExpenseCategory : selectedIncomeCategory

        viewModel.updateTransaction(
            transaction,
            amount: amountValue,
            note: note,
            type: selectedType,
            category: category
        )
        presentationMode.wrappedValue.dismiss()
    }
}
