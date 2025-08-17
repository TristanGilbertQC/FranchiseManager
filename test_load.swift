#!/usr/bin/env swift

import Foundation

// Test the load functionality
func testLoadFunctionality() {
    print("🧪 Testing load functionality...")
    
    let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let appName = "FranchiseManager"
    let appDirectory = appSupportPath.appendingPathComponent(appName)
    let savedFilesPath = appDirectory.appendingPathComponent("savedFiles")
    
    print("📂 LOAD: Starting load saved games list")
    print("📂 LOAD: App Support path: \(appSupportPath.path)")
    print("📂 LOAD: App directory: \(appDirectory.path)")
    print("📂 LOAD: Looking for savedFiles at: \(savedFilesPath.path)")
    
    // Check if directory exists
    if !FileManager.default.fileExists(atPath: savedFilesPath.path) {
        print("📂 LOAD: ❌ savedFiles directory does not exist!")
        return
    }
    
    print("📂 LOAD: ✅ savedFiles directory exists")
    
    do {
        let files = try FileManager.default.contentsOfDirectory(at: savedFilesPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        print("📂 LOAD: Found \(files.count) total files in directory")
        
        for file in files {
            print("📂 LOAD: Found file: \(file.lastPathComponent)")
        }
        
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        print("📂 LOAD: Found \(jsonFiles.count) JSON files")
        
        for jsonFile in jsonFiles {
            print("📂 LOAD: JSON file: \(jsonFile.lastPathComponent)")
            
            // Test loading each file
            print("🎯 PREVIEW: Starting load preview for: \(jsonFile.lastPathComponent)")
            print("🎯 PREVIEW: Reading data from: \(jsonFile.path)")
            
            do {
                let data = try Data(contentsOf: jsonFile)
                print("🎯 PREVIEW: Read \(data.count) bytes of data")
                
                // Try to parse as JSON to verify format
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = jsonObject as? [String: Any] {
                    if let gameName = dict["gameName"] as? String {
                        print("🎯 PREVIEW: ✅ Successfully parsed game: '\(gameName)'")
                    } else {
                        print("🎯 PREVIEW: ⚠️ No gameName found in JSON")
                    }
                    if let saveDate = dict["saveDate"] as? String {
                        print("🎯 PREVIEW: Save date: \(saveDate)")
                    }
                } else {
                    print("🎯 PREVIEW: ⚠️ JSON is not a dictionary")
                }
                
                print("🎯 PREVIEW: ✅ Preview loaded successfully")
                
            } catch {
                print("🎯 PREVIEW: ❌ Failed to load preview: \(error)")
                print("🎯 PREVIEW: ❌ Error details: \(error.localizedDescription)")
            }
        }
        
        let sortedFiles = jsonFiles.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 > date2
        }
        
        print("📂 LOAD: ✅ Successfully loaded \(sortedFiles.count) saved games")
        print("📂 LOAD: Files sorted by date (newest first):")
        for (index, file) in sortedFiles.enumerated() {
            let date = (try? file.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            print("📂 LOAD:   \(index + 1). \(file.lastPathComponent) - \(date)")
        }
        
    } catch {
        print("📂 LOAD: ❌ Error loading saved games: \(error)")
        print("📂 LOAD: ❌ Error details: \(error.localizedDescription)")
    }
}

testLoadFunctionality()