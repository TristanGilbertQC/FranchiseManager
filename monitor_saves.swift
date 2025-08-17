#!/usr/bin/env swift

import Foundation

func monitorSaveFiles() {
    let savedFilesPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("FranchiseManager/savedFiles")
    
    print("🔍 Monitoring save files at: \(savedFilesPath.path)")
    print("🔍 Press Ctrl+C to stop monitoring")
    print("🔍 Now go test the save functionality in the app...")
    print()
    
    var previousFileCount = 0
    var previousFiles: [String] = []
    
    // Get initial state
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: savedFilesPath.path)
        previousFileCount = files.count
        previousFiles = files.sorted()
        print("🔍 Initial state: \(previousFileCount) files")
        for file in previousFiles {
            print("🔍   - \(file)")
        }
        print()
    } catch {
        print("🔍 ❌ Error reading initial directory: \(error)")
        return
    }
    
    // Monitor for changes
    while true {
        Thread.sleep(forTimeInterval: 1.0) // Check every second
        
        do {
            let currentFiles = try FileManager.default.contentsOfDirectory(atPath: savedFilesPath.path).sorted()
            let currentFileCount = currentFiles.count
            
            if currentFileCount != previousFileCount || currentFiles != previousFiles {
                print("🚨 CHANGE DETECTED!")
                print("🚨 File count: \(previousFileCount) → \(currentFileCount)")
                
                // Find new files
                let newFiles = currentFiles.filter { !previousFiles.contains($0) }
                for newFile in newFiles {
                    print("🚨 ✅ NEW FILE: \(newFile)")
                    
                    // Try to read and display the new file content
                    let filePath = savedFilesPath.appendingPathComponent(newFile)
                    do {
                        let data = try Data(contentsOf: filePath)
                        print("🚨 📄 File size: \(data.count) bytes")
                        
                        if newFile.hasSuffix(".json") {
                            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                            if let dict = jsonObject as? [String: Any] {
                                if let gameName = dict["gameName"] as? String {
                                    print("🚨 🎮 Game saved: '\(gameName)'")
                                }
                                if let saveDate = dict["saveDate"] as? String {
                                    print("🚨 📅 Save date: \(saveDate)")
                                }
                            }
                        }
                    } catch {
                        print("🚨 ❌ Error reading new file: \(error)")
                    }
                }
                
                // Find deleted files
                let deletedFiles = previousFiles.filter { !currentFiles.contains($0) }
                for deletedFile in deletedFiles {
                    print("🚨 ❌ DELETED FILE: \(deletedFile)")
                }
                
                previousFileCount = currentFileCount
                previousFiles = currentFiles
                print()
            }
            
        } catch {
            print("🔍 ❌ Error monitoring directory: \(error)")
        }
    }
}

monitorSaveFiles()