import Foundation
import SwiftUI

// MARK: - Game Simulation Errors

enum AdvanceDayError: Error {
    case invalidTeamConfiguration(String)
    case missingGameData(String)
    case saveLoadFailure(String)
    case malformedLineupData(String)
}

// MARK: - Team Lineup Model

struct TeamLineup: Codable, Identifiable {
    var id: UUID
    var teamId: UUID
    var forwardLines: [[UUID]] // 4 lines of 3 players each
    var defensePairs: [[UUID]] // 3 pairs of 2 players each
    var startingGoalie: UUID?
    var backupGoalie: UUID?
    
    init(teamId: UUID) {
        self.id = UUID()
        self.teamId = teamId
        self.forwardLines = Array(repeating: [], count: 4)
        self.defensePairs = Array(repeating: [], count: 3)
    }
    
    var isValid: Bool {
        let hasValidForwardLines = forwardLines.allSatisfy { $0.count == 3 }
        let hasValidDefensePairs = defensePairs.allSatisfy { $0.count == 2 }
        let hasGoalies = startingGoalie != nil && backupGoalie != nil
        
        return hasValidForwardLines && hasValidDefensePairs && hasGoalies
    }
    
    func getAllPlayerIds() -> Set<UUID> {
        var allIds = Set<UUID>()
        
        for line in forwardLines {
            allIds.formUnion(line)
        }
        
        for pair in defensePairs {
            allIds.formUnion(pair)
        }
        
        if let startingGoalie = startingGoalie {
            allIds.insert(startingGoalie)
        }
        
        if let backupGoalie = backupGoalie {
            allIds.insert(backupGoalie)
        }
        
        return allIds
    }
}

// MARK: - Game Result Model

struct SimulationGameResult: Codable, Identifiable {
    var id: UUID
    var gameId: UUID
    var homeTeamId: UUID
    var awayTeamId: UUID
    var homeScore: Int
    var awayScore: Int
    var isOvertime: Bool
    var isShootout: Bool
    var date: Date
    var playerStats: [UUID: PlayerStats]
    
    var winningTeamId: UUID {
        return homeScore > awayScore ? homeTeamId : awayTeamId
    }
    
    var losingTeamId: UUID {
        return homeScore < awayScore ? homeTeamId : awayTeamId
    }
    
    var wasShutout: Bool {
        return homeScore == 0 || awayScore == 0
    }
    
    init(gameId: UUID, homeTeamId: UUID, awayTeamId: UUID, homeScore: Int, awayScore: Int, isOvertime: Bool, isShootout: Bool, date: Date, playerStats: [UUID: PlayerStats] = [:]) {
        self.id = UUID()
        self.gameId = gameId
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.isOvertime = isOvertime
        self.isShootout = isShootout
        self.date = date
        self.playerStats = playerStats
    }
}

// MARK: - Lineup Manager

class LineupManager {
    
