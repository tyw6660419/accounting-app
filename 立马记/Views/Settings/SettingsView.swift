import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("管理") {
                    NavigationLink {
                        CategoryManageView()
                    } label: {
                        Label("分类管理", systemImage: "tag")
                    }

                    NavigationLink {
                        TemplateManageView()
                    } label: {
                        Label("模板管理", systemImage: "bolt")
                    }
                }

                Section("数据") {
                    HStack {
                        Label("数据导出", systemImage: "square.and.arrow.up")
                        Spacer()
                        Text("即将推出")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("关于") {
                    HStack {
                        Label("版本", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
