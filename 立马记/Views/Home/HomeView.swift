import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseRecord.dateTime, order: .reverse) private var allRecords: [ExpenseRecord]
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \ExpenseTemplate.sortOrder) private var templates: [ExpenseTemplate]

    @State private var vm = HomeViewModel()
    @State private var showAddExpense = false
    @State private var selectedRecord: ExpenseRecord? = nil
    @State private var templateToUse: ExpenseTemplate? = nil

    private var todayRecords: [ExpenseRecord] { vm.todayRecords(from: allRecords) }
    private var todayTotal: Double { vm.todayTotal(from: allRecords) }
    private var monthTotal: Double { vm.monthTotal(from: allRecords) }
    private var topTemplates: [ExpenseTemplate] { Array(templates.prefix(3)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    addButton
                    if !topTemplates.isEmpty { quickTemplates }
                    todayList
                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("立马记")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedRecord) { record in
                EditRecordView(record: record)
            }
        }
        .sheet(isPresented: $showAddExpense, onDismiss: { templateToUse = nil }) {
            AddExpenseView(prefillTemplate: templateToUse)
        }
    }

    // MARK: - Subviews

    private var summaryCard: some View {
        VStack(spacing: 8) {
            Text("¥\(todayTotal.amountDisplay)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.snappy, value: todayTotal)
            Text("今日支出")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("本月共 ¥\(monthTotal.amountDisplay)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var addButton: some View {
        Button {
            showAddExpense = true
        } label: {
            Label("记一笔", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
    }

    private var quickTemplates: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("快捷模板")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            HStack(spacing: 10) {
                ForEach(topTemplates) { template in
                    Button {
                        templateToUse = template
                        showAddExpense = true
                    } label: {
                        VStack(spacing: 4) {
                            Text(template.name)
                                .font(.subheadline.weight(.medium))
                            if let amt = template.defaultAmount {
                                Text("¥\(amt.amountShort)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private var todayList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日记录")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if todayRecords.isEmpty {
                Text("今天还没有记录，点击上方按钮开始记账")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(todayRecords.enumerated()), id: \.element.id) { index, record in
                        Button { selectedRecord = record } label: {
                            ExpenseRowView(
                                record: record,
                                categoryIcon: icon(for: record)
                            )
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)

                        if index < todayRecords.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            }
        }
    }

    private func icon(for record: ExpenseRecord) -> String {
        guard let id = record.categoryId else { return "ellipsis.circle" }
        return categories.first(where: { $0.id == id })?.icon ?? "ellipsis.circle"
    }
}
