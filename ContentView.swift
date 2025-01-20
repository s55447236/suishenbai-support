import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var merit: Int = 0
    @State private var showSettings = false
    @State private var engine: CHHapticEngine?
    @State private var floatingTexts: [FloatingText] = []
    @AppStorage("vibrationIntensity") private var vibrationIntensity: Double = 0.5
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @State private var woodfishScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // 功德计数器
                    Text("功德: \(merit)")
                        .font(.system(size: 24, weight: .bold))
                        .padding()
                    
                    Spacer()
                    
                    // 木鱼图片按钮
                    Button(action: {
                        merit += 1
                        playHaptic()
                        if soundEnabled {
                            SoundManager.shared.playWoodFishSound()
                        }
                        addFloatingText()
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
                            woodfishScale = 0.8
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
                                woodfishScale = 1.1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
                                    woodfishScale = 1.0
                                }
                            }
                        }
                    }) {
                        Image("woodfish")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .scaleEffect(woodfishScale)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                
                // 显示所有浮动文字
                ForEach(floatingTexts) { text in
                    Text("功德 +1")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20, weight: .bold))
                        .position(text.position)
                        .opacity(text.opacity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .onAppear(perform: prepareHaptics)
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine creation error: \(error.localizedDescription)")
        }
    }
    
    private func playHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(vibrationIntensity * 1.5))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
    
    private func addFloatingText() {
        let position = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2 - 100
        )
        let id = UUID()
        let floatingText = FloatingText(id: id, position: position, opacity: 1)
        floatingTexts.append(floatingText)
        
        // 延长动画时间，增加移动距离
        withAnimation(.easeOut(duration: 1.5)) {
            if let index = floatingTexts.firstIndex(where: { $0.id == id }) {
                floatingTexts[index].position.y -= 150
                floatingTexts[index].opacity = 0
            }
        }
        
        // 延长文字移除时间
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            floatingTexts.removeAll { $0.id == id }
        }
    }
}

struct FloatingText: Identifiable {
    let id: UUID
    var position: CGPoint
    var opacity: Double
} 