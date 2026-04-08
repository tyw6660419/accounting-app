import AppIntents

/// Widget 点击后触发此 Intent，通过 URL Scheme 打开新增页
/// 使用前需在 Xcode 中为主 App Target 开启 App Intents 能力
struct OpenAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "记一笔"
    static var description = IntentDescription("打开立马记并直接跳到新增支出页")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
