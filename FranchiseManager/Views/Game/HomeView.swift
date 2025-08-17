import SwiftUI

struct HomeView: View {
    @Binding var savedGame: SavedGame
    @StateObject private var advanceDayManager = AdvanceDayManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Season Info Header
                VStack(spacing: 8) {
                    Text("Season \(savedGame.seasonDisplayString)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(savedGame.currentPhase.displayName)
                        .font(.headline)
                        .foregroundColor(.cyan)
                    
                    Text(savedGame.calendar.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let team = savedGame.league.teams.first(where: { $0.id == savedGame.playerTeamId }) {
                        let record = savedGame.currentSeason.recordFor(teamId: team.id)
                        Text("\(record.wins)W - \(record.losses)L - \(record.overtimeLosses)OTL")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                // Upcoming Games
                VStack(alignment: .leading, spacing: 12) {
                    Text("Upcoming Games")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if savedGame.currentSeason.games.isEmpty {
                        Text("No games scheduled")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(savedGame.currentSeason.games.prefix(5), id: \.id) { game in
                            GameRowView(game: game, savedGame: savedGame)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                // Upcoming Events
                VStack(alignment: .leading, spacing: 12) {
                    Text("Upcoming Events")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    let upcomingEvents = savedGame.getUpcomingEvents(limit: 5)
                    
                    if upcomingEvents.isEmpty {
                        Text("No upcoming events")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(upcomingEvents, id: \.id) { event in
                            EventRowView(event: event)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                // Quick Actions
                VStack(spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if advanceDayManager.isSimulating {
                        VStack(spacing: 10) {
                            ProgressView(value: advanceDayManager.simulationProgress)
                                .frame(maxWidth: 300)
                            
                            Text(advanceDayManager.simulationStatus)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else {
                        HStack(spacing: 15) {
                            Button("Simulate Next Game") {
                                // TODO: Implement single game simulation
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            
                            Button("Advance Day") {
                                advanceOneDay()
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .disabled(advanceDayManager.isSimulating)
                        }
                        
                        HStack(spacing: 15) {
                            Button("Advance Week") {
                                advanceMultipleDays(7)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .disabled(advanceDayManager.isSimulating)
                            
                            Button("Save Game") {
                                simpleSave()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        
                        HStack(spacing: 15) {
                            Button("Next Phase") {
                                advanceToNextPhase()
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .disabled(advanceDayManager.isSimulating)
                            
                            Button("tj") {
                                // TODO: Add tj button functionality
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                
                Spacer()
            }
            .padding()
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .onAppear {
            print("🏠 HOME: HomeView appeared - game name: '\(savedGame.gameName)'")
        }
    }
    
    private func advanceOneDay() {
        Task { @MainActor in
            do {
                savedGame = try await advanceDayManager.advanceDay(savedGame: savedGame)
            } catch {
                print("Error advancing day: \(error)")
            }
        }
    }
    
    private func advanceMultipleDays(_ days: Int) {
        Task { @MainActor in
            for _ in 0..<days {
                do {
                    savedGame = try await advanceDayManager.advanceDay(savedGame: savedGame)
                } catch {
                    print("Error advancing day: \(error)")
                    break
                }
            }
        }
    }
    
    private func advanceToNextPhase() {
        savedGame.calendar.transitionToNextPhase()
    }
    
    private func simpleSave() {
        print("💾 SIMPLE SAVE: ====== STARTING SAVE PROCESS ======")
        print("💾 SIMPLE SAVE: Step 1 - Initializing save")
        print("💾 SIMPLE SAVE: Game name: '\(savedGame.gameName)'")
        print("💾 SIMPLE SAVE: Game ID: '\(savedGame.id)'")
        print("💾 SIMPLE SAVE: Player team ID: '\(savedGame.playerTeamId)'")
        
        print("💾 SIMPLE SAVE: Step 2 - Getting file system paths")
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let savedGamesPath = documentsPath.appendingPathComponent("savedGames")
        
        print("💾 SIMPLE SAVE: Documents path: \(documentsPath.path)")
        print("💾 SIMPLE SAVE: savedGames path: \(savedGamesPath.path)")
        
        do {
            print("💾 SIMPLE SAVE: Step 3 - Checking directory existence")
            let directoryExists = FileManager.default.fileExists(atPath: savedGamesPath.path)
            print("💾 SIMPLE SAVE: Directory exists: \(directoryExists)")
            
            if !directoryExists {
                print("💾 SIMPLE SAVE: Step 3a - Creating savedGames directory")
                try FileManager.default.createDirectory(at: savedGamesPath, withIntermediateDirectories: true, attributes: nil)
                print("💾 SIMPLE SAVE: ✅ Directory created successfully")
                
                // Double-check directory was created
                let dirCreated = FileManager.default.fileExists(atPath: savedGamesPath.path)
                print("💾 SIMPLE SAVE: Directory verification: \(dirCreated)")
            } else {
                print("💾 SIMPLE SAVE: Directory already exists - continuing")
            }
            
            print("💾 SIMPLE SAVE: Step 4 - Creating filename")
            let now = Date()
            print("💾 SIMPLE SAVE: Current date: \(now)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let timestamp = dateFormatter.string(from: now)
            print("💾 SIMPLE SAVE: Formatted timestamp: \(timestamp)")
            
            let cleanGameName = savedGame.gameName.replacingOccurrences(of: " ", with: "_")
            print("💾 SIMPLE SAVE: Clean game name: '\(cleanGameName)'")
            
            let filename = "\(cleanGameName)_\(timestamp).json"
            print("💾 SIMPLE SAVE: Final filename: '\(filename)'")
            
            let saveURL = savedGamesPath.appendingPathComponent(filename)
            print("💾 SIMPLE SAVE: Full save URL: \(saveURL.absoluteString)")
            print("💾 SIMPLE SAVE: Full save path: \(saveURL.path)")
            
            print("💾 SIMPLE SAVE: Step 5 - Encoding game data to JSON")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            print("💾 SIMPLE SAVE: JSON encoder configured")
            
            print("💾 SIMPLE SAVE: Starting JSON encoding...")
            let jsonData = try encoder.encode(savedGame)
            print("💾 SIMPLE SAVE: ✅ JSON encoding successful")
            print("💾 SIMPLE SAVE: Encoded data size: \(jsonData.count) bytes")
            
            // Preview first 100 characters of JSON
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let preview = String(jsonString.prefix(100))
                print("💾 SIMPLE SAVE: JSON preview: \(preview)...")
            }
            
            print("💾 SIMPLE SAVE: Step 6 - Writing file to disk")
            print("💾 SIMPLE SAVE: About to write to: \(saveURL.path)")
            
            try jsonData.write(to: saveURL)
            print("💾 SIMPLE SAVE: ✅ File write operation completed")
            
            print("💾 SIMPLE SAVE: Step 7 - Verifying file was written")
            let fileExists = FileManager.default.fileExists(atPath: saveURL.path)
            print("💾 SIMPLE SAVE: File exists after write: \(fileExists)")
            
            if fileExists {
                // Get file size for verification
                let attributes = try FileManager.default.attributesOfItem(atPath: saveURL.path)
                if let fileSize = attributes[.size] as? Int {
                    print("💾 SIMPLE SAVE: File size on disk: \(fileSize) bytes")
                    print("💾 SIMPLE SAVE: Size match: \(fileSize == jsonData.count)")
                }
                print("💾 SIMPLE SAVE: ✅ File verified successfully on disk")
            } else {
                print("💾 SIMPLE SAVE: ❌ FILE NOT FOUND AFTER WRITE - THIS IS A PROBLEM")
            }
            
            print("💾 SIMPLE SAVE: Step 8 - Listing directory contents")
            let dirContents = try FileManager.default.contentsOfDirectory(atPath: savedGamesPath.path)
            print("💾 SIMPLE SAVE: Directory contains \(dirContents.count) files:")
            for file in dirContents.sorted() {
                print("💾 SIMPLE SAVE:   - \(file)")
            }
            
            print("💾 SIMPLE SAVE: ====== SAVE PROCESS COMPLETED SUCCESSFULLY ======")
            
        } catch {
            print("💾 SIMPLE SAVE: ❌ ERROR OCCURRED: \(error)")
            print("💾 SIMPLE SAVE: Error type: \(type(of: error))")
            print("💾 SIMPLE SAVE: Error description: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("💾 SIMPLE SAVE: Error domain: \(nsError.domain)")
                print("💾 SIMPLE SAVE: Error code: \(nsError.code)")
                print("💾 SIMPLE SAVE: Error userInfo: \(nsError.userInfo)")
            }
            print("💾 SIMPLE SAVE: ====== SAVE PROCESS FAILED ======")
        }
    }
}