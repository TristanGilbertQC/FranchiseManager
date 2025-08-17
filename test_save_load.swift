#!/usr/bin/env swift

import Foundation

// Test the save functionality path creation
func testSaveDirectory() {
    print("🧪 Testing save directory creation...")
    
    let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let appName = "FranchiseManager"
    let appDirectory = appSupportPath.appendingPathComponent(appName)
    let savedFilesPath = appDirectory.appendingPathComponent("savedFiles")
    
    print("🧪 App Support path: \(appSupportPath.path)")
    print("🧪 App directory: \(appDirectory.path)")
    print("🧪 SavedFiles path: \(savedFilesPath.path)")
    
    do {
        // Create app directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            print("🧪 Creating app directory...")
            try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            print("🧪 ✅ Successfully created app directory")
        } else {
            print("🧪 ✅ App directory already exists")
        }
        
        // Create savedFiles directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: savedFilesPath.path) {
            print("🧪 Creating savedFiles directory...")
            try FileManager.default.createDirectory(at: savedFilesPath, withIntermediateDirectories: true, attributes: nil)
            print("🧪 ✅ Successfully created savedFiles directory")
        } else {
            print("🧪 ✅ SavedFiles directory already exists")
        }
        
        // Test writing a simple file
        let testFileName = "test_save_\(Date().timeIntervalSince1970).json"
        let testFilePath = savedFilesPath.appendingPathComponent(testFileName)
        let testData = "{\"test\": true, \"timestamp\": \"\(Date())\"}".data(using: .utf8)!
        
        print("🧪 Writing test file: \(testFileName)")
        try testData.write(to: testFilePath)
        print("🧪 ✅ Test file written successfully")
        
        // Verify file exists
        if FileManager.default.fileExists(atPath: testFilePath.path) {
            print("🧪 ✅ Test file verified on disk")
            let fileSize = try FileManager.default.attributesOfItem(atPath: testFilePath.path)[.size] as? Int ?? 0
            print("🧪 File size: \(fileSize) bytes")
        } else {
            print("🧪 ❌ Test file NOT found after write")
        }
        
        // List files in directory
        let files = try FileManager.default.contentsOfDirectory(at: savedFilesPath, includingPropertiesForKeys: nil, options: [])
        print("🧪 Files in savedFiles directory: \(files.count)")
        for file in files {
            print("🧪   - \(file.lastPathComponent)")
        }
        
    } catch {
        print("🧪 ❌ Error: \(error)")
        print("🧪 ❌ Error details: \(error.localizedDescription)")
    }
}

testSaveDirectory()