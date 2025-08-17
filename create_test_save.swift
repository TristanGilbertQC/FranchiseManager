#!/usr/bin/env swift

import Foundation

// Create a minimal test save file that matches the SavedGame structure
func createTestSave() {
    print("🧪 Creating realistic test save file...")
    
    let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let savedFilesPath = appSupportPath.appendingPathComponent("FranchiseManager/savedFiles")
    
    // Create a minimal but valid SavedGame JSON structure
    let testSave = """
    {
        "id": "12345678-1234-1234-1234-123456789012",
        "gameName": "Test Game",
        "playerTeamId": "12345678-1234-1234-1234-123456789012",
        "saveDate": "\(ISO8601DateFormatter().string(from: Date()))",
        "seasons": [],
        "league": {
            "id": "12345678-1234-1234-1234-123456789012",
            "name": "Test League",
            "teams": [
                {
                    "id": "12345678-1234-1234-1234-123456789012",
                    "cityName": "Test City",
                    "nickname": "Test Team",
                    "fullName": "Test City Test Team",
                    "roster": [],
                    "conferenceId": "12345678-1234-1234-1234-123456789012",
                    "divisionId": "12345678-1234-1234-1234-123456789012"
                }
            ],
            "conferences": [
                {
                    "id": "12345678-1234-1234-1234-123456789012",
                    "name": "Test Conference"
                }
            ],
            "divisions": [
                {
                    "id": "12345678-1234-1234-1234-123456789012",
                    "name": "Test Division",
                    "conferenceId": "12345678-1234-1234-1234-123456789012"
                }
            ]
        },
        "calendar": {
            "currentDate": "\(ISO8601DateFormatter().string(from: Date()))",
            "phase": "regularSeason",
            "year": 2025
        },
        "currentSeason": {
            "id": "12345678-1234-1234-1234-123456789012",
            "year": 2025,
            "games": [],
            "teamRecords": [
                {
                    "teamId": "12345678-1234-1234-1234-123456789012",
                    "wins": 10,
                    "losses": 5,
                    "overtimeLosses": 2,
                    "points": 22,
                    "goalsFor": 50,
                    "goalsAgainst": 35
                }
            ]
        }
    }
    """
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let timestamp = formatter.string(from: Date())
    let filename = "Test_Game_\(timestamp).json"
    let filePath = savedFilesPath.appendingPathComponent(filename)
    
    do {
        try testSave.write(to: filePath, atomically: true, encoding: .utf8)
        print("🧪 ✅ Created test save file: \(filename)")
        print("🧪 File path: \(filePath.path)")
        
        // Verify file
        if FileManager.default.fileExists(atPath: filePath.path) {
            let fileSize = try FileManager.default.attributesOfItem(atPath: filePath.path)[.size] as? Int ?? 0
            print("🧪 ✅ File verified, size: \(fileSize) bytes")
        }
        
        // List all files
        let files = try FileManager.default.contentsOfDirectory(at: savedFilesPath, includingPropertiesForKeys: nil, options: [])
        print("🧪 Total files in savedFiles: \(files.count)")
        for file in files {
            print("🧪   - \(file.lastPathComponent)")
        }
        
    } catch {
        print("🧪 ❌ Error creating test save: \(error)")
    }
}

createTestSave()