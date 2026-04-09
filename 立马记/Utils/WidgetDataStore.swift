import Foundation

// 供主 App 和 Widget Extension 共同使用
// 两个 Target 都需要添加此文件

struct WidgetSharedRecord: Codable {
    let snapshot: String
    let amount: Double
}

enum WidgetDataStore {
    static let appGroupID = "group.com.tanyawen.limaji"

    static func save(todayTotal: Double, monthTotal: Double, recent: [WidgetSharedRecord]) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        defaults.set(todayTotal, forKey: "widget_todayTotal")
        defaults.set(monthTotal, forKey: "widget_monthTotal")
        if let data = try? JSONEncoder().encode(recent) {
            defaults.set(data, forKey: "widget_recentRecords")
        }
    }

    static func load() -> (todayTotal: Double, monthTotal: Double, recent: [WidgetSharedRecord]) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return (0, 0, []) }
        let today = defaults.double(forKey: "widget_todayTotal")
        let month = defaults.double(forKey: "widget_monthTotal")
        var recent: [WidgetSharedRecord] = []
        if let data = defaults.data(forKey: "widget_recentRecords"),
           let decoded = try? JSONDecoder().decode([WidgetSharedRecord].self, from: data) {
            recent = decoded
        }
        return (today, month, recent)
    }
}
