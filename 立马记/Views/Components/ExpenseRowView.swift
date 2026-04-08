import SwiftUI

struct ExpenseRowView: View {
    let record: ExpenseRecord
    let categoryIcon: String

    var body: some View {
        HStack(spacing: 12) {
            // 分类图标
            Image(systemName: categoryIcon)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // 分类名 + 备注
            VStack(alignment: .leading, spacing: 2) {
                Text(record.categorySnapshot)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 金额 + 时间
            VStack(alignment: .trailing, spacing: 2) {
                Text("¥\(record.amount.amountDisplay)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(record.dateTime, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
