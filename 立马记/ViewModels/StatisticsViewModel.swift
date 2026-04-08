import Foundation
import Observation

@Observable
class StatisticsViewModel {

    enum Granularity: String, CaseIterable {
        case day = "日"
        case month = "月"
        case year = "年"
    }

    var granularity: Granularity = .day
    var selectedDate: Date = Date()

    // MARK: - Navigation

    func stepBack() {
        let cal = Calendar.current
        switch granularity {
        case .day:   selectedDate = cal.date(byAdding: .day,   value: -1, to: selectedDate)!
        case .month: selectedDate = cal.date(byAdding: .month, value: -1, to: selectedDate)!
        case .year:  selectedDate = cal.date(byAdding: .year,  value: -1, to: selectedDate)!
        }
    }

    func stepForward() {
        let cal = Calendar.current
        switch granularity {
        case .day:   selectedDate = cal.date(byAdding: .day,   value: 1, to: selectedDate)!
        case .month: selectedDate = cal.date(byAdding: .month, value: 1, to: selectedDate)!
        case .year:  selectedDate = cal.date(byAdding: .year,  value: 1, to: selectedDate)!
        }
    }

    var isFuture: Bool {
        let cal = Calendar.current
        let now = Date()
        switch granularity {
        case .day:   return cal.isDate(selectedDate, inSameDayAs: now) || selectedDate > now
        case .month:
            let selComps = cal.dateComponents([.year, .month], from: selectedDate)
            let nowComps = cal.dateComponents([.year, .month], from: now)
            return selComps.year! > nowComps.year! ||
                   (selComps.year! == nowComps.year! && selComps.month! >= nowComps.month!)
        case .year:
            return cal.component(.year, from: selectedDate) >= cal.component(.year, from: now)
        }
    }

    // MARK: - Label

    var periodLabel: String {
        let cal = Calendar.current
        let now = Date()
        switch granularity {
        case .day:
            if cal.isDateInToday(selectedDate) { return "今天" }
            if cal.isDateInYesterday(selectedDate) { return "昨天" }
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "zh_CN")
            fmt.dateFormat = cal.component(.year, from: selectedDate) == cal.component(.year, from: now)
                ? "M月d日"
                : "yyyy年M月d日"
            return fmt.string(from: selectedDate)
        case .month:
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "zh_CN")
            fmt.dateFormat = cal.component(.year, from: selectedDate) == cal.component(.year, from: now)
                ? "M月"
                : "yyyy年M月"
            return fmt.string(from: selectedDate)
        case .year:
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "zh_CN")
            fmt.dateFormat = "yyyy年"
            return fmt.string(from: selectedDate)
        }
    }

    // MARK: - Filtering

    func periodRange() -> (start: Date, end: Date) {
        let cal = Calendar.current
        switch granularity {
        case .day:
            let start = cal.startOfDay(for: selectedDate)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
        case .month:
            var comps = cal.dateComponents([.year, .month], from: selectedDate)
            let start = cal.date(from: comps)!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        case .year:
            var comps = DateComponents()
            comps.year = cal.component(.year, from: selectedDate)
            comps.month = 1
            comps.day = 1
            let start = cal.date(from: comps)!
            let end = cal.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        }
    }

    func filteredRecords(from all: [ExpenseRecord]) -> [ExpenseRecord] {
        let range = periodRange()
        return all.filter { $0.dateTime >= range.start && $0.dateTime < range.end }
    }

    func total(from records: [ExpenseRecord]) -> Double {
        records.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Stats

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
