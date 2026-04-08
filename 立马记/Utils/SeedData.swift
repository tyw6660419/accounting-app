import Foundation
import SwiftData

enum SeedData {
    private static let key = "defaultCategoriesInserted_v1"

    static let defaultCategories: [(name: String, icon: String, sortOrder: Int, isSystem: Bool)] = [
        ("餐饮",    "fork.knife",       0, false),
        ("咖啡饮品", "cup.and.saucer",   1, false),
        ("交通",    "car",              2, false),
        ("购物",    "bag",              3, false),
        ("日用",    "house",            4, false),
        ("娱乐",    "gamecontroller",   5, false),
        ("宠物",    "pawprint",         6, false),
        ("其他",    "ellipsis.circle",  7, true),   // 系统分类，不可删除
    ]

    /// App 首次启动时写入默认分类，通过 UserDefaults 标记防止重复写入
    static func insertDefaultCategoriesIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        for item in defaultCategories {
            let category = Category(
                name: item.name,
                icon: item.icon,
                sortOrder: item.sortOrder,
                isSystem: item.isSystem
            )
            context.insert(category)
        }

        try? context.save()
        UserDefaults.standard.set(true, forKey: key)
    }
}
