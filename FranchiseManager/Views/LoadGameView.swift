import SwiftUI

struct LoadGameView: View {
    @Binding var showLoadView: Bool
    @Binding var selectedGame: SavedGame?
    @Binding var showGame: Bool
    
    @State private var savedGames: [(file: URL, game: SavedGameInfo)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showLoadView = false
                }
            
            VStack(spacing: 20) {
                HStack {
                    Text("Load Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        showLoadView = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading saved games...")
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                } else if let error = errorMessage {
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Games")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 200)
                } else if savedGames.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "folder")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Saved Games")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start a new game to create your first save file")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 200)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(savedGames, id: \.file) { savedGameData in
                                SavedGameCard(
                                    gameInfo: savedGameData.game,
                                    onLoad: {
                                        loadGame(from: savedGameData.file)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 400)
                }
                
                HStack {
                    Button(action: {
                        loadSavedGames()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(20)
            .shadow(radius: 20)
            .frame(maxWidth: 600, maxHeight: 500)
        }
        .onAppear {
            loadSavedGames()
        }
    }
    
    private func loadSavedGames() {
        isLoading = true
        errorMessage = nil
        savedGames = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let gameFiles = SavedGamesManager.shared.loadSavedGamesList()
            var loadedGames: [(file: URL, game: SavedGameInfo)] = []
            
            for file in gameFiles {
                do {
                    let gameInfo = try extractGameInfo(from: file)
                    loadedGames.append((file: file, game: gameInfo))
                } catch {
                    print("Error extracting info from \(file.lastPathComponent): \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.savedGames = loadedGames
                self.isLoading = false
            }
        }
    }
    
    private func extractGameInfo(from url: URL) throws -> SavedGameInfo {
        let data = try Data(contentsOf: url)
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw LoadGameError.invalidFileFormat
        }
        
        let gameName = jsonObject["gameName"] as? String ?? "Unknown Game"
        let saveDate = jsonObject["saveDate"] as? String ?? ""
        
        let savedDate: Date
        if !saveDate.isEmpty {
            let formatter = ISO8601DateFormatter()
            savedDate = formatter.date(from: saveDate) ?? Date.distantPast
        } else {
            savedDate = Date.distantPast
        }
        
        var playerTeamName = "Unknown Team"
        if let playerTeamId = jsonObject["playerTeamId"] as? String,
           let league = jsonObject["league"] as? [String: Any],
           let teams = league["teams"] as? [[String: Any]] {
            for team in teams {
                if let teamId = team["id"] as? String, teamId == playerTeamId {
                    if let fullName = team["fullName"] as? String {
                        playerTeamName = fullName
                    } else if let cityName = team["cityName"] as? String,
                              let nickname = team["nickname"] as? String {
                        playerTeamName = "\(cityName) \(nickname)"
                    }
                    break
                }
            }
        }
        
        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        
        return SavedGameInfo(
            fileName: url.lastPathComponent,
            gameName: gameName,
            playerTeam: playerTeamName,
            saveDate: savedDate,
            fileSize: fileSize
        )
    }
    
    private func loadGame(from url: URL) {
        print("🎮 LOAD GAME: Loading game from: \(url.lastPathComponent)")
        
        do {
            let savedGame = try SavedGamesManager.shared.loadSavedGame(from: url)
            print("🎮 LOAD GAME: Successfully loaded: \(savedGame.gameName)")
            print("🎮 LOAD GAME: Game ID: \(savedGame.id)")
            print("🎮 LOAD GAME: Player team ID: \(savedGame.playerTeamId)")
            
            // Ensure state updates happen on main thread with proper sequencing
            DispatchQueue.main.async {
                // First set the loaded game
                self.selectedGame = savedGame
                print("🎮 LOAD GAME: Set selectedGame to: \(savedGame.gameName)")
                
                // Close the load view first
                self.showLoadView = false
                print("🎮 LOAD GAME: Set showLoadView to false")
                
                // Then trigger navigation after a short delay to ensure UI updates
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.showGame = true
                    print("🎮 LOAD GAME: Set showGame to true")
                    print("🎮 LOAD GAME: Final state - selectedGame: \(self.selectedGame?.gameName ?? "nil"), showGame: \(self.showGame)")
                }
            }
            
        } catch {
            print("🎮 LOAD GAME: Error loading game: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load game: \(error.localizedDescription)"
            }
        }
    }
}

struct SavedGameCard: View {
    let gameInfo: SavedGameInfo
    let onLoad: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(gameInfo.gameName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(gameInfo.playerTeam)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateFormatter.string(from: gameInfo.saveDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "doc")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(byteFormatter.string(fromByteCount: Int64(gameInfo.fileSize)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onLoad) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Load Game")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .frame(height: 160)
    }
}

struct SavedGameInfo {
    let fileName: String
    let gameName: String
    let playerTeam: String
    let saveDate: Date
    let fileSize: Int
}

enum LoadGameError: Error, LocalizedError {
    case invalidFileFormat
    case noSavedGames
    
    var errorDescription: String? {
        switch self {
        case .invalidFileFormat:
            return "Invalid save file format"
        case .noSavedGames:
            return "No saved games found"
        }
    }
}