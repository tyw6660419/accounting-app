import Foundation
import SwiftData

@Model
final class ExpenseTemplate {
    var id: UUID
    var name: String
    var defaultAmount: Double?  // 可为空，调用时金额为 0
    var defaultCategoryId: UUID
    var defaultNote: String?
    var sortOrder: Int
    var createdAt: Date

    init(
        name: String,
        defaultAmount: Double? = nil,
        defaultCategoryId: UUID,
        defaultNote: String? = nil,
        sortOrder: Int
    ) {
        self.id = UUID()
        self.name = name
        self.defaultAmount = defaultAmount
        self.defaultCategoryId = defaultCategoryId
        self.defaultNote = defaultNote
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }
}
