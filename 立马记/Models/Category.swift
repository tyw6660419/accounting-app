import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String        // SF Symbol 名称
    var sortOrder: Int
    var isSystem: Bool      // true = 系统预置，不可删除
    var createdAt: Date

    init(name: String, icon: String, sortOrder: Int, isSystem: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.isSystem = isSystem
        self.createdAt = Date()
    }
}
