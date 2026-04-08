import SwiftUI
import SwiftData

/// 根视图：Tab Bar + 全局 AddExpense Sheet
/// Sheet 挂在 TabView 层，使 Widget 跳转时无论当前在哪个 Tab 都能弹出
struct ContentTabView: View {
    @Binding var openAddExpense: Bool
    @State private var showSheet = false
    @State private var templateToApply: ExpenseTemplate? = nil

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("首页", systemImage: "house") }

            StatisticsView()
                .tabItem { Label("统计", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gear") }
        }
        .sheet(isPresented: $showSheet, onDismiss: { templateToApply = nil }) {
            AddExpenseView(prefillTemplate: templateToApply)
        }
        // Widget / URL Scheme 触发
        .onChange(of: openAddExpense) { _, val in
            if val {
                showSheet = true
                openAddExpense = false
            }
        }
    }
}
