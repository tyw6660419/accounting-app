import SwiftUI
import SwiftData

@main
struct LiMaJiApp: App {
    let container: ModelContainer
    @State private var openAddExpense = false

    init() {
        do {
            let schema = Schema([
                ExpenseRecord.self,
                Category.self,
                ExpenseTemplate.self,
            ])
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("SwiftData ModelContainer 初始化失败: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentTabView(openAddExpense: $openAddExpense)
                .modelContainer(container)
                .onAppear {
                    SeedData.insertDefaultCategoriesIfNeeded(context: container.mainContext)
                }
                .onOpenURL { url in
                    // 支持 quickledger://add 和 quickledger://home
                    if url.scheme == "quickledger", url.host == "add" {
                        openAddExpense = true
                    }
                }
        }
    }
}