    static func generateOptimalLineup(for team: Team) throws -> TeamLineup {
        let availablePlayers = team.roster.filter { !$0.injuryStatus.isInjured }
        
        // Separate players by position
        let centers = availablePlayers.filter { $0.position == .center }.sorted { $0.overall > $1.overall }
        let leftWings = availablePlayers.filter { $0.position == .leftWing }.sorted { $0.overall > $1.overall }
        let rightWings = availablePlayers.filter { $0.position == .rightWing }.sorted { $0.overall > $1.overall }
        let leftDefense = availablePlayers.filter { $0.position == .leftDefense }.sorted { $0.overall > $1.overall }
        let rightDefense = availablePlayers.filter { $0.position == .rightDefense }.sorted { $0.overall > $1.overall }
        let goalies = availablePlayers.filter { $0.position == .goalie }.sorted { $0.overall > $1.overall }
        
        // Validate minimum requirements
        guard centers.count >= 4 || availablePlayers.filter({ $0.position == .center || $0.position == .leftWing || $0.position == .rightWing }).count >= 12 else {
            throw AdvanceDayError.invalidTeamConfiguration("Team \(team.name) does not have enough forwards")
        }
        
        guard leftDefense.count >= 3 || rightDefense.count >= 3 || (leftDefense.count + rightDefense.count) >= 6 else {
            throw AdvanceDayError.invalidTeamConfiguration("Team \(team.name) does not have enough defensemen")
        }
        
        guard goalies.count >= 2 else {
            throw AdvanceDayError.invalidTeamConfiguration("Team \(team.name) does not have enough goalies")
        }
        
        var lineup = TeamLineup(teamId: team.id)
        
        // Create forward lines - mix best players across lines but prioritize line 1
        let allForwards = (centers + leftWings + rightWings).sorted { $0.overall > $1.overall }
        
        for lineIndex in 0..<4 {
            var line: [UUID] = []
            
            // Try to get a center for each line first
            if lineIndex < centers.count {
                line.append(centers[lineIndex].id)
            }
            
            // Fill remaining spots with best available forwards
            let remainingForwards = allForwards.filter { player in
                !lineup.getAllPlayerIds().contains(player.id)
            }
            
            while line.count < 3 && !remainingForwards.isEmpty {
                let nextBest = remainingForwards.first { !lineup.getAllPlayerIds().contains($0.id) }
                if let player = nextBest {
                    line.append(player.id)
                }
            }
            
            // If still not enough, pad with any available forward
            while line.count < 3 {
                if let anyForward = allForwards.first(where: { !lineup.getAllPlayerIds().contains($0.id) }) {
                    line.append(anyForward.id)
                } else {
                    break
                }
            }
            
            lineup.forwardLines[lineIndex] = line
        }
        
        // Create defense pairs
        let allDefense = (leftDefense + rightDefense).sorted { $0.overall > $1.overall }
        
        for pairIndex in 0..<3 {
            var pair: [UUID] = []
            
            let remainingDefense = allDefense.filter { !lineup.getAllPlayerIds().contains($0.id) }
            
            for _ in 0..<2 {
                if let defender = remainingDefense.first(where: { !lineup.getAllPlayerIds().contains($0.id) }) {
                    pair.append(defender.id)
                }
            }
            
            lineup.defensePairs[pairIndex] = pair
        }
        
        // Assign goalies
        lineup.startingGoalie = goalies.first?.id
        lineup.backupGoalie = goalies.count > 1 ? goalies[1].id : goalies.first?.id
        
        guard lineup.isValid else {
            throw AdvanceDayError.malformedLineupData("Generated lineup for team \(team.name) is invalid")
        }
        
        return lineup
    }
    
    static func getLineDeploymentPercent(lineNumber: Int) -> Double {
        switch lineNumber {
        case 0: return 0.30 // Line 1: 30%
        case 1: return 0.25 // Line 2: 25%
        case 2: return 0.25 // Line 3: 25%
        case 3: return 0.20 // Line 4: 20%
        default: return 0.20
        }
    }
    
    static func getDefenseDeploymentPercent(pairNumber: Int) -> Double {
        switch pairNumber {
        case 0: return 0.40 // Top pair: 40%
        case 1: return 0.35 // Second pair: 35%
        case 2: return 0.25 // Third pair: 25%
        default: return 0.25
        }
    }
}

// MARK: - Game Simulator

class GameSimulator {
    
