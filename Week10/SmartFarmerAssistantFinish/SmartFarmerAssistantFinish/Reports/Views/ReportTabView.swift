// Reports/Views/ReportTabView.swift
import SwiftUI
import CoreData

struct ReportTabView: View {

    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var transactions: FetchedResults<Transaction>

    @StateObject private var vm = ReportViewModel()

    @State private var showShare  = false
    @State private var shareItems: [Any] = []
    @State private var isExporting = false

    // MARK: - Derived data

    private var allTransactions: [Transaction] { Array(transactions) }

    private var monthlyReports: [MonthlyReport] {
        vm.buildMonthlyReports(allTransactions)
    }

    private var selectedReport: MonthlyReport {
        vm.selectedReport(from: monthlyReports)
    }

    private var monthTransactions: [Transaction] {
        vm.transactions(for: vm.selectedMonth, from: allTransactions)
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Month navigator
                    MonthPickerView(
                        selectedMonth: $vm.selectedMonth,
                        canGoNext: vm.canGoToNextMonth,
                        onPrevious: vm.goToPreviousMonth,
                        onNext: vm.goToNextMonth
                    )
                    .padding(.horizontal)
                    .fadeIn(delay: 0.05)

                    // Bar chart (last 6 months or all if fewer)
                    FarmCard(
                        title: "ចំណូល / ចំណាយ ប្រចាំខែ",
                        icon: "chart.bar.fill",
                        iconColor: .orange
                    ) {
                        if monthlyReports.isEmpty {
                            emptyChartPlaceholder
                        } else {
                            BarChartView(entries: Array(monthlyReports.suffix(6)))
                                .frame(height: 200)
                        }
                    }
                    .padding(.horizontal)
                    .fadeIn(delay: 0.1)

                    // Monthly summary card
                    SummaryCardView(report: selectedReport)
                        .padding(.horizontal)
                        .fadeIn(delay: 0.15)

                    // Export buttons
                    exportButtons
                        .padding(.horizontal)
                        .fadeIn(delay: 0.2)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("របាយការណ៍")
            .sheet(isPresented: $showShare) {
                ShareSheet(items: shareItems)
            }
            .loadingOverlay(isLoading: isExporting)
        }
    }

    // MARK: - Export Buttons

    private var exportButtons: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "នាំចេញទិន្នន័យ",
                icon: "square.and.arrow.up",
                color: .blue
            )

            HStack(spacing: 12) {
                // CSV export
                PrimaryButton(
                    title: "CSV",
                    icon: "tablecells",
                    color: .blue
                ) {
                    exportCSV()
                }

                // PDF export
                PrimaryButton(
                    title: "PDF",
                    icon: "doc.richtext",
                    color: .orange
                ) {
                    exportPDF()
                }
            }

            Text("ចែករំលែកតាម AirDrop, Mail, WhatsApp ឬ Files")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    // MARK: - Empty state

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("មិនទាន់មានប្រតិបត្តិការ")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Export actions

    private func exportCSV() {
        isExporting = true
        DispatchQueue.global(qos: .userInitiated).async {
            let csv = CSVExporter.makeTransactionCSV(allTransactions)
            let url = CSVExporter.writeToTempFile(csv, named: "farm_report")
            DispatchQueue.main.async {
                isExporting = false
                if let url = url {
                    shareItems = [url]
                    showShare  = true
                }
            }
        }
    }

    private func exportPDF() {
        isExporting = true
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfData = PDFGenerator.makeReportPDF(
                title:    "Farm Monthly Report",
                subtitle: selectedReport.monthYearLabel,
                rows:     vm.summaryRows(from: selectedReport),
                reports:  monthlyReports
            )
            let url = PDFGenerator.writeTempFile(pdfData, named: "farm_report")
            DispatchQueue.main.async {
                isExporting = false
                if let url = url {
                    shareItems = [url]
                    showShare  = true
                }
            }
        }
    }
}
