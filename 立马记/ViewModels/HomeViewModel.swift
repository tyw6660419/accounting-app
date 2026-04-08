import Foundation
import Observation

@Observable
class HomeViewModel {
    func todayTotal(from records: [ExpenseRecord]) -> Double {
        let range = todayRange()
        return records
            .filter { $0.dateTime >= range.start && $0.dateTime < range.end }
            .reduce(0) { $0 + $1.amount }
    }

    func monthTotal(from records: [ExpenseRecord]) -> Double {
        let range = currentMonthRange()
        return records
            .filter { $0.dateTime >= range.start && $0.dateTime < range.end }
            .reduce(0) { $0 + $1.amount }
    }

    func todayRecords(from records: [ExpenseRecord]) -> [ExpenseRecord] {
        let range = todayRange()
        return records
            .filter { $0.dateTime >= range.start && $0.dateTime < range.end }
            .sorted { $0.dateTime > $1.dateTime }
    }

    private func todayRange() -> (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return (start, end)
    }

    private func currentMonthRange() -> (start: Date, end: Date) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        let start = cal.date(from: comps)!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return (start, end)
    }
}