    static func simulateGame(homeTeam: Team, awayTeam: Team, homeLineup: TeamLineup, awayLineup: TeamLineup, date: Date) throws -> SimulationGameResult {
        
        // Calculate team strengths
        let homeOffensiveStrength = calculateOffensiveStrength(team: homeTeam, lineup: homeLineup)
        let homeDefensiveStrength = calculateDefensiveStrength(team: homeTeam, lineup: homeLineup)
        
        let awayOffensiveStrength = calculateOffensiveStrength(team: awayTeam, lineup: awayLineup)
        let awayDefensiveStrength = calculateDefensiveStrength(team: awayTeam, lineup: awayLineup)
        
        // Calculate expected goals using simple model
        let homeExpectedGoals = Double(homeOffensiveStrength) / (Double(awayDefensiveStrength) + 50.0) * 3.0
        let awayExpectedGoals = Double(awayOffensiveStrength) / (Double(homeDefensiveStrength) + 50.0) * 3.0
        
        // Generate actual goals using Poisson distribution approximation
        let homeGoals = generateGoalsFromExpected(homeExpectedGoals)
        let awayGoals = generateGoalsFromExpected(awayExpectedGoals)
        
        var finalHomeScore = homeGoals
        var finalAwayScore = awayGoals
        var isOvertime = false
        var isShootout = false
        
        // Handle overtime/shootout
        if homeGoals == awayGoals {
            isOvertime = true
            if Double.random(in: 0...1) < 0.5 {
                finalHomeScore += 1
            } else {
                finalAwayScore += 1
            }
            
            // 30% chance it goes to shootout instead of OT goal
            if Double.random(in: 0...1) < 0.3 {
                isShootout = true
            }
        }
        
        // Generate player statistics
        var playerStats: [UUID: PlayerStats] = [:]
        
        // Generate stats for home team
        let homeStats = generatePlayerStats(
            team: homeTeam, 
            lineup: homeLineup, 
            teamGoals: finalHomeScore, 
            opponentGoals: finalAwayScore,
            isHome: true,
            isOvertime: isOvertime,
            isShootout: isShootout
        )
        playerStats.merge(homeStats) { _, new in new }
        
        // Generate stats for away team
        let awayStats = generatePlayerStats(
            team: awayTeam, 
            lineup: awayLineup, 
            teamGoals: finalAwayScore, 
            opponentGoals: finalHomeScore,
            isHome: false,
            isOvertime: isOvertime,
            isShootout: isShootout
        )
        playerStats.merge(awayStats) { _, new in new }
        
        let result = SimulationGameResult(
            gameId: UUID(),
            homeTeamId: homeTeam.id,
            awayTeamId: awayTeam.id,
            homeScore: finalHomeScore,
            awayScore: finalAwayScore,
            isOvertime: isOvertime,
            isShootout: isShootout,
            date: date,
            playerStats: playerStats
        )
        
        return result
    }
    
    private static func calculateOffensiveStrength(team: Team, lineup: TeamLineup) -> Int {
        var totalStrength = 0
        var playerCount = 0
        
        // Calculate forward strength
        for line in lineup.forwardLines {
            for playerId in line {
                if let player = team.roster.first(where: { $0.id == playerId }),
                   let attributes = player.skaterAttributes {
                    let offensiveRating = (attributes.shootingAccuracy + attributes.shootingPower + 
                                         attributes.passingAccuracy + attributes.passingVision + 
                                         attributes.speed) / 5
                    totalStrength += offensiveRating
                    playerCount += 1
                }
            }
        }
        
        return playerCount > 0 ? totalStrength / playerCount : 50
    }
    
    private static func calculateDefensiveStrength(team: Team, lineup: TeamLineup) -> Int {
        var totalStrength = 0
        var playerCount = 0
        
        // Calculate defense strength
        for pair in lineup.defensePairs {
            for playerId in pair {
                if let player = team.roster.first(where: { $0.id == playerId }),
                   let attributes = player.skaterAttributes {
                    let defensiveRating = (attributes.defensivePositioning + attributes.stickChecking + 
                                         attributes.gapControl + attributes.shotBlocking + 
                                         attributes.bodyChecking) / 5
                    totalStrength += defensiveRating
                    playerCount += 1
                }
            }
        }
        
        // Add goalie strength
        if let goalieId = lineup.startingGoalie,
           let goalie = team.roster.first(where: { $0.id == goalieId }),
           let attributes = goalie.goalieAttributes {
            totalStrength += attributes.overall
            playerCount += 1
        }
        
        return playerCount > 0 ? totalStrength / playerCount : 50
    }
    
