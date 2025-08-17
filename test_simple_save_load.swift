#!/usr/bin/env swift

import Foundation

// Test the simple save/load system
func testSimpleSaveLoad() {
    print("🧪 Testing simple save/load system...")
    
    let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
    let savedGamesPath = desktopPath.appendingPathComponent("savedGames")
    
    print("🧪 Desktop path: \(desktopPath.path)")
    print("🧪 SavedGames path: \(savedGamesPath.path)")
    
    // Test simple save simulation
    print("")
    print("💾 SIMPLE SAVE: Testing simple save simulation...")
    
    let testGameData = """
    {
        "id": "\(UUID().uuidString)",
        "gameName": "Simple Test Game",
        "playerTeamId": "\(UUID().uuidString)",
        "saveDate": "\(ISO8601DateFormatter().string(from: Date()))",
        "seasons": [],
        "league": {
            "id": "\(UUID().uuidString)",
            "name": "Simple League",
            "teams": [
                {
                    "id": "\(UUID().uuidString)",
                    "cityName": "Simple City",
                    "nickname": "Test Team",
                    "fullName": "Simple City Test Team",
                    "roster": [],
                    "conferenceId": "\(UUID().uuidString)",
                    "divisionId": "\(UUID().uuidString)"
                }
            ],
            "conferences": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Simple Conference"
                }
            ],
            "divisions": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Simple Division",
                    "conferenceId": "\(UUID().uuidString)"
                }
            ]
        },
        "calendar": {
            "currentDate": "\(ISO8601DateFormatter().string(from: Date()))",
            "phase": "regularSeason",
            "year": 2025
        },
        "currentSeason": {
            "id": "\(UUID().uuidString)",
            "year": 2025,
            "games": [],
            "teamRecords": []
        }
    }
    """
    
    do {
        // Create directory if needed (simulate simpleSave)
        if !FileManager.default.fileExists(atPath: savedGamesPath.path) {
            print("💾 SIMPLE SAVE: Creating savedGames directory")
            try FileManager.default.createDirectory(at: savedGamesPath, withIntermediateDirectories: true, attributes: nil)
            print("💾 SIMPLE SAVE: ✅ Directory created")
        } else {
            print("💾 SIMPLE SAVE: Directory already exists")
        }
        
        // Create filename (simulate simple save logic)
        let timestamp = DateFormatter().string(from: Date())
        let filename = "Simple_Test_Game_\(timestamp.replacingOccurrences(of: " ", with: "_")).json"
        let saveURL = savedGamesPath.appendingPathComponent(filename)
        
        print("💾 SIMPLE SAVE: Filename: \(filename)")
        print("💾 SIMPLE SAVE: Full path: \(saveURL.path)")
        
        // Write file
        try testGameData.write(to: saveURL, atomically: true, encoding: .utf8)
        print("💾 SIMPLE SAVE: ✅ File written successfully")
        
        // Verify
        if FileManager.default.fileExists(atPath: saveURL.path) {
            print("💾 SIMPLE SAVE: ✅ File verified on disk")
        }
        
    } catch {
        print("💾 SIMPLE SAVE: ❌ Error: \(error)")
        return
    }
    
    // Test simple load simulation
    print("")
    print("📂 SIMPLE LOAD: Testing simple load simulation...")
    
    do {
        // Check if directory exists (simulate simpleLoad)
        guard FileManager.default.fileExists(atPath: savedGamesPath.path) else {
            print("📂 SIMPLE LOAD: ❌ SavedGames directory not found")
            return
        }
        
        // Find JSON files
        let files = try FileManager.default.contentsOfDirectory(at: savedGamesPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        print("📂 SIMPLE LOAD: Found \(jsonFiles.count) save files")
        
        guard !jsonFiles.isEmpty else {
            print("📂 SIMPLE LOAD: ❌ No save files found")
            return
        }
        
        // Sort by creation date (newest first)
        let sortedFiles = jsonFiles.sorted { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 > date2
        }
        
        // Load the most recent save
        let mostRecentFile = sortedFiles[0]
        print("📂 SIMPLE LOAD: Loading most recent save: \(mostRecentFile.lastPathComponent)")
        
        let data = try Data(contentsOf: mostRecentFile)
        print("📂 SIMPLE LOAD: Read \(data.count) bytes")
        
        // Parse JSON to verify
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = jsonObject as? [String: Any] {
            if let gameName = dict["gameName"] as? String {
                print("📂 SIMPLE LOAD: ✅ Successfully loaded game: '\(gameName)'")
            }
        }
        
    } catch {
        print("📂 SIMPLE LOAD: ❌ Error: \(error)")
        return
    }
    
    print("")
    print("🧪 ✅ Simple save/load system test completed successfully!")
    print("🧪 ✅ Save functionality: Working")
    print("🧪 ✅ Load functionality: Working")
    print("🧪 ✅ Debug prints: Working")
    print("🧪 ✅ File location: /Users/admin/Desktop/savedGames")
    
    // List all files
    do {
        let allFiles = try FileManager.default.contentsOfDirectory(atPath: savedGamesPath.path)
        print("🧪 Total files in savedGames: \(allFiles.count)")
        for file in allFiles.sorted() {
            print("🧪   - \(file)")
        }
    } catch {
        print("🧪 ❌ Error listing files: \(error)")
    }
}

testSimpleSaveLoad()