import WidgetKit
import SwiftUI

// MARK: - Entry

struct LiMaJiEntry: TimelineEntry {
    let date: Date
    let todayTotal: Double
    let monthTotal: Double
    let recentRecords: [WidgetSharedRecord]
}

// MARK: - Provider

struct LiMaJiProvider: TimelineProvider {
    func placeholder(in context: Context) -> LiMaJiEntry {
        LiMaJiEntry(date: Date(), todayTotal: 128.5, monthTotal: 2340, recentRecords: [
            WidgetSharedRecord(snapshot: "餐饮", amount: 38),
            WidgetSharedRecord(snapshot: "交通", amount: 15),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (LiMaJiEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LiMaJiEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> LiMaJiEntry {
        let data = WidgetDataStore.load()
        return LiMaJiEntry(
            date: Date(),
            todayTotal: data.todayTotal,
            monthTotal: data.monthTotal,
            recentRecords: data.recent
        )
    }
}

// MARK: - Small Widget（主屏幕 2×2）

struct SmallWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("今日支出")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("¥\(entry.todayTotal.amountDisplay)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer()
            Link(destination: URL(string: "quickledger://add")!) {
                Label("记一笔", systemImage: "plus.circle.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.accentColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - Medium Widget（主屏幕 4×2）

struct MediumWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        HStack(spacing: 0) {
            // 左：金额汇总
            VStack(alignment: .leading, spacing: 6) {
                Text("今日")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("¥\(entry.todayTotal.amountDisplay)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("本月 ¥\(entry.monthTotal.amountDisplay)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer()
                Link(destination: URL(string: "quickledger://add")!) {
                    Text("记一笔")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .leading)

            Divider()

            // 右：最近记录
            VStack(alignment: .leading, spacing: 6) {
                if entry.recentRecords.isEmpty {
                    Spacer()
                    Text("暂无记录")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    ForEach(Array(entry.recentRecords.prefix(3).enumerated()), id: \.offset) { _, rec in
                        HStack {
                            Text(rec.snapshot)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text("¥\(rec.amount.amountShort)")
                                .font(.caption.weight(.medium))
                        }
                    }
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// MARK: - 锁屏圆形（accessoryCircular）

struct CircularWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: "yensign.circle.fill")
                .font(.system(size: 12))
            Text("¥\(entry.todayTotal.amountShort)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }
}

// MARK: - 锁屏矩形（accessoryRectangular）

struct RectangularWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("立马记 · 今日")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("¥\(entry.todayTotal.amountDisplay)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("本月 ¥\(entry.monthTotal.amountDisplay)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Entry View

struct LiMaJiWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: LiMaJiEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget

struct LiMaJiWidget: Widget {
    let kind: String = "LiMaJiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LiMaJiProvider()) { entry in
            LiMaJiWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("立马记")
        .description("快速查看今日支出，一键记账")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}
