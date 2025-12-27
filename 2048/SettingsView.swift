import SwiftUI

struct SettingsView: View {
    @ObservedObject var game: GameModel
    @ObservedObject var audioManager = AudioHapticsManager.shared
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Background Blur (Glassmorphism)
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            
            // Settings Card
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("SETTINGS")
                        .font(AppFont.rounded(24, weight: .heavy))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        withAnimation { isPresented = false }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 10)
                
                // Music Toggle
                ToggleRow(title: "Music", isOn: $audioManager.isMusicOn, icon: "music.note")
                
                // Sound Effects Toggle
                ToggleRow(title: "Sound Effects", isOn: $audioManager.isSFXOn, icon: "speaker.wave.3.fill")
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Track Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("MUSIC TRACK")
                        .font(AppFont.rounded(14, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 12) {
                        TrackButton(
                            title: "Default",
                            isSelected: audioManager.selectedMusicTrack == "default",
                            action: { audioManager.selectedMusicTrack = "default" }
                        )
                        
                        TrackButton(
                            title: "Alternate",
                            isSelected: audioManager.selectedMusicTrack == "alternate",
                            action: { audioManager.selectedMusicTrack = "alternate" }
                        )
                    }
                }
                
                #if DEBUG
                Divider()
                    .background(Color.white.opacity(0.2))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("DEBUG TOOLS")
                        .font(AppFont.rounded(14, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                game.debugSetup()
                                isPresented = false
                            }
                        }) {
                            Text("Near End")
                                .font(AppFont.rounded(14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.6))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            withAnimation {
                                game.debugWinSetup()
                                isPresented = false
                            }
                        }) {
                            Text("Near Win")
                                .font(AppFont.rounded(14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.6))
                                .cornerRadius(12)
                        }
                    }
                }
                #endif
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(BlockBlastConstants.cravrDarkSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
            )
            .padding(20)
        }
    }
}

// Helper Views
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            Text(title)
                .font(AppFont.rounded(18, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: BlockBlastConstants.cravrGreen))
        }
    }
}

struct TrackButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.rounded(16, weight: .bold))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(isSelected ? BlockBlastConstants.cravrMaize : Color.white.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    SettingsView(game: GameModel(), isPresented: .constant(true))
}