    private static func generateGoalsFromExpected(_ expectedGoals: Double) -> Int {
        // Simple Poisson approximation using random sampling
        let lambda = max(0.5, min(8.0, expectedGoals)) // Clamp between 0.5 and 8
        
        var goals = 0
        var probability = exp(-lambda)
        var cumulativeProbability = probability
        let randomValue = Double.random(in: 0...1)
        
        while cumulativeProbability < randomValue && goals < 10 {
            goals += 1
            probability *= lambda / Double(goals)
            cumulativeProbability += probability
        }
        
        return goals
    }
    
    private static func generatePlayerStats(team: Team, lineup: TeamLineup, teamGoals: Int, opponentGoals: Int, isHome: Bool, isOvertime: Bool, isShootout: Bool) -> [UUID: PlayerStats] {
        
        var playerStats: [UUID: PlayerStats] = [:]
        var goalsRemaining = teamGoals
        var assistsRemaining = teamGoals * 2 // Each goal can have up to 2 assists
        
        // Generate stats for forwards
        for (lineIndex, line) in lineup.forwardLines.enumerated() {
            let deploymentPercent = LineupManager.getLineDeploymentPercent(lineNumber: lineIndex)
            let baseTOI = Int(3600.0 * deploymentPercent) // Time on ice in seconds
            
            for playerId in line {
                guard let player = team.roster.first(where: { $0.id == playerId }) else { continue }
                
                var stats = PlayerStats()
                
                // Time on ice
                let variation = Double.random(in: 0.8...1.2)
                stats.timeOnIce = Int(Double(baseTOI) * variation)
                
                // Goals (higher chance for better players and top lines)
                let goalProbability = calculateGoalProbability(player: player, lineIndex: lineIndex)
                if goalsRemaining > 0 && Double.random(in: 0...1) < goalProbability {
                    stats.goals = 1
                    goalsRemaining -= 1
                }
                
                // Assists (higher for centers and good passers)
                let assistProbability = calculateAssistProbability(player: player, lineIndex: lineIndex)
                if assistsRemaining > 0 && Double.random(in: 0...1) < assistProbability {
                    let assists = min(assistsRemaining, Int.random(in: 1...2))
                    stats.assists = assists
                    assistsRemaining -= assists
                }
                
                // Other stats
                stats.shots = generateShots(player: player, deploymentPercent: deploymentPercent)
                stats.hits = generateHits(player: player, deploymentPercent: deploymentPercent)
                stats.blocks = generateBlocks(player: player, deploymentPercent: deploymentPercent)
                stats.penaltyMinutes = generatePenaltyMinutes(player: player)
                
                // +/- calculation
                let goalDifferential = teamGoals - opponentGoals
                let plusMinusVariation = Int.random(in: -1...1)
                stats.plusMinus = (goalDifferential + plusMinusVariation)
                
                // Faceoffs for centers
                if player.position == .center {
                    stats.faceoffAttempts = Int.random(in: 5...25)
                    let faceoffSkill = player.skaterAttributes?.positioning ?? 50
                    let faceoffWinRate = Double(faceoffSkill) / 100.0
                    stats.faceoffWins = Int(Double(stats.faceoffAttempts) * faceoffWinRate)
                }
                
                playerStats[playerId] = stats
            }
        }
        
        // Generate stats for defense
        for (pairIndex, pair) in lineup.defensePairs.enumerated() {
            let deploymentPercent = LineupManager.getDefenseDeploymentPercent(pairNumber: pairIndex)
            let baseTOI = Int(3600.0 * deploymentPercent)
            
            for playerId in pair {
                guard let player = team.roster.first(where: { $0.id == playerId }) else { continue }
                
                var stats = PlayerStats()
                
                let variation = Double.random(in: 0.8...1.2)
                stats.timeOnIce = Int(Double(baseTOI) * variation)
                
                // Defense rarely score but can get assists
                if assistsRemaining > 0 && Double.random(in: 0...1) < 0.15 {
                    stats.assists = 1
                    assistsRemaining -= 1
                }
                
                stats.shots = generateShots(player: player, deploymentPercent: deploymentPercent) / 2 // Defense shoot less
                stats.hits = generateHits(player: player, deploymentPercent: deploymentPercent)
                stats.blocks = generateBlocks(player: player, deploymentPercent: deploymentPercent) * 2 // Defense block more
                stats.penaltyMinutes = generatePenaltyMinutes(player: player)
                
                let goalDifferential = teamGoals - opponentGoals
                let plusMinusVariation = Int.random(in: -1...1)
                stats.plusMinus = (goalDifferential + plusMinusVariation)
                
                playerStats[playerId] = stats
            }
        }
        
        // Generate goalie stats
        if let goalieId = lineup.startingGoalie,
           let _ = team.roster.first(where: { $0.id == goalieId }) {
            
            var stats = PlayerStats()
            
            stats.timeOnIce = 3600 // Full game
            stats.goalsAgainst = opponentGoals
            
            // Generate shots against (typically 25-35 per game)
            stats.shotsAgainst = Int.random(in: 20...40)
            stats.saves = stats.shotsAgainst - opponentGoals
            
            // Goalie record
            if teamGoals > opponentGoals {
                stats.wins = 1
            } else if isOvertime || isShootout {
                stats.overtimeLosses = 1
            } else {
                stats.losses = 1
            }
            
            if opponentGoals == 0 {
                stats.shutouts = 1
            }
            
            playerStats[goalieId] = stats
        }
        
        return playerStats
    }
    
