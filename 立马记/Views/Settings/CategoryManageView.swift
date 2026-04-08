import SwiftUI
import SwiftData

struct CategoryManageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query private var allRecords: [ExpenseRecord]

    @State private var showAddSheet = false
    @State private var editingCategory: Category? = nil
    @State private var categoryToDelete: Category? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            ForEach(categories) { cat in
                HStack(spacing: 12) {
                    Image(systemName: cat.icon)
                        .frame(width: 28)
                        .foregroundStyle(.secondary)
                    Text(cat.name)
                    Spacer()
                    if cat.isSystem {
                        Text("系统")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !cat.isSystem { editingCategory = cat }
                }
                .swipeActions(edge: .trailing) {
                    if !cat.isSystem {
                        Button(role: .destructive) {
                            categoryToDelete = cat
                            showDeleteAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
            .onMove(perform: moveCategory)
        }
        .navigationTitle("分类管理")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if categories.count < 20 { showAddSheet = true }
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(categories.count >= 20)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddSheet) {
            CategoryEditSheet(category: nil) { name, icon in
                addCategory(name: name, icon: icon)
            }
        }
        .sheet(item: $editingCategory) { cat in
            CategoryEditSheet(category: cat) { name, icon in
                cat.name = name
                cat.icon = icon
                try? modelContext.save()
            }
        }
        .alert("删除分类", isPresented: $showDeleteAlert, presenting: categoryToDelete) { cat in
            Button("删除", role: .destructive) { deleteCategory(cat) }
            Button("取消", role: .cancel) {}
        } message: { cat in
            let count = allRecords.filter { $0.categoryId == cat.id }.count
            if count > 0 {
                Text("该分类下有 \(count) 条历史记录，删除后这些记录将保留分类名称但无法通过分类筛选。确认删除？")
            } else {
                Text("确认删除「\(cat.name)」分类？")
            }
        }
    }

    private func addCategory(name: String, icon: String) {
        let maxOrder = categories.map(\.sortOrder).max() ?? -1
        let cat = Category(name: name, icon: icon, sortOrder: maxOrder + 1)
        modelContext.insert(cat)
        try? modelContext.save()
    }

    private func deleteCategory(_ cat: Category) {
        // 历史记录 categoryId 置 nil，但 categorySnapshot 保持不变
        for record in allRecords where record.categoryId == cat.id {
            record.categoryId = nil
        }
        modelContext.delete(cat)
        try? modelContext.save()
        reorderAfterDelete()
    }

    private func moveCategory(from source: IndexSet, to destination: Int) {
        var sorted = categories.sorted(by: { $0.sortOrder < $1.sortOrder })
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, cat) in sorted.enumerated() {
            cat.sortOrder = index
        }
        try? modelContext.save()
    }

    private func reorderAfterDelete() {
        let sorted = categories.sorted(by: { $0.sortOrder < $1.sortOrder })
        for (index, cat) in sorted.enumerated() {
            cat.sortOrder = index
        }
        try? modelContext.save()
    }
}

// MARK: - CategoryEditSheet

struct CategoryEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let category: Category?
    let onSave: (String, String) -> Void

    @State private var name: String = ""
    @State private var icon: String = "star"

    // 常用 SF Symbol 图标供选择
    private let iconOptions: [String] = [
        "fork.knife", "cup.and.saucer", "car", "bag", "house",
        "gamecontroller", "pawprint", "ellipsis.circle",
        "cart", "tram", "airplane", "bicycle",
        "heart", "book", "music.note", "camera",
        "dumbbell", "pill", "scissors", "wrench",
        "gift", "creditcard", "banknote", "film",
    ]

    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("分类名称") {
                    TextField("输入名称", text: $name)
                }

                Section("选择图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { sym in
                            Button {
                                icon = sym
                            } label: {
                                Image(systemName: sym)
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                                    .background(icon == sym ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(icon == sym ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(category == nil ? "新增分类" : "编辑分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(name.trimmingCharacters(in: .whitespaces), icon)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let cat = category {
                    name = cat.name
                    icon = cat.icon
                }
            }
        }
    }
}
