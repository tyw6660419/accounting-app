import SwiftUI
import SwiftData

struct EditRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @Bindable var record: ExpenseRecord

    @State private var amountString: String = ""
    @State private var selectedCategoryId: UUID? = nil
    @State private var showDeleteAlert = false
    @State private var vm = AddExpenseViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 金额
                VStack(alignment: .leading, spacing: 8) {
                    Text("金额")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("¥")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $vm.amountString)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // 分类
                VStack(alignment: .leading, spacing: 10) {
                    Text("分类")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    CategoryGridView(
                        categories: categories,
                        selectedId: vm.selectedCategoryId
                    ) { cat in
                        vm.selectCategory(id: cat.id, name: cat.name)
                    }
                }

                // 备注
                VStack(alignment: .leading, spacing: 8) {
                    Text("备注")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    TextField("备注（选填）", text: $vm.note)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onChange(of: vm.note) { _, v in
                            if v.count > 100 { vm.note = String(v.prefix(100)) }
                        }
                }

                // 时间
                VStack(alignment: .leading, spacing: 8) {
                    Text("时间")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: $record.dateTime, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding(.horizontal)
                }

                // 保存按钮
                Button(action: saveRecord) {
                    Text("保存修改")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(vm.canSave ? Color.accentColor : Color(.systemGray4))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!vm.canSave)

                // 删除按钮
                Button {
                    showDeleteAlert = true
                } label: {
                    Text("删除记录")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("编辑记录")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认删除这条记录？", isPresented: $showDeleteAlert) {
            Button("删除", role: .destructive) { deleteRecord() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销。")
        }
        .onAppear { loadRecord() }
    }

    private func loadRecord() {
        vm.amountString = record.amount.amountShort
        vm.selectedCategoryId = record.categoryId
        vm.selectedCategorySnapshot = record.categorySnapshot
        vm.note = record.note ?? ""
    }

    private func saveRecord() {
        guard let amount = vm.amount else { return }
        record.amount = amount
        record.categoryId = vm.selectedCategoryId
        record.categorySnapshot = vm.selectedCategorySnapshot
        record.note = vm.note.isEmpty ? nil : vm.note
        record.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }

    private func deleteRecord() {
        modelContext.delete(record)
        try? modelContext.save()
        dismiss()
    }
}
