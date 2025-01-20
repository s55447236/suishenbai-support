import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("vibrationIntensity") private var vibrationIntensity: Double = 0.5
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("震动设置")) {
                    VStack {
                        Text("震动强度: \(Int(vibrationIntensity * 100))%")
                        Slider(value: $vibrationIntensity, in: 0...1)
                    }
                }
                
                Section(header: Text("声音设置")) {
                    Toggle("启用音效", isOn: $soundEnabled)
                }
                
                Section(header: Text("关于")) {
                    Text("随身拜 v1.0")
                    Text("一个简单的电子木鱼应用")
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
} 