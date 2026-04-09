import SwiftUI
import SwiftData
import WidgetKit

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \ExpenseTemplate.sortOrder) private var templates: [ExpenseTemplate]
    @Query(sort: \ExpenseRecord.dateTime, order: .reverse) private var allRecords: [ExpenseRecord]

    @State private var vm = AddExpenseViewModel()
    @State private var showSavedToast = false

    var prefillTemplate: ExpenseTemplate?
    var onSaved: (() -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                amountHeader
                Divider()
                ScrollView {
                    VStack(spacing: 20) {
                        if !templates.isEmpty { templateBar }
                        categorySection
                        noteField
                    }
                    .padding(.vertical, 16)
                }
                Divider()
                bottomSection
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("记一笔")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .overlay(alignment: .top) {
                if showSavedToast {
                    toastView
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
            .animation(.spring(duration: 0.3), value: showSavedToast)
        }
        .onAppear {
            if let t = prefillTemplate {
                let catName = categories.first(where: { $0.id == t.defaultCategoryId })?.name
                vm.applyTemplate(t, categoryName: catName)
            }
        }
    }

    // MARK: - Subviews

    private var amountHeader: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("¥")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(vm.displayAmount)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(vm.amountString.isEmpty ? .secondary : .primary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: vm.amountString)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)

            Text("今天 " + Date().formatted(.dateTime.hour().minute()))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }

    private var templateBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(templates) { template in
                    TemplateChip(template: template) {
                        let catName = categories.first(where: { $0.id == template.defaultCategoryId })?.name
                        vm.applyTemplate(template, categoryName: catName)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("分类")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            CategoryGridView(
                categories: categories,
                selectedId: vm.selectedCategoryId
            ) { cat in
                vm.selectCategory(id: cat.id, name: cat.name)
            }
            .padding(.horizontal)
        }
    }

    private var noteField: some View {
        TextField("备注（选填）", text: $vm.note)
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .onChange(of: vm.note) { _, v in
                if v.count > 100 { vm.note = String(v.prefix(100)) }
            }
    }

    private var bottomSection: some View {
        VStack(spacing: 10) {
            NumpadView(onInput: { vm.inputKey($0) }, onDelete: { vm.deleteKey() })
                .padding(.horizontal)

            Button(action: saveExpense) {
                Text("保存")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(vm.canSave ? Color.accentColor : Color(.systemGray4))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!vm.canSave)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private var toastView: some View {
        Label("已记录 ✓", systemImage: "checkmark.circle.fill")
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    // MARK: - Widget 数据刷新

    private func refreshWidgetData() {
        let cal = Calendar.current
        let now = Date()
        let todayStart = cal.startOfDay(for: now)
        let monthStart: Date = {
            var c = cal.dateComponents([.year, .month], from: now)
            return cal.date(from: c)!
        }()

        let todayTotal = allRecords
            .filter { $0.dateTime >= todayStart }
            .reduce(0.0) { $0 + $1.amount }

        let monthTotal = allRecords
            .filter { $0.dateTime >= monthStart }
            .reduce(0.0) { $0 + $1.amount }

        let recent = Array(allRecords.prefix(3)).map {
            WidgetSharedRecord(snapshot: $0.categorySnapshot, amount: $0.amount)
        }

        WidgetDataStore.save(todayTotal: todayTotal, monthTotal: monthTotal, recent: recent)
    }

    // MARK: - Actions

    private func saveExpense() {
        guard let amount = vm.amount else { return }

        let record = ExpenseRecord(
            amount: amount,
            categoryId: vm.selectedCategoryId,
            categorySnapshot: vm.selectedCategorySnapshot,
            note: vm.note.isEmpty ? nil : vm.note,
            dateTime: Date(),
            source: "app"
        )
        modelContext.insert(record)
        try? modelContext.save()

        refreshWidgetData()
        WidgetCenter.shared.reloadAllTimelines()

        showSavedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            vm.reset()
            showSavedToast = false
            dismiss()
            onSaved?()
        }
    }
}

// MARK: - TemplateChip

struct TemplateChip: View {
    let template: ExpenseTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.subheadline.weight(.medium))
                if let amt = template.defaultAmount {
                    Text("¥\(amt.amountShort)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
