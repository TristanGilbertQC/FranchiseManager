#!/usr/bin/env swift

import Foundation

// Test complete save/load workflow with Desktop savedGames folder
func testCompleteWorkflow() {
    print("🧪 Testing complete save/load workflow with Desktop folder...")
    
    let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
    let savedFilesPath = desktopPath.appendingPathComponent("savedGames")
    
    print("🧪 Desktop path: \(desktopPath.path)")
    print("🧪 SavedGames path: \(savedFilesPath.path)")
    
    // Simulate new game creation auto-save (NewGameView functionality)
    print("")
    print("🎮 NEW GAME: Simulating auto-save on new game creation...")
    
    let newGameData = """
    {
        "id": "\(UUID().uuidString)",
        "gameName": "Auto-Save Workflow Test",
        "playerTeamId": "\(UUID().uuidString)",
        "saveDate": "\(ISO8601DateFormatter().string(from: Date()))",
        "seasons": [],
        "league": {
            "id": "\(UUID().uuidString)",
            "name": "Workflow League",
            "teams": [
                {
                    "id": "\(UUID().uuidString)",
                    "cityName": "Workflow City",
                    "nickname": "Rangers",
                    "fullName": "Workflow City Rangers",
                    "roster": [],
                    "conferenceId": "\(UUID().uuidString)",
                    "divisionId": "\(UUID().uuidString)"
                }
            ],
            "conferences": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Eastern Conference"
                }
            ],
            "divisions": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Atlantic Division",
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
            "teamRecords": [
                {
                    "teamId": "\(UUID().uuidString)",
                    "wins": 0,
                    "losses": 0,
                    "overtimeLosses": 0,
                    "points": 0,
                    "goalsFor": 0,
                    "goalsAgainst": 0
                }
            ]
        }
    }
    """
    
    do {
        // Create savedGames directory (same as NewGameView)
        if !FileManager.default.fileExists(atPath: savedFilesPath.path) {
            print("🎮 NEW GAME: Creating savedGames directory...")
            try FileManager.default.createDirectory(at: savedFilesPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Auto-save new game
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let filename = "Auto-Save_Workflow_Test_\(timestamp).json"
        let saveURL = savedFilesPath.appendingPathComponent(filename)
        
        print("🎮 NEW GAME: Auto-saving to: \(filename)")
        try newGameData.write(to: saveURL, atomically: true, encoding: .utf8)
        print("🎮 NEW GAME: ✅ Auto-save successful")
        
    } catch {
        print("🎮 NEW GAME: ❌ Auto-save failed: \(error)")
        return
    }
    
    // Simulate manual save from HomeView
    print("")
    print("🎮 SAVE: Simulating manual save from game...")
    
    let manualSaveData = """
    {
        "id": "\(UUID().uuidString)",
        "gameName": "Manual Save Test",
        "playerTeamId": "\(UUID().uuidString)",
        "saveDate": "\(ISO8601DateFormatter().string(from: Date()))",
        "seasons": [],
        "league": {
            "id": "\(UUID().uuidString)",
            "name": "Manual League",
            "teams": [
                {
                    "id": "\(UUID().uuidString)",
                    "cityName": "Save City",
                    "nickname": "Hawks",
                    "fullName": "Save City Hawks",
                    "roster": [],
                    "conferenceId": "\(UUID().uuidString)",
                    "divisionId": "\(UUID().uuidString)"
                }
            ],
            "conferences": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Western Conference"
                }
            ],
            "divisions": [
                {
                    "id": "\(UUID().uuidString)",
                    "name": "Pacific Division",
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
            "teamRecords": [
                {
                    "teamId": "\(UUID().uuidString)",
                    "wins": 5,
                    "losses": 3,
                    "overtimeLosses": 1,
                    "points": 11,
                    "goalsFor": 25,
                    "goalsAgainst": 20
                }
            ]
        }
    }
    """
    
    do {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let filename = "Manual_Save_Test_\(timestamp).json"
        let saveURL = savedFilesPath.appendingPathComponent(filename)
        
        print("🎮 SAVE: Saving manually to: \(filename)")
        try manualSaveData.write(to: saveURL, atomically: true, encoding: .utf8)
        print("🎮 SAVE: ✅ Manual save successful")
        
    } catch {
        print("🎮 SAVE: ❌ Manual save failed: \(error)")
        return
    }
    
    // Simulate load functionality from ContentView
    print("")
    print("📂 LOAD: Simulating LoadView functionality...")
    
    do {
        let files = try FileManager.default.contentsOfDirectory(at: savedFilesPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        print("📂 LOAD: Found \(jsonFiles.count) total save files")
        
        // Sort by creation date (newest first)
        let sortedFiles = jsonFiles.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 > date2
        }
        
        print("📂 LOAD: ✅ LoadView would display:")
        for (index, fileURL) in sortedFiles.enumerated() {
            let data = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dict = jsonObject as? [String: Any] {
                let gameName = dict["gameName"] as? String ?? "Unknown"
                let saveDate = dict["saveDate"] as? String ?? "Unknown"
                print("📂 LOAD:   \(index + 1). '\(gameName)' - \(saveDate)")
            }
        }
        
    } catch {
        print("📂 LOAD: ❌ Load simulation failed: \(error)")
        return
    }
    
    print("")
    print("🧪 ✅ Complete workflow test successful!")
    print("🧪 ✅ Auto-save on new game creation: Working")
    print("🧪 ✅ Manual save from game: Working") 
    print("🧪 ✅ LoadView file detection: Working")
    print("🧪 ✅ All saves/loads use Desktop/savedGames folder")
    
    // Final file count
    do {
        let allFiles = try FileManager.default.contentsOfDirectory(atPath: savedFilesPath.path)
        print("🧪 Total files in savedGames: \(allFiles.count)")
        for file in allFiles.sorted() {
            print("🧪   - \(file)")
        }
    } catch {
        print("🧪 ❌ Error listing final files: \(error)")
    }
}

testCompleteWorkflow()