import WidgetKit
import SwiftUI

// MARK: - Entry

struct LiMaJiEntry: TimelineEntry {
    let date: Date
    let todayTotal: Double
    let monthTotal: Double
    let todayRecords: [WidgetSharedRecord]
}

// MARK: - Provider

struct LiMaJiProvider: TimelineProvider {
    func placeholder(in context: Context) -> LiMaJiEntry {
        LiMaJiEntry(
            date: Date(),
            todayTotal: 128.5,
            monthTotal: 2340,
            todayRecords: [
                WidgetSharedRecord(snapshot: "餐饮", amount: 38, time: "12:30"),
                WidgetSharedRecord(snapshot: "交通", amount: 15, time: "09:10"),
                WidgetSharedRecord(snapshot: "购物", amount: 75.5, time: "08:00"),
            ]
        )
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
            todayRecords: data.todayRecords
        )
    }
}

// MARK: - 小组件（2×2）今日总额

struct SmallWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("今日支出")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer().frame(height: 4)
            Text("¥\(entry.todayTotal.amountDisplay)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("共 \(entry.todayRecords.count) 笔")
                .font(.caption2)
                .foregroundStyle(.secondary)
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

// MARK: - 中组件（4×2）今日记录列表

struct MediumWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text("今日支出")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("¥\(entry.todayTotal.amountDisplay)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14)

            if entry.todayRecords.isEmpty {
                Spacer()
                Text("今天还没有记录")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(entry.todayRecords.prefix(3).enumerated()), id: \.offset) { i, rec in
                        HStack(spacing: 8) {
                            Text(rec.time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 36, alignment: .leading)
                            Text(rec.snapshot)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text("¥\(rec.amount.amountShort)")
                                .font(.caption.weight(.semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        if i < min(entry.todayRecords.count, 3) - 1 {
                            Divider().padding(.horizontal, 14)
                        }
                    }
                }
                Spacer()
            }

            Divider().padding(.horizontal, 14)

            // 底部快捷入口
            Link(destination: URL(string: "quickledger://add")!) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("记一笔")
                    Spacer()
                    Text("本月 ¥\(entry.monthTotal.amountDisplay)")
                        .foregroundStyle(.secondary)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - 大组件（4×4）今日记录列表（更多条）

struct LargeWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        VStack(spacing: 0) {
            // 顶部
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("今日支出")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("¥\(entry.todayTotal.amountDisplay)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("本月")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("¥\(entry.monthTotal.amountDisplay)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 16)

            if entry.todayRecords.isEmpty {
                Spacer()
                Text("今天还没有记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(entry.todayRecords.prefix(7).enumerated()), id: \.offset) { i, rec in
                        HStack(spacing: 10) {
                            Text(rec.time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 38, alignment: .leading)
                            Text(rec.snapshot)
                                .font(.subheadline)
                                .lineLimit(1)
                            Spacer()
                            Text("¥\(rec.amount.amountShort)")
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        if i < min(entry.todayRecords.count, 7) - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                Spacer()
            }

            Divider().padding(.horizontal, 16)

            Link(destination: URL(string: "quickledger://add")!) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("记一笔")
                    Spacer()
                    Text("共 \(entry.todayRecords.count) 笔")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - 锁屏圆形

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

// MARK: - 锁屏矩形

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
            Text("共 \(entry.todayRecords.count) 笔 · 本月 ¥\(entry.monthTotal.amountDisplay)")
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
        case .systemLarge:
            LargeWidgetView(entry: entry)
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
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}
