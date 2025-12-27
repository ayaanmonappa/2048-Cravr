import SwiftUI
import AVFoundation
import Combine

class AudioHapticsManager: ObservableObject {
    static let shared = AudioHapticsManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var bgMusicPlayer: AVAudioPlayer?
    
    @Published var isMusicOn: Bool {
        didSet {
            UserDefaults.standard.set(isMusicOn, forKey: "isMusicOn")
            if isMusicOn {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    @Published var isSFXOn: Bool {
        didSet {
            UserDefaults.standard.set(isSFXOn, forKey: "isSFXOn")
        }
    }
    
    @Published var selectedMusicTrack: String {
        didSet {
            UserDefaults.standard.set(selectedMusicTrack, forKey: "selectedMusicTrack")
            if isMusicOn {
                playBackgroundMusic() // Restart with new track
            }
        }
    }
    
    init() {
        self.isMusicOn = UserDefaults.standard.object(forKey: "isMusicOn") as? Bool ?? true
        self.isSFXOn = UserDefaults.standard.object(forKey: "isSFXOn") as? Bool ?? true
        self.selectedMusicTrack = UserDefaults.standard.string(forKey: "selectedMusicTrack") ?? "default"
    }
    
    // MARK: - Haptics & Swipe Audio
    
    func playMove() {
        playSound("swipe", volume: 0.5)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func playMerge() {
        // TODO: Insert "Collision" Sound Here
        playSound("collision", volume: 0.7) // User to replace file
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func playUnlock() {
        // TODO: Insert "New Block" Sound Here
        playSound("maximize_006", volume: 0.8) // User to replace file
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    // Old methods removed

    
    // MARK: - Audio
    
    func playSound(_ name: String, volume: Float = 0.9) {
        guard isSFXOn else { return }
        
        if let player = audioPlayers[name] {
            player.stop()
            player.currentTime = 0
            player.volume = volume
            player.play()
            return
        }

        // Try mp3, then wav
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") ?? 
                        Bundle.main.url(forResource: name, withExtension: "wav") else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            audioPlayers[name] = player
        } catch {
            #if DEBUG
            print("Failed to play sound: \(error)")
            #endif
        }
    }
    
    func playBackgroundMusic() {
        guard isMusicOn else { return }
        
        let filename = selectedMusicTrack == "alternate" ? "alternate" : "mixkit-dancing-fit-45"
        let ext = selectedMusicTrack == "alternate" ? "wav" : "mp3"
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else { return }
        
        do {
            // If already playing this url, don't restart? 
            // Current simple logic: just restart.
            bgMusicPlayer?.stop()
            
            bgMusicPlayer = try AVAudioPlayer(contentsOf: url)
            bgMusicPlayer?.numberOfLoops = -1 // Infinite loop
            bgMusicPlayer?.volume = 0.07 // Low background volume
            bgMusicPlayer?.prepareToPlay()
            bgMusicPlayer?.play()
        } catch {
            #if DEBUG
            print("Failed to play background music: \(error)")
            #endif
        }
    }
    
    func stopBackgroundMusic() {
        bgMusicPlayer?.stop()
    }
    
    func playGameOver() {
        // "end game" (wav)
        playSound("endgame", volume: 1.0)
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    func playWin() {
        // "winGame" (wav)
        playSound("winGame", volume: 1.0)
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}
