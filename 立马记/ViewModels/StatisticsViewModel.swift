import Foundation
import Observation

@Observable
class StatisticsViewModel {
    /// 0 = 本月，-1 = 上月
    var monthOffset: Int = 0

    var periodLabel: String { monthOffset == 0 ? "本月" : "上月" }

    func periodRange() -> (start: Date, end: Date) {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: Date())
        comps.month! += monthOffset
        let start = cal.date(from: comps)!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return (start, end)
    }

    func filteredRecords(from all: [ExpenseRecord]) -> [ExpenseRecord] {
        let range = periodRange()
        return all.filter { $0.dateTime >= range.start && $0.dateTime < range.end }
    }

    func total(from records: [ExpenseRecord]) -> Double {
        records.reduce(0) { $0 + $1.amount }
    }

    struct CategoryStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let amount: Double
        let percentage: Double
    }

    func categoryStats(from records: [ExpenseRecord], categories: [Category]) -> [CategoryStat] {
        let totalAmt = total(from: records)
        guard totalAmt > 0 else { return [] }

        var grouped: [String: (icon: String, amount: Double)] = [:]

        for record in records {
            let name = record.categorySnapshot
            let icon = categories.first(where: { $0.id == record.categoryId })?.icon ?? "ellipsis.circle"
            if let existing = grouped[name] {
                grouped[name] = (icon: existing.icon, amount: existing.amount + record.amount)
            } else {
                grouped[name] = (icon: icon, amount: record.amount)
            }
        }

        return grouped.map { name, value in
            CategoryStat(
                name: name,
                icon: value.icon,
                amount: value.amount,
                percentage: value.amount / totalAmt
            )
        }.sorted { $0.amount > $1.amount }
    }
}
