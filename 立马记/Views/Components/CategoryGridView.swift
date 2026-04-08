import SwiftUI

struct CategoryGridView: View {
    let categories: [Category]
    let selectedId: UUID?
    let onSelect: (Category) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(categories.sorted(by: { $0.sortOrder < $1.sortOrder })) { cat in
                CategoryCell(category: cat, isSelected: selectedId == cat.id) {
                    onSelect(cat)
                }
            }
        }
    }
}

struct CategoryCell: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .frame(height: 24)
                Text(category.name)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color(.systemGray6))
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