    private static func calculateGoalProbability(player: Player, lineIndex: Int) -> Double {
        guard let attributes = player.skaterAttributes else { return 0.02 }
        
        let shootingSkill = Double(attributes.shootingAccuracy + attributes.shootingPower) / 200.0
        let lineMultiplier = LineupManager.getLineDeploymentPercent(lineNumber: lineIndex)
        
        return shootingSkill * lineMultiplier * 0.3 // Base goal probability
    }
    
    private static func calculateAssistProbability(player: Player, lineIndex: Int) -> Double {
        guard let attributes = player.skaterAttributes else { return 0.03 }
        
        let passingSkill = Double(attributes.passingAccuracy + attributes.passingVision) / 200.0
        let lineMultiplier = LineupManager.getLineDeploymentPercent(lineNumber: lineIndex)
        let positionMultiplier = player.position == .center ? 1.3 : 1.0
        
        return passingSkill * lineMultiplier * positionMultiplier * 0.4
    }
    
    private static func generateShots(player: Player, deploymentPercent: Double) -> Int {
        guard let attributes = player.skaterAttributes else { return 0 }
        
        let shootingTendency = Double(attributes.shootingAccuracy + attributes.shootingPower) / 200.0
        let baseShots = deploymentPercent * 8.0 // Base shots based on ice time
        let actualShots = baseShots * shootingTendency * Double.random(in: 0.5...1.5)
        
        return max(0, Int(actualShots))
    }
    
    private static func generateHits(player: Player, deploymentPercent: Double) -> Int {
        guard let attributes = player.skaterAttributes else { return 0 }
        
        let hittingTendency = Double(attributes.bodyChecking + attributes.strength) / 200.0
        let baseHits = deploymentPercent * 3.0
        let actualHits = baseHits * hittingTendency * Double.random(in: 0.5...2.0)
        
        return max(0, Int(actualHits))
    }
    
    private static func generateBlocks(player: Player, deploymentPercent: Double) -> Int {
        guard let attributes = player.skaterAttributes else { return 0 }
        
        let blockingTendency = Double(attributes.shotBlocking + attributes.positioning) / 200.0
        let baseBlocks = deploymentPercent * 2.0
        let actualBlocks = baseBlocks * blockingTendency * Double.random(in: 0.3...1.8)
        
        return max(0, Int(actualBlocks))
    }
    
    private static func generatePenaltyMinutes(player: Player) -> Int {
        guard let attributes = player.skaterAttributes else { return 0 }
        
        let disciplineFactor = Double(100 - attributes.discipline) / 100.0
        let penaltyProbability = disciplineFactor * 0.15
        
        if Double.random(in: 0...1) < penaltyProbability {
            return [2, 2, 2, 4, 5, 10].randomElement() ?? 2 // Most penalties are 2 minutes
        }
        
        return 0
    }
}

// MARK: - Advance Day Manager

@MainActor
class AdvanceDayManager: ObservableObject {
    
    @Published var isSimulating = false
    @Published var simulationProgress = 0.0
    @Published var simulationStatus = ""
    
    func advanceDay(savedGame: SavedGame) async throws -> SavedGame {
        self.isSimulating = true
        self.simulationProgress = 0.0
        self.simulationStatus = "Starting day simulation..."
        
        var updatedGame = savedGame
        let currentDate = updatedGame.currentDate
        
        // Step 1: Generate lineups for teams that need them
        self.simulationProgress = 0.1
        self.simulationStatus = "Generating team lineups..."
        
        var teamLineups: [UUID: TeamLineup] = [:]
        
        for team in updatedGame.league.teams {
            do {
                let lineup = try LineupManager.generateOptimalLineup(for: team)
                teamLineups[team.id] = lineup
            } catch {
                print("Error generating lineup for team \(team.name): \(error)")
                // Create minimal lineup or skip team
            }
        }
        
        // Step 2: Find games scheduled for today
        self.simulationProgress = 0.2
        self.simulationStatus = "Finding scheduled games..."
        
        let todaysGames = updatedGame.currentSeason.games.filter { game in
            Calendar.current.isDate(game.date, inSameDayAs: currentDate) && !game.isCompleted
        }
        
        // Step 3: Simulate each game
        var completedGames: [SimulationGameResult] = []
        
        for (index, game) in todaysGames.enumerated() {
            let progress = 0.2 + (Double(index) / Double(todaysGames.count)) * 0.6
            self.simulationProgress = progress
            self.simulationStatus = "Simulating game \(index + 1) of \(todaysGames.count)..."
            
            guard let homeTeam = updatedGame.league.teams.first(where: { $0.id == game.homeTeamId }),
                  let awayTeam = updatedGame.league.teams.first(where: { $0.id == game.awayTeamId }),
                  let homeLineup = teamLineups[game.homeTeamId],
                  let awayLineup = teamLineups[game.awayTeamId] else {
                continue
            }
            
            do {
                let result = try GameSimulator.simulateGame(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    homeLineup: homeLineup,
                    awayLineup: awayLineup,
                    date: currentDate
                )
                
                completedGames.append(result)
                
                // Update game as completed
                if let gameIndex = updatedGame.currentSeason.games.firstIndex(where: { $0.id == game.id }) {
                    updatedGame.currentSeason.games[gameIndex].isCompleted = true
                    updatedGame.currentSeason.games[gameIndex].result = BasicGameResult(
                        homeTeamId: result.homeTeamId,
                        awayTeamId: result.awayTeamId,
                        homeScore: result.homeScore,
                        awayScore: result.awayScore,
                        overtime: result.isOvertime,
                        shootout: result.isShootout,
                        date: result.date
                    )
                }
                
            } catch {
                print("Error simulating game: \(error)")
            }
        }
        
        // Step 4: Update team records and player stats
        self.simulationProgress = 0.8
        self.simulationStatus = "Updating team records and player stats..."
        
        for result in completedGames {
            // Update team records
            updateTeamRecord(savedGame: &updatedGame, result: result)
            
            // Update player stats
            updatePlayerStats(savedGame: &updatedGame, result: result)
        }
        
        // Step 5: Handle injury recovery
        self.simulationProgress = 0.9
        self.simulationStatus = "Processing injury recovery..."
        
        for teamIndex in updatedGame.league.teams.indices {
            for playerIndex in updatedGame.league.teams[teamIndex].roster.indices {
                updatedGame.league.teams[teamIndex].roster[playerIndex].advanceDay()
            }
        }
        
        // Step 6: Advance the date
        try updatedGame.advanceDate(by: 1)
        
        self.simulationProgress = 1.0
        self.simulationStatus = "Day simulation complete!"
        self.isSimulating = false
        
        // Brief delay to show completion
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return updatedGame
    }
    
