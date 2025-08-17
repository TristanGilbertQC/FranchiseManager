#!/usr/bin/env swift

import Foundation

// Simulate the auto-save functionality that should happen during new game creation
func testAutoSaveSimulation() {
    print("🧪 Testing auto-save simulation for new game creation...")
    
    // Create a mock SavedGame similar to what would be created
    let mockSavedGame = """
    {
        "id": "\(UUID().uuidString)",
        "gameName": "Auto-Save Test Game",
        "playerTeamId": "\(UUID().uuidString)",
        "saveDate": "\(ISO8601DateFormatter().string(from: Date()))",
        "seasons": [],
        "league": {
            "id": "\(UUID().uuidString)",
            "name": "Test League",
            "teams": [
                {
                    "id": "\(UUID().uuidString)",
                    "cityName": "Test City",
                    "nickname": "Test Team",
                    "fullName": "Test City Test Team",
                    "roster": [],
                    "conferenceId": "\(UUID().uuidString)",
                    "divisionId": "\(UUID().uuidString)"
                }
            ],
            "conferences": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Test Conference"
                }
            ],
            "divisions": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Test Division",
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
    
    // Simulate the auto-save logic from NewGameView
    print("🎮 NEW GAME: Auto-saving new game 'Auto-Save Test Game'")
    
    do {
        // Get Application Support directory (same as the actual code)
        let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appName = "FranchiseManager"
        let appDirectory = appSupportPath.appendingPathComponent(appName)
        print("🎮 NEW GAME: App Support path: \(appSupportPath.path)")
        print("🎮 NEW GAME: App directory: \(appDirectory.path)")
        
        // Create app directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            print("🎮 NEW GAME: Creating app directory...")
            try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            print("🎮 NEW GAME: Successfully created app directory")
        } else {
            print("🎮 NEW GAME: App directory already exists")
        }
        
        let savedFilesPath = appDirectory.appendingPathComponent("savedFiles")
        print("🎮 NEW GAME: Target savedFiles path: \(savedFilesPath.path)")
        
        // Create savedFiles directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: savedFilesPath.path) {
            print("🎮 NEW GAME: savedFiles directory doesn't exist, creating it...")
            try FileManager.default.createDirectory(at: savedFilesPath, withIntermediateDirectories: true, attributes: nil)
            print("🎮 NEW GAME: Successfully created savedFiles directory")
        } else {
            print("🎮 NEW GAME: savedFiles directory already exists")
        }
        
        // Create filename with timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let filename = "Auto-Save_Test_Game_\(timestamp).json"
        let saveURL = savedFilesPath.appendingPathComponent(filename)
        print("🎮 NEW GAME: Full save path: \(saveURL.path)")
        print("🎮 NEW GAME: Filename: \(filename)")
        
        print("🎮 NEW GAME: Writing to file...")
        try mockSavedGame.write(to: saveURL, atomically: true, encoding: .utf8)
        print("🎮 NEW GAME: ✅ Successfully wrote save file")
        
        // Verify the file was written
        if FileManager.default.fileExists(atPath: saveURL.path) {
            let fileSize = try FileManager.default.attributesOfItem(atPath: saveURL.path)[.size] as? Int ?? 0
            print("🎮 NEW GAME: ✅ File verified on disk, size: \(fileSize) bytes")
            
            // Verify content
            let readData = try Data(contentsOf: saveURL)
            let jsonObject = try JSONSerialization.jsonObject(with: readData, options: [])
            if let dict = jsonObject as? [String: Any] {
                if let gameName = dict["gameName"] as? String {
                    print("🎮 NEW GAME: ✅ Verified game name: '\(gameName)'")
                }
            }
            
            print("🎮 NEW GAME: ✅ AUTO-SAVE SIMULATION SUCCESSFUL!")
            
        } else {
            print("🎮 NEW GAME: ❌ File not found after write operation")
        }
        
    } catch {
        print("🎮 NEW GAME: ❌ Error auto-saving new game: \(error)")
        print("🎮 NEW GAME: ❌ Error details: \(error.localizedDescription)")
    }
    
    // List all files in directory
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("FranchiseManager/savedFiles").path)
        print("🎮 NEW GAME: Total files in savedFiles directory: \(files.count)")
        for file in files.sorted() {
            print("🎮 NEW GAME:   - \(file)")
        }
    } catch {
        print("🎮 NEW GAME: ❌ Error listing files: \(error)")
    }
}

testAutoSaveSimulation()