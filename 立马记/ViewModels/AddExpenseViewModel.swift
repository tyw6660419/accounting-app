import Foundation
import Observation

@Observable
class AddExpenseViewModel {
    var amountString: String = ""
    var selectedCategoryId: UUID? = nil
    var selectedCategorySnapshot: String = "其他"
    var note: String = ""

    // 金额大字显示
    var displayAmount: String {
        amountString.isEmpty ? "0" : amountString
    }

    // 有效金额（nil = 无效，不可保存）
    var amount: Double? {
        guard !amountString.isEmpty,
              let d = Double(amountString),
              d > 0 else { return nil }
        return d
    }

    var canSave: Bool { amount != nil }

    // MARK: - 数字键盘输入

    func inputKey(_ key: String) {
        switch key {
        case ".":
            handleDot()
        default:
            handleDigit(key)
        }
    }

    func deleteKey() {
        guard !amountString.isEmpty else { return }
        amountString.removeLast()
    }

    private func handleDot() {
        if amountString.isEmpty {
            amountString = "0."
        } else if !amountString.contains(".") {
            amountString += "."
        }
    }

    private func handleDigit(_ digit: String) {
        if let dotIndex = amountString.firstIndex(of: ".") {
            // 小数点后最多两位
            let afterDot = amountString.distance(from: dotIndex, to: amountString.endIndex) - 1
            if afterDot >= 2 { return }
        } else {
            // 整数部分最多 5 位，且不超过 99999
            let candidate = amountString + digit
            if let val = Double(candidate), val > 99999 { return }
            if amountString.count >= 5 { return }
        }

        // 去掉前导零（直接输入的整数部分）
        if amountString == "0" {
            amountString = digit
        } else {
            amountString += digit
        }
    }

    // MARK: - 分类选择

    func selectCategory(id: UUID, name: String) {
        if selectedCategoryId == id {
            // 再次点击取消选择
            selectedCategoryId = nil
            selectedCategorySnapshot = "其他"
        } else {
            selectedCategoryId = id
            selectedCategorySnapshot = name
        }
    }

    // MARK: - 模板填充

    func applyTemplate(_ template: ExpenseTemplate, categoryName: String?) {
        if let amt = template.defaultAmount {
            amountString = amt.amountShort
        } else {
            amountString = ""
        }
        selectedCategoryId = template.defaultCategoryId
        selectedCategorySnapshot = categoryName ?? "其他"
        note = template.defaultNote ?? ""
    }

    // MARK: - 重置

    func reset() {
        amountString = ""
        selectedCategoryId = nil
        selectedCategorySnapshot = "其他"
        note = ""
    }
}
