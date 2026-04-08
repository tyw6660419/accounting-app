import SwiftUI

struct NumpadView: View {
    let onInput: (String) -> Void
    let onDelete: () -> Void

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"],
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { key in
                        NumpadKey(label: key) {
                            if key == "⌫" { onDelete() } else { onInput(key) }
                        }
                    }
                }
            }
        }
    }
}

private struct NumpadKey: View {
    let label: String
    let action: () -> Void

    var isDelete: Bool { label == "⌫" }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(isDelete ? .title3 : .title2)
                .fontWeight(isDelete ? .regular : .medium)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(isDelete ? Color(.systemGray5) : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }
}
