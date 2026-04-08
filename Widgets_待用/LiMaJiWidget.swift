// ⚠️ Widget 需要单独的 Widget Extension Target
//
// 在 Xcode 中操作步骤：
// 1. File → New → Target → Widget Extension
// 2. Product Name: LiMaJiWidget
// 3. 勾选 "Include Configuration App Intent"
// 4. 将此文件及 SmallWidgetView / MediumWidgetView 移入该 Target
// 5. 在 App Group 中配置共享数据（参见 PRD 13.5 节）
//
// 以下为 Widget 完整实现，待 Target 创建后可直接使用

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Timeline Entry

struct LiMaJiEntry: TimelineEntry {
    let date: Date
    let todayTotal: Double
    let monthTotal: Double
    let recentRecords: [(snapshot: String, amount: Double)]
}

// MARK: - Timeline Provider

struct LiMaJiProvider: TimelineProvider {
    func placeholder(in context: Context) -> LiMaJiEntry {
        LiMaJiEntry(date: Date(), todayTotal: 0, monthTotal: 0, recentRecords: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (LiMaJiEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LiMaJiEntry>) -> Void) {
        // TODO: 通过 App Group 读取 SwiftData 数据
        // 配置 App Group 后在此处初始化共享 ModelContainer 并查询
        let entry = LiMaJiEntry(date: Date(), todayTotal: 0, monthTotal: 0, recentRecords: [])
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Small Widget (2×2)

struct SmallWidgetView: View {
    let entry: LiMaJiEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("今日支出")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("¥\(entry.todayTotal.amountDisplay)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
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

// MARK: - Medium Widget (4×2)

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
                Text("本月 ¥\(entry.monthTotal.amountDisplay)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
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
                ForEach(Array(entry.recentRecords.prefix(2).enumerated()), id: \.offset) { _, rec in
                    HStack {
                        Text(rec.snapshot)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("¥\(rec.amount.amountShort)")
                            .font(.caption.weight(.medium))
                    }
                }
                if entry.recentRecords.isEmpty {
                    Text("暂无记录")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Widget Configuration

struct LiMaJiWidget: Widget {
    let kind: String = "LiMaJiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LiMaJiProvider()) { entry in
            LiMaJiWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("立马记")
        .description("快速查看今日支出，一键记账")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct LiMaJiWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: LiMaJiEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
