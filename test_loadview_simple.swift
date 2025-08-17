#!/usr/bin/env swift

import Foundation

// Test that our LoadAGameView logic works
struct SavedGameInfo {
    let filename: String
    let gameName: String
    let gameId: String
    let playerTeam: String
    let saveDate: Date
    let fileSize: Int
    let filePath: URL
}

func testLoadGamesList() {
    print("📂 LOAD VIEW TEST: Testing saved games listing functionality")
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let savedGamesPath = documentsPath.appendingPathComponent("savedGames")
    
    print("📂 LOAD VIEW TEST: Documents path: \(documentsPath.path)")
    print("📂 LOAD VIEW TEST: SavedGames path: \(savedGamesPath.path)")
    
    do {
        // Check if directory exists
        guard FileManager.default.fileExists(atPath: savedGamesPath.path) else {
            print("📂 LOAD VIEW TEST: ❌ SavedGames directory not found")
            return
        }
        
        // Find JSON files
        let files = try FileManager.default.contentsOfDirectory(at: savedGamesPath, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey], options: .skipsHiddenFiles)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        print("📂 LOAD VIEW TEST: Found \(jsonFiles.count) JSON files")
        
        var gameInfos: [SavedGameInfo] = []
        
        for file in jsonFiles {
            do {
                print("📂 LOAD VIEW TEST: Processing file: \(file.lastPathComponent)")
                
                // Get file metadata
                let resourceValues = try file.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                let creationDate = resourceValues.creationDate ?? Date.distantPast
                let fileSize = resourceValues.fileSize ?? 0
                
                // Read and parse the file to get game info
                let data = try Data(contentsOf: file)
                
                // Try to decode just enough to get basic info
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let gameName = jsonObject["gameName"] as? String ?? "Unknown Game"
                    let gameId = jsonObject["id"] as? String ?? "Unknown ID"
                    let saveDate = jsonObject["saveDate"] as? String ?? ""
                    
                    // Parse save date
                    let savedDate: Date
                    if !saveDate.isEmpty {
                        let formatter = ISO8601DateFormatter()
                        savedDate = formatter.date(from: saveDate) ?? creationDate
                    } else {
                        savedDate = creationDate
                    }
                    
                    // Get player team info if available
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
                    
                    let gameInfo = SavedGameInfo(
                        filename: file.lastPathComponent,
                        gameName: gameName,
                        gameId: gameId,
                        playerTeam: playerTeamName,
                        saveDate: savedDate,
                        fileSize: fileSize,
                        filePath: file
                    )
                    
                    gameInfos.append(gameInfo)
                    print("📂 LOAD VIEW TEST: ✅ Processed game: '\(gameName)' - Team: '\(playerTeamName)'")
                }
            } catch {
                print("📂 LOAD VIEW TEST: ❌ Error processing file \(file.lastPathComponent): \(error)")
            }
        }
        
        // Sort by save date (newest first)
        gameInfos.sort { $0.saveDate > $1.saveDate }
        
        print("📂 LOAD VIEW TEST: ✅ Successfully loaded \(gameInfos.count) games")
        print("📂 LOAD VIEW TEST: Game List:")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let byteFormatter = ByteCountFormatter()
        byteFormatter.allowedUnits = [.useKB, .useMB]
        byteFormatter.countStyle = .file
        
        for (index, game) in gameInfos.enumerated() {
            let formattedDate = dateFormatter.string(from: game.saveDate)
            let formattedSize = byteFormatter.string(fromByteCount: Int64(game.fileSize))
            
            print("📂 LOAD VIEW TEST:   \(index + 1). \(game.gameName)")
            print("📂 LOAD VIEW TEST:      Team: \(game.playerTeam)")
            print("📂 LOAD VIEW TEST:      Date: \(formattedDate)")
            print("📂 LOAD VIEW TEST:      Size: \(formattedSize)")
            print("📂 LOAD VIEW TEST:      File: \(game.filename)")
            print("📂 LOAD VIEW TEST:")
        }
        
    } catch {
        print("📂 LOAD VIEW TEST: ❌ Error loading saved games: \(error)")
    }
}

testLoadGamesList()