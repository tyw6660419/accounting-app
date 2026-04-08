import Foundation

extension Double {
    /// "¥12.50" 格式，保留两位小数
    var amountDisplay: String {
        String(format: "%.2f", self)
    }

    /// 简短显示（去掉末尾零），用于模板按钮
    var amountShort: String {
        let formatted = String(format: "%.2f", self)
        if formatted.hasSuffix(".00") {
            return String(format: "%.0f", self)
        }
        if formatted.hasSuffix("0") {
            return String(format: "%.1f", self)
        }
        return formatted
    }
}
