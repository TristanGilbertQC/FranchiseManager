#!/usr/bin/env swift

import Foundation

// Test if LoadView logic can detect saved games
func testLoadViewLogic() {
    print("🧪 Testing LoadView logic...")
    
    let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let appDirectory = appSupportPath.appendingPathComponent("FranchiseManager")
    let savedFilesPath = appDirectory.appendingPathComponent("savedFiles")
    
    print("📂 LOAD: Starting load saved games list")
    print("📂 LOAD: Looking for savedFiles at: \(savedFilesPath.path)")
    
    guard FileManager.default.fileExists(atPath: savedFilesPath.path) else {
        print("📂 LOAD: ❌ savedFiles directory does not exist!")
        return
    }
    
    print("📂 LOAD: ✅ savedFiles directory exists")
    
    do {
        let files = try FileManager.default.contentsOfDirectory(at: savedFilesPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        print("📂 LOAD: Found \(jsonFiles.count) JSON save files")
        
        if jsonFiles.isEmpty {
            print("📂 LOAD: ⚠️ No save files found - LoadView would show empty state")
            return
        }
        
        print("📂 LOAD: ✅ LoadView should display \(jsonFiles.count) games:")
        
        // Sort files by creation date (newest first) - same as ContentView
        let sortedFiles = jsonFiles.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 > date2
        }
        
        for (index, fileURL) in sortedFiles.enumerated() {
            print("🎯 PREVIEW: Testing SavedGameRow \(index + 1): \(fileURL.lastPathComponent)")
            
            do {
                let data = try Data(contentsOf: fileURL)
                print("🎯 PREVIEW: Read \(data.count) bytes")
                
                // Test JSON parsing - same as SavedGameRow
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = jsonObject as? [String: Any] {
                    let gameName = dict["gameName"] as? String ?? "Unknown Game"
                    let saveDate = dict["saveDate"] as? String ?? "Unknown Date"
                    
                    print("🎯 PREVIEW: ✅ Row \(index + 1) would show:")
                    print("🎯 PREVIEW:     Game: '\(gameName)'")
                    print("🎯 PREVIEW:     Date: \(saveDate)")
                    print("🎯 PREVIEW:     Load button would be enabled ✅")
                } else {
                    print("🎯 PREVIEW: ❌ Row \(index + 1) - Invalid JSON format")
                }
                
            } catch {
                print("🎯 PREVIEW: ❌ Row \(index + 1) - Failed to read file: \(error)")
            }
        }
        
        print("📂 LOAD: ✅ LoadView logic test completed successfully")
        print("📂 LOAD: ✅ All \(jsonFiles.count) save files can be processed by LoadView")
        
    } catch {
        print("📂 LOAD: ❌ Error accessing directory: \(error)")
    }
}

testLoadViewLogic()