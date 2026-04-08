import Foundation
import SwiftData

@Model
final class ExpenseRecord {
    var id: UUID
    var amount: Double          // 金额，0.01~99999.99
    var categoryId: UUID?       // 分类被删后为 nil
    var categorySnapshot: String // 分类名快照，分类删除不影响显示
    var note: String?
    var dateTime: Date
    var source: String          // "app" | "widget" | "shortcut"
    var templateId: UUID?
    var createdAt: Date
    var updatedAt: Date

    init(
        amount: Double,
        categoryId: UUID? = nil,
        categorySnapshot: String,
        note: String? = nil,
        dateTime: Date = Date(),
        source: String = "app",
        templateId: UUID? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.categoryId = categoryId
        self.categorySnapshot = categorySnapshot
        self.note = note
        self.dateTime = dateTime
        self.source = source
        self.templateId = templateId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
