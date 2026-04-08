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
                // 粒度选择
                Picker("粒度", selection: $vm.granularity) {
                    ForEach(StatisticsViewModel.Granularity.allCases, id: \.self) { g in
                        Text(g.rawValue).tag(g)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)

                // 日期导航
                HStack {
                    Button {
                        vm.stepBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                    }

                    Spacer()

                    Text(vm.periodLabel)
                        .font(.subheadline.weight(.semibold))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: vm.periodLabel)

                    Spacer()

                    Button {
                        vm.stepForward()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(vm.isFuture ? Color(.systemGray4) : .primary)
                            .frame(width: 36, height: 36)
                    }
                    .disabled(vm.isFuture)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

                Divider()

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
