#!/usr/bin/env swift

import Foundation

func monitorNewGameSave() {
    let savedFilesPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("FranchiseManager/savedFiles")
    
    print("🔍 Monitoring auto-save during new game creation...")
    print("🔍 Directory: \(savedFilesPath.path)")
    print("🔍 Looking for '🎮 NEW GAME' logs and new save files")
    print()
    
    // Get initial file list
    var previousFiles: [String] = []
    do {
        previousFiles = try FileManager.default.contentsOfDirectory(atPath: savedFilesPath.path).sorted()
        print("🔍 Initial files (\(previousFiles.count)):")
        for file in previousFiles {
            print("🔍   - \(file)")
        }
        print()
    } catch {
        print("🔍 ❌ Error reading directory: \(error)")
        return
    }
    
    print("🔍 Ready! Now create a new game in the app:")
    print("🔍 1. Click 'New Game' on main menu")
    print("🔍 2. Enter a game name (e.g., 'My Auto-Save Test')")
    print("🔍 3. Click 'Create Game'")
    print("🔍 4. Select a team")
    print("🔍 5. Click 'Start Managing'")
    print("🔍 6. Watch for auto-save logs and new file creation!")
    print()
    
    // Monitor for changes
    var checkCount = 0
    while checkCount < 120 { // Monitor for 2 minutes
        Thread.sleep(forTimeInterval: 1.0)
        checkCount += 1
        
        do {
            let currentFiles = try FileManager.default.contentsOfDirectory(atPath: savedFilesPath.path).sorted()
            
            if currentFiles != previousFiles {
                print("🚨 CHANGE DETECTED at \(Date())!")
                print("🚨 Files: \(previousFiles.count) → \(currentFiles.count)")
                
                // Find new files
                let newFiles = currentFiles.filter { !previousFiles.contains($0) }
                for newFile in newFiles {
                    print("🚨 ✅ NEW AUTO-SAVE FILE: \(newFile)")
                    
                    // Read and validate the new save file
                    let filePath = savedFilesPath.appendingPathComponent(newFile)
                    do {
                        let data = try Data(contentsOf: filePath)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        if let dict = jsonObject as? [String: Any] {
                            if let gameName = dict["gameName"] as? String {
                                print("🚨 🎮 Auto-saved game: '\(gameName)'")
                            }
                            if let saveDate = dict["saveDate"] as? String {
                                print("🚨 📅 Save date: \(saveDate)")
                            }
                            if let playerTeamId = dict["playerTeamId"] as? String {
                                print("🚨 👥 Player team ID: \(playerTeamId)")
                            }
                            
                            print("🚨 ✅ AUTO-SAVE SUCCESSFUL! File size: \(data.count) bytes")
                        }
                    } catch {
                        print("🚨 ❌ Error reading new file: \(error)")
                    }
                }
                
                previousFiles = currentFiles
                print()
            }
            
            if checkCount % 10 == 0 {
                print("🔍 Still monitoring... (\(checkCount)/120 seconds)")
            }
            
        } catch {
            print("🔍 ❌ Error monitoring: \(error)")
        }
    }
    
    print("🔍 Monitoring complete.")
    
    // Final file check
    do {
        let finalFiles = try FileManager.default.contentsOfDirectory(atPath: savedFilesPath.path).sorted()
        print("🔍 Final file count: \(finalFiles.count)")
        for file in finalFiles {
            print("🔍   - \(file)")
        }
    } catch {
        print("🔍 ❌ Error in final check: \(error)")
    }
}

monitorNewGameSave()