import SwiftUI
import SwiftData

struct TemplateManageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseTemplate.sortOrder) private var templates: [ExpenseTemplate]
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var showAddSheet = false
    @State private var editingTemplate: ExpenseTemplate? = nil

    var body: some View {
        List {
            ForEach(templates) { template in
                TemplateRow(template: template, categoryName: categoryName(for: template.defaultCategoryId))
                    .onTapGesture { editingTemplate = template }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(template)
                            try? modelContext.save()
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
            }
            .onMove(perform: moveTemplate)
        }
        .navigationTitle("模板管理")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if templates.count < 8 { showAddSheet = true }
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(templates.count >= 8)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddSheet) {
            TemplateEditSheet(template: nil, categories: categories, onSave: addTemplate)
        }
        .sheet(item: $editingTemplate) { t in
            TemplateEditSheet(template: t, categories: categories) { name, amount, catId, note in
                t.name = name
                t.defaultAmount = amount
                t.defaultCategoryId = catId
                t.defaultNote = note
                try? modelContext.save()
            }
        }
    }

    private func categoryName(for id: UUID) -> String {
        categories.first(where: { $0.id == id })?.name ?? "未知分类"
    }

    private func addTemplate(name: String, amount: Double?, categoryId: UUID, note: String?) {
        let maxOrder = templates.map(\.sortOrder).max() ?? -1
        let t = ExpenseTemplate(
            name: name,
            defaultAmount: amount,
            defaultCategoryId: categoryId,
            defaultNote: note,
            sortOrder: maxOrder + 1
        )
        modelContext.insert(t)
        try? modelContext.save()
    }

    private func moveTemplate(from source: IndexSet, to destination: Int) {
        var sorted = templates.sorted(by: { $0.sortOrder < $1.sortOrder })
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, t) in sorted.enumerated() { t.sortOrder = index }
        try? modelContext.save()
    }
}

// MARK: - TemplateRow

private struct TemplateRow: View {
    let template: ExpenseTemplate
    let categoryName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(template.name)
                .font(.subheadline.weight(.medium))
            HStack(spacing: 6) {
                if let amt = template.defaultAmount {
                    Text("¥\(amt.amountShort)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(categoryName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - TemplateEditSheet

struct TemplateEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let template: ExpenseTemplate?
    let categories: [Category]
    let onSave: (String, Double?, UUID, String?) -> Void

    @State private var name: String = ""
    @State private var amountString: String = ""
    @State private var selectedCategoryId: UUID? = nil
    @State private var note: String = ""

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && selectedCategoryId != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                amountSection
                categorySection
                noteSection
            }
            .navigationTitle(template == nil ? "新增模板" : "编辑模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear { loadTemplate() }
        }
    }

    // MARK: Form sections (拆开避免编译器推断超时)

    private var nameSection: some View {
        Section("模板名称") {
            TextField("如：午饭、瑞幸", text: $name)
        }
    }

    private var amountSection: some View {
        Section("默认金额（选填）") {
            TextField("留空则记账时手动输入", text: $amountString)
                .keyboardType(.decimalPad)
        }
    }

    private var categorySection: some View {
        Section("默认分类") {
            ForEach(categories) { cat in
                CategoryPickerRow(
                    category: cat,
                    isSelected: selectedCategoryId == cat.id,
                    onTap: { selectedCategoryId = cat.id }
                )
            }
        }
    }

    private var noteSection: some View {
        Section("默认备注（选填）") {
            TextField("留空则不填备注", text: $note)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("取消") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("保存", action: saveTemplate)
                .disabled(!canSave)
        }
    }

    // MARK: Actions

    private func saveTemplate() {
        guard let catId = selectedCategoryId else { return }
        let amount = Double(amountString)
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        onSave(trimmedName, amount, catId, trimmedNote.isEmpty ? nil : trimmedNote)
        dismiss()
    }

    private func loadTemplate() {
        if let t = template {
            name = t.name
            if let amt = t.defaultAmount { amountString = amt.amountShort }
            selectedCategoryId = t.defaultCategoryId
            note = t.defaultNote ?? ""
        } else if selectedCategoryId == nil {
            selectedCategoryId = categories.first?.id
        }
    }
}

// MARK: - CategoryPickerRow

private struct CategoryPickerRow: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: category.icon)
                    .frame(width: 24)
                    .foregroundStyle(.secondary)
                Text(category.name)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
