import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        prepareAudioSession()
    }
    
    private func prepareAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playWoodFishSound() {
        guard let url = Bundle.main.url(forResource: "woodfish", withExtension: "MP3") else {
            print("Could not find woodfish.MP3 in bundle")
            return
        }
        
        print("Found audio file at: \(url.path)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            let success = audioPlayer?.play() ?? false
            print("Audio player started playing: \(success)")
        } catch {
            print("Could not play sound file: \(error)")
        }
    }
}