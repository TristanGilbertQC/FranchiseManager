import Foundation

class SavedGamesManager {
    static let shared = SavedGamesManager()
    
    private init() {}
    
    // MARK: - Directory Management
    
    func getSavedGamesDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let savedGamesPath = documentsPath.appendingPathComponent("savedGames")
        
        // Create the directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: savedGamesPath.path) {
            do {
                try FileManager.default.createDirectory(at: savedGamesPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // Directory creation failed - let calling code handle the error
            }
        }
        
        return savedGamesPath
    }
    
    // MARK: - Save Game
    
    func saveGame(_ savedGame: SavedGame) throws -> String {
        // Update save date
        var gameToSave = savedGame
        gameToSave.saveDate = Date()
        
        // Encode the saved game to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(gameToSave)
        
        // Create filename with game name and timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let filename = "\(gameToSave.gameName)_\(timestamp).json"
        
        // Get the savedGames directory and create save path
        let savedGamesPath = getSavedGamesDirectory()
        let savePath = savedGamesPath.appendingPathComponent(filename)
        
        // Write the file
        try data.write(to: savePath)
        return filename
    }
    
    // MARK: - Load Games
    
    func loadSavedGamesList() -> [URL] {
        do {
            let savedGamesPath = getSavedGamesDirectory()
            let files = try FileManager.default.contentsOfDirectory(at: savedGamesPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            let sortedFiles = jsonFiles.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 > date2
            }
            
            return sortedFiles
        } catch {
            return []
        }
    }
    
    func loadSavedGame(from url: URL) throws -> SavedGame {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SavedGame.self, from: data)
    }
}