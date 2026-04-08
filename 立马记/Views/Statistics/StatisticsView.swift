import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(sort: \ExpenseRecord.dateTime, order: .reverse) private var allRecords: [ExpenseRecord]
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @State private var vm = StatisticsViewModel()

    private var records: [ExpenseRecord] { vm.filteredRecords(from: allRecords) }
    private var total: Double { vm.total(from: records) }
    private var stats: [StatisticsViewModel.CategoryStat] {
        vm.categoryStats(from: records, categories: categories)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 月份切换
                Picker("周期", selection: $vm.monthOffset) {
                    Text("本月").tag(0)
                    Text("上月").tag(-1)
                }
                .pickerStyle(.segmented)
                .padding()

                if records.isEmpty {
                    Spacer()
                    Text("\(vm.periodLabel)还没有支出记录")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 总支出卡片
                            VStack(spacing: 6) {
                                Text("¥\(total.amountDisplay)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .contentTransition(.numericText())
                                    .animation(.snappy, value: total)
                                Text("共 \(records.count) 笔")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)

                            // 分类列表
                            VStack(spacing: 0) {
                                ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                                    CategoryStatRow(stat: stat)
                                        .padding(.horizontal)
                                    if index < stats.count - 1 {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("统计")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct CategoryStatRow: View {
    let stat: StatisticsViewModel.CategoryStat

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: stat.icon)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(stat.name)
                .font(.subheadline)

            Spacer()

            Text("¥\(stat.amount.amountDisplay)")
                .font(.subheadline.weight(.semibold))

            Text(String(format: "%d%%", Int(stat.percentage * 100)))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
        .padding(.vertical, 10)
    }
}