    private func updateTeamRecord(savedGame: inout SavedGame, result: SimulationGameResult) {
        // Update home team record
        if let homeIndex = savedGame.league.teams.firstIndex(where: { $0.id == result.homeTeamId }) {
            if result.homeScore > result.awayScore {
                savedGame.league.teams[homeIndex].record.wins += 1
            } else if result.isOvertime || result.isShootout {
                savedGame.league.teams[homeIndex].record.overtimeLosses += 1
            } else {
                savedGame.league.teams[homeIndex].record.losses += 1
            }
        }
        
        // Update away team record
        if let awayIndex = savedGame.league.teams.firstIndex(where: { $0.id == result.awayTeamId }) {
            if result.awayScore > result.homeScore {
                savedGame.league.teams[awayIndex].record.wins += 1
            } else if result.isOvertime || result.isShootout {
                savedGame.league.teams[awayIndex].record.overtimeLosses += 1
            } else {
                savedGame.league.teams[awayIndex].record.losses += 1
            }
        }
    }
    
    private func updatePlayerStats(savedGame: inout SavedGame, result: SimulationGameResult) {
        for (playerId, gameStats) in result.playerStats {
            // Find the player in the league
            for teamIndex in savedGame.league.teams.indices {
                if let playerIndex = savedGame.league.teams[teamIndex].roster.firstIndex(where: { $0.id == playerId }) {
                    
                    // Update season stats
                    savedGame.league.teams[teamIndex].roster[playerIndex].seasonStats.addGameStats(
                        goals: gameStats.goals,
                        assists: gameStats.assists,
                        plusMinus: gameStats.plusMinus,
                        penaltyMinutes: gameStats.penaltyMinutes,
                        shots: gameStats.shots,
                        hits: gameStats.hits,
                        blocks: gameStats.blocks,
                        faceoffWins: gameStats.faceoffWins,
                        faceoffAttempts: gameStats.faceoffAttempts,
                        timeOnIce: gameStats.timeOnIce,
                        saves: gameStats.saves,
                        goalsAgainst: gameStats.goalsAgainst,
                        shotsAgainst: gameStats.shotsAgainst,
                        win: gameStats.wins > 0,
                        loss: gameStats.losses > 0,
                        overtimeLoss: gameStats.overtimeLosses > 0,
                        shutout: gameStats.shutouts > 0
                    )
                    
                    // Update career stats
                    savedGame.league.teams[teamIndex].roster[playerIndex].careerStats.addGameStats(
                        goals: gameStats.goals,
                        assists: gameStats.assists,
                        plusMinus: gameStats.plusMinus,
                        penaltyMinutes: gameStats.penaltyMinutes,
                        shots: gameStats.shots,
                        hits: gameStats.hits,
                        blocks: gameStats.blocks,
                        faceoffWins: gameStats.faceoffWins,
                        faceoffAttempts: gameStats.faceoffAttempts,
                        timeOnIce: gameStats.timeOnIce,
                        saves: gameStats.saves,
                        goalsAgainst: gameStats.goalsAgainst,
                        shotsAgainst: gameStats.shotsAgainst,
                        win: gameStats.wins > 0,
                        loss: gameStats.losses > 0,
                        overtimeLoss: gameStats.overtimeLosses > 0,
                        shutout: gameStats.shutouts > 0
                    )
                    
                    break
                }
            }
        }
    }
}