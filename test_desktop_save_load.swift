#!/usr/bin/env swift

import Foundation

// Test the new Desktop-based save/load functionality
func testDesktopSaveLoad() {
    print("🧪 Testing Desktop savedGames folder functionality...")
    
    // Test save path
    let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
    let savedFilesPath = desktopPath.appendingPathComponent("savedGames")
    
    print("🎮 SAVE: Desktop path: \(desktopPath.path)")
    print("🎮 SAVE: Target savedGames path: \(savedFilesPath.path)")
    
    do {
        // Ensure directory exists
        if !FileManager.default.fileExists(atPath: savedFilesPath.path) {
            print("🎮 SAVE: Creating savedGames directory...")
            try FileManager.default.createDirectory(at: savedFilesPath, withIntermediateDirectories: true, attributes: nil)
            print("🎮 SAVE: ✅ Successfully created savedGames directory")
        } else {
            print("🎮 SAVE: ✅ savedGames directory already exists")
        }
        
        // Create test save file
        let testGameData = """
        {
            "id": "\(UUID().uuidString)",
            "gameName": "Desktop Test Game",
            "playerTeamId": "\(UUID().uuidString)",
            "saveDate": "\(ISO8601DateFormatter().string(from: Date()))",
            "seasons": [],
            "league": {
                "id": "\(UUID().uuidString)",
                "name": "Desktop League",
                "teams": [
                    {
                        "id": "\(UUID().uuidString)",
                        "cityName": "Desktop City",
                        "nickname": "Test Team",
                        "fullName": "Desktop City Test Team",
                        "roster": [],
                        "conferenceId": "\(UUID().uuidString)",
                        "divisionId": "\(UUID().uuidString)"
                    }
                ],
                "conferences": [
                    {
                        "id": "\(UUID().uuidString)",
                        "name": "Desktop Conference"
                    }
                ],
                "divisions": [
                    {
                        "id": "\(UUID().uuidString)",
                        "name": "Desktop Division",
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
        
        // Save test file
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let filename = "Desktop_Test_Game_\(timestamp).json"
        let saveURL = savedFilesPath.appendingPathComponent(filename)
        
        print("🎮 SAVE: Writing test file: \(filename)")
        try testGameData.write(to: saveURL, atomically: true, encoding: .utf8)
        print("🎮 SAVE: ✅ Successfully wrote test file")
        
        // Verify file exists
        if FileManager.default.fileExists(atPath: saveURL.path) {
            let fileSize = try FileManager.default.attributesOfItem(atPath: saveURL.path)[.size] as? Int ?? 0
            print("🎮 SAVE: ✅ File verified on disk, size: \(fileSize) bytes")
        }
        
    } catch {
        print("🎮 SAVE: ❌ Error in save test: \(error)")
        return
    }
    
    // Test load functionality
    print("")
    print("📂 LOAD: Testing load functionality...")
    print("📂 LOAD: Looking for savedGames at: \(savedFilesPath.path)")
    
    do {
        let files = try FileManager.default.contentsOfDirectory(at: savedFilesPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        print("📂 LOAD: Found \(jsonFiles.count) JSON save files")
        
        for (index, fileURL) in jsonFiles.enumerated() {
            print("📂 LOAD: File \(index + 1): \(fileURL.lastPathComponent)")
            
            // Test loading the file
            do {
                let data = try Data(contentsOf: fileURL)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let dict = jsonObject as? [String: Any] {
                    let gameName = dict["gameName"] as? String ?? "Unknown"
                    let saveDate = dict["saveDate"] as? String ?? "Unknown"
                    print("🎯 PREVIEW: Game: '\(gameName)', Date: \(saveDate)")
                }
                
            } catch {
                print("🎯 PREVIEW: ❌ Error loading \(fileURL.lastPathComponent): \(error)")
            }
        }
        
        print("📂 LOAD: ✅ Load test completed successfully")
        
    } catch {
        print("📂 LOAD: ❌ Error in load test: \(error)")
    }
    
    // Final summary
    print("")
    print("🧪 ✅ Desktop save/load functionality test completed")
    print("🧪 Save path: \(savedFilesPath.path)")
    
    // List all files
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: savedFilesPath.path)
        print("🧪 Total files in savedGames: \(files.count)")
        for file in files.sorted() {
            print("🧪   - \(file)")
        }
    } catch {
        print("🧪 ❌ Error listing final files: \(error)")
    }
}

testDesktopSaveLoad()