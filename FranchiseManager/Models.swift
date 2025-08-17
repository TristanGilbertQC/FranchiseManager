import Foundation

enum Position: String, CaseIterable, Codable {
    case center = "C"
    case leftWing = "LW"
    case rightWing = "RW"
    case leftDefense = "LD"
    case rightDefense = "RD"
    case goalie = "G"
    
    var displayName: String {
        switch self {
        case .center: return "Center"
        case .leftWing: return "Left Wing"
        case .rightWing: return "Right Wing"
        case .leftDefense: return "Left Defense"
        case .rightDefense: return "Right Defense"
        case .goalie: return "Goalie"
        }
    }
}

enum HandednessShoot: String, CaseIterable, Codable {
    case left = "L"
    case right = "R"
}

struct PlayerStats: Codable {
    var gamesPlayed: Int
    var goals: Int
    var assists: Int
    var points: Int { return goals + assists }
    var plusMinus: Int
    var penaltyMinutes: Int
    var shots: Int
    var hits: Int
    var blocks: Int
    var faceoffWins: Int
    var faceoffAttempts: Int
    var timeOnIce: Int // in seconds
    
    // Goalie-specific stats
    var saves: Int
    var goalsAgainst: Int
    var shotsAgainst: Int
    var wins: Int
    var losses: Int
    var overtimeLosses: Int
    var shutouts: Int
    
    init() {
        self.gamesPlayed = 0
        self.goals = 0
        self.assists = 0
        self.plusMinus = 0
        self.penaltyMinutes = 0
        self.shots = 0
        self.hits = 0
        self.blocks = 0
        self.faceoffWins = 0
        self.faceoffAttempts = 0
        self.timeOnIce = 0
        self.saves = 0
        self.goalsAgainst = 0
        self.shotsAgainst = 0
        self.wins = 0
        self.losses = 0
        self.overtimeLosses = 0
        self.shutouts = 0
    }
    
    // Computed properties
    var faceoffPercentage: Double {
        return faceoffAttempts > 0 ? Double(faceoffWins) / Double(faceoffAttempts) : 0.0
    }
    
    var savePercentage: Double {
        return shotsAgainst > 0 ? Double(saves) / Double(shotsAgainst) : 0.0
    }
    
    var goalsAgainstAverage: Double {
        return timeOnIce > 0 ? Double(goalsAgainst) * 3600.0 / Double(timeOnIce) : 0.0
    }
    
    var averageTimeOnIce: Double {
        return gamesPlayed > 0 ? Double(timeOnIce) / Double(gamesPlayed) : 0.0
    }
    
    mutating func addGameStats(goals: Int = 0, assists: Int = 0, plusMinus: Int = 0, 
                              penaltyMinutes: Int = 0, shots: Int = 0, hits: Int = 0, 
                              blocks: Int = 0, faceoffWins: Int = 0, faceoffAttempts: Int = 0,
                              timeOnIce: Int = 0, saves: Int = 0, goalsAgainst: Int = 0,
                              shotsAgainst: Int = 0, win: Bool = false, loss: Bool = false,
                              overtimeLoss: Bool = false, shutout: Bool = false) {
        self.gamesPlayed += 1
        self.goals += goals
        self.assists += assists
        self.plusMinus += plusMinus
        self.penaltyMinutes += penaltyMinutes
        self.shots += shots
        self.hits += hits
        self.blocks += blocks
        self.faceoffWins += faceoffWins
        self.faceoffAttempts += faceoffAttempts
        self.timeOnIce += timeOnIce
        
        // Goalie stats
        self.saves += saves
        self.goalsAgainst += goalsAgainst
        self.shotsAgainst += shotsAgainst
        if win { self.wins += 1 }
        if loss { self.losses += 1 }
        if overtimeLoss { self.overtimeLosses += 1 }
        if shutout { self.shutouts += 1 }
    }
}

struct SkaterAttributes: Codable {
    var passingAccuracy: Int = 50
    var passingVision: Int = 50
    var passingCreativity: Int = 50
    var passingUnderPressure: Int = 50
    
    var shootingAccuracy: Int = 50
    var shootingPower: Int = 50
    var quickRelease: Int = 50
    var oneTimer: Int = 50
    var reboundControl: Int = 50
    
    var positioning: Int = 50
    var anticipation: Int = 50
    var decisionMaking: Int = 50
    var gameAwareness: Int = 50
    var adaptability: Int = 50
    
    var stickChecking: Int = 50
    var gapControl: Int = 50
    var shotBlocking: Int = 50
    var defensivePositioning: Int = 50
    
    var bodyChecking: Int = 50
    var pokeChecking: Int = 50
    var forechecking: Int = 50
    var backchecking: Int = 50
    var intimidation: Int = 50
    
    var speed: Int = 50
    var acceleration: Int = 50
    var agility: Int = 50
    var balance: Int = 50
    var stamina: Int = 50
    var strength: Int = 50
    
    var clutch: Int = 50
    var composure: Int = 50
    var focus: Int = 50
    var resilience: Int = 50
    var competitiveDrive: Int = 50
    var coachability: Int = 50
    var workEthic: Int = 50
    var learningRate: Int = 50
    var peakAge: Int = 27
    var declineRate: Int = 50
    var injuryRecovery: Int = 50
    var leadership: Int = 50
    var discipline: Int = 50
    var ego: Int = 50
    var mediaHandling: Int = 50
    var loyalty: Int = 50
    var consistency: Int = 50
    var injuryProne: Int = 50
    var dirtyPlayer: Int = 50
    
    var overall: Int {
        let physicalSkills = (speed + acceleration + agility + balance + stamina + strength) / 6
        let offensiveSkills = (passingAccuracy + passingVision + shootingAccuracy + shootingPower + quickRelease) / 5
        let defensiveSkills = (stickChecking + gapControl + shotBlocking + defensivePositioning + bodyChecking) / 5
        let mentalSkills = (positioning + anticipation + decisionMaking + gameAwareness + clutch + composure) / 6
        
        return (physicalSkills + offensiveSkills + defensiveSkills + mentalSkills) / 4
    }
    
    func positionSpecificOverall(for position: Position) -> Int {
        switch position {
        case .center:
            // Centers: Weight passing vision and decision making higher
            let passing = (passingAccuracy + passingVision * 2 + passingCreativity) / 4
            let vision = (decisionMaking * 2 + gameAwareness + positioning) / 4
            let offensive = (shootingAccuracy + quickRelease + oneTimer) / 3
            let physical = (speed + acceleration + agility + balance) / 4
            let mental = (clutch + composure + focus) / 3
            return (passing * 3 + vision * 3 + offensive * 2 + physical * 2 + mental) / 11
            
        case .leftWing, .rightWing:
            // Wingers: Weight shooting accuracy and speed higher
            let shooting = (shootingAccuracy * 2 + shootingPower + quickRelease + oneTimer) / 5
            let speed_skills = (speed * 2 + acceleration + agility) / 4
            let passing = (passingAccuracy + passingVision) / 2
            let physical = (strength + balance + stamina) / 3
            let mental = (positioning + anticipation + clutch) / 3
            return (shooting * 3 + speed_skills * 3 + passing * 2 + physical * 2 + mental) / 11
            
        case .leftDefense, .rightDefense:
            // Defense: Weight defensive positioning and stick checking higher
            let defense = (defensivePositioning * 2 + stickChecking * 2 + gapControl + shotBlocking) / 6
            let physical = (strength + balance + strength) / 3
            let passing = (passingAccuracy + passingVision + passingUnderPressure) / 3
            let checking = (bodyChecking + pokeChecking + backchecking) / 3
            let mental = (positioning + anticipation + decisionMaking) / 3
            return (defense * 4 + physical * 2 + passing * 2 + checking * 2 + mental) / 11
            
        case .goalie:
            // Goalies use separate attributes
            return overall
        }
    }
    
    static let maxAttribute = 99
    static let minAttribute = 1
}

struct GoalieAttributes: Codable {
    var anglePlay: Int = 50
    var depthManagement: Int = 50
    var netCoverage: Int = 50
    var postPlay: Int = 50
    var screenManagement: Int = 50
    
    var gloveHand: Int = 50
    var blocker: Int = 50
    var padSaves: Int = 50
    var reactionTime: Int = 50
    var secondSaves: Int = 50
    
    var reboundDirection: Int = 50
    var absorption: Int = 50
    var recoverySpeed: Int = 50
    var scrambleAbility: Int = 50
    var freezeTiming: Int = 50
    
    var lateralMovement: Int = 50
    var postToPost: Int = 50
    var butterflyTechnique: Int = 50
    var recovery: Int = 50
    var flexibility: Int = 50
    
    var puckPlaying: Int = 50
    var passingAccuracy: Int = 50
    var decisionMaking: Int = 50
    var behindNet: Int = 50
    var breakoutAssistance: Int = 50
    
    var focus: Int = 50
    var tracking: Int = 50
    var anticipation: Int = 50
    
    var clutch: Int = 50
    var composure: Int = 50
    var resilience: Int = 50
    var competitiveDrive: Int = 50
    var coachability: Int = 50
    var workEthic: Int = 50
    var learningRate: Int = 50
    var peakAge: Int = 30
    var declineRate: Int = 50
    var injuryRecovery: Int = 50
    var leadership: Int = 50
    var discipline: Int = 50
    var ego: Int = 50
    var mediaHandling: Int = 50
    var loyalty: Int = 50
    var adaptability: Int = 50
    var consistency: Int = 50
    var injuryProne: Int = 50
    var dirtyPlayer: Int = 50
    
    var overall: Int {
        let positioning = (anglePlay + depthManagement + netCoverage + postPlay + screenManagement) / 5
        let reflexes = (gloveHand + blocker + padSaves + reactionTime + secondSaves) / 5
        let rebounds = (reboundDirection + absorption + recoverySpeed + scrambleAbility + freezeTiming) / 5
        let movement = (lateralMovement + postToPost + butterflyTechnique + recovery + flexibility) / 5
        let puckHandling = (puckPlaying + passingAccuracy + decisionMaking + behindNet + breakoutAssistance) / 5
        let mental = (focus + tracking + anticipation + clutch + composure) / 5
        
        return (positioning + reflexes + rebounds + movement + puckHandling + mental) / 6
    }
    
    static let maxAttribute = 99
    static let minAttribute = 1
}

enum ContractType: String, CaseIterable, Codable {
    case standard = "STD"
    case entryLevel = "ELC"
    case twoWay = "2-WAY"
    case oneYear = "1YR"
    case `extension` = "EXT"
}

struct Contract: Codable {
    var salary: Int
    var yearsRemaining: Int
    var contractType: ContractType
    var noTradeClause: Bool
    var noMovementClause: Bool
    
    init(salary: Int, yearsRemaining: Int, contractType: ContractType = .standard, noTradeClause: Bool = false, noMovementClause: Bool = false) {
        self.salary = salary
        self.yearsRemaining = yearsRemaining
        self.contractType = contractType
        self.noTradeClause = noTradeClause
        self.noMovementClause = noMovementClause
    }
    
    var isExpired: Bool {
        return yearsRemaining <= 0
    }
    
    var hasClause: Bool {
        return noTradeClause || noMovementClause
    }
}

enum InjuryStatus: Codable {
    case healthy
    case injured(daysRemaining: Int, description: String)
    
    var isInjured: Bool {
        switch self {
        case .healthy: return false
        case .injured: return true
        }
    }
    
    var daysRemaining: Int {
        switch self {
        case .healthy: return 0
        case .injured(let days, _): return days
        }
    }
}

struct Player: Codable, Identifiable {
    var id: UUID
    var firstName: String
    var lastName: String
    var fullName: String { return "\(firstName) \(lastName)" }
    var jerseyNumber: Int
    var position: Position
    var age: Int
    var height: Int
    var weight: Int
    var handedness: HandednessShoot
    var birthplace: String
    var teamId: UUID?
    
    var skaterAttributes: SkaterAttributes?
    var goalieAttributes: GoalieAttributes?
    var seasonStats: PlayerStats
    var careerStats: PlayerStats
    var contract: Contract?
    var injuryStatus: InjuryStatus
    var waiversEligible: Bool
    var role: String
    
    var overall: Int {
        if position == .goalie {
            return goalieAttributes?.overall ?? 50
        } else {
            return skaterAttributes?.positionSpecificOverall(for: position) ?? 50
        }
    }
    
    var stats: PlayerStats {
        return seasonStats
    }
    
    var isRookie: Bool {
        return stats.gamesPlayed < 10
    }
    
    var marketValue: Int {
        let baseValue = overall * 100000
        let ageMultiplier: Double
        
        switch age {
        case 18...22: ageMultiplier = 1.2
        case 23...28: ageMultiplier = 1.0
        case 29...32: ageMultiplier = 0.8
        case 33...36: ageMultiplier = 0.6
        default: ageMultiplier = 0.4
        }
        
        return Int(Double(baseValue) * ageMultiplier)
    }
    
    init(firstName: String, lastName: String, jerseyNumber: Int, position: Position, age: Int, height: Int, weight: Int, handedness: HandednessShoot, birthplace: String, teamId: UUID? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.jerseyNumber = jerseyNumber
        self.position = position
        self.age = age
        self.height = height
        self.weight = weight
        self.handedness = handedness
        self.birthplace = birthplace
        self.teamId = teamId
        self.seasonStats = PlayerStats()
        self.careerStats = PlayerStats()
        self.injuryStatus = .healthy
        self.waiversEligible = false
        self.role = "Regular"
        
        if position == .goalie {
            self.goalieAttributes = GoalieAttributes()
            self.skaterAttributes = nil
        } else {
            self.skaterAttributes = SkaterAttributes()
            self.goalieAttributes = nil
        }
    }
    
    mutating func advanceDay() {
        if case .injured(let days, let description) = injuryStatus {
            if days <= 1 {
                injuryStatus = .healthy
            } else {
                injuryStatus = .injured(daysRemaining: days - 1, description: description)
            }
        }
    }
}

struct TeamRecord: Codable {
    var wins: Int
    var losses: Int
    var overtimeLosses: Int
    
    init() {
        self.wins = 0
        self.losses = 0
        self.overtimeLosses = 0
    }
    
    var points: Int {
        return (wins * 2) + overtimeLosses
    }
    
    var gamesPlayed: Int {
        return wins + losses + overtimeLosses
    }
    
    var winPercentage: Double {
        return gamesPlayed > 0 ? Double(wins) / Double(gamesPlayed) : 0.0
    }
}

struct Line: Codable, Identifiable {
    let id: UUID
    var name: String
    var leftWingId: UUID?
    var centerId: UUID?
    var rightWingId: UUID?
    var leftDefenseId: UUID?
    var rightDefenseId: UUID?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
    var isComplete: Bool {
        return leftWingId != nil && centerId != nil && rightWingId != nil
    }
    
    var isDefensePairComplete: Bool {
        return leftDefenseId != nil && rightDefenseId != nil
    }
}

struct TeamLines: Codable {
    var forwardLines: [Line] = []
    var defensePairs: [Line] = []
    var startingGoalieId: UUID?
    var backupGoalieId: UUID?
    
    init() {
        forwardLines = [
            Line(name: "Line 1"),
            Line(name: "Line 2"),
            Line(name: "Line 3"),
            Line(name: "Line 4")
        ]
        defensePairs = [
            Line(name: "Defense 1"),
            Line(name: "Defense 2"),
            Line(name: "Defense 3")
        ]
    }
}

struct Team: Codable, Identifiable {
    var id: UUID
    var name: String
    var city: String
    var fullName: String { return "\(city) \(name)" }
    var abbreviation: String
    var primaryColor: String
    var secondaryColor: String
    
    var roster: [Player]
    var lines: TeamLines
    var record: TeamRecord
    var salary: Int
    var salaryCap: Int
    
    var capSpace: Int {
        return salaryCap - salary
    }
    
    var rosterCount: Int {
        return roster.count
    }
    
    init(name: String, city: String, abbreviation: String, primaryColor: String, secondaryColor: String) {
        self.id = UUID()
        self.name = name
        self.city = city
        self.abbreviation = abbreviation
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.roster = []
        self.lines = TeamLines()
        self.record = TeamRecord()
        self.salary = 0
        self.salaryCap = 80000000
    }
    
    func players(at position: Position) -> [Player] {
        return roster.filter { $0.position == position }
    }
    
    mutating func addPlayer(_ player: Player) {
        roster.append(player)
        if let contract = player.contract {
            salary += contract.salary
        }
    }
    
    mutating func removePlayer(_ player: Player) {
        roster.removeAll { $0.id == player.id }
        if let contract = player.contract {
            salary -= contract.salary
        }
    }
}

struct League: Codable, Identifiable {
    var id: UUID
    var name: String
    var teams: [Team] = []
    var currentSeason: Int
    var gamesPerSeason: Int = 82
    
    var standings: [Team] {
        return teams.sorted { $0.record.points > $1.record.points }
    }
    
    init(name: String, teams: [Team], currentSeason: Int) {
        self.id = UUID()
        self.name = name
        self.teams = teams
        self.currentSeason = currentSeason
    }
    
    func team(withId id: UUID) -> Team? {
        return teams.first { $0.id == id }
    }
    
    mutating func updateTeam(_ updatedTeam: Team) {
        if let index = teams.firstIndex(where: { $0.id == updatedTeam.id }) {
            teams[index] = updatedTeam
        }
    }
    
    func getStandingsForPhase(_ phase: SeasonPhase) -> [Team] {
        switch phase {
        case .preseason, .offseason:
            return teams.sorted { $0.name < $1.name }
        case .regular, .playoffs:
            return standings
        }
    }
}

struct BasicGameResult: Codable {
    var homeTeamId: UUID
    var awayTeamId: UUID
    var homeScore: Int
    var awayScore: Int
    var overtime: Bool
    var shootout: Bool
    var date: Date
    
    init(homeTeamId: UUID, awayTeamId: UUID, homeScore: Int, awayScore: Int, overtime: Bool = false, shootout: Bool = false, date: Date) {
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.overtime = overtime
        self.shootout = shootout
        self.date = date
    }
}

struct Game: Codable, Identifiable {
    let id: UUID
    var homeTeamId: UUID
    var awayTeamId: UUID
    var date: Date
    var isCompleted: Bool
    var result: BasicGameResult?
    var homeTeamStats: [UUID: PlayerStats]
    var awayTeamStats: [UUID: PlayerStats]
    
    init(homeTeamId: UUID, awayTeamId: UUID, date: Date) {
        self.id = UUID()
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.date = date
        self.isCompleted = false
        self.homeTeamStats = [:]
        self.awayTeamStats = [:]
    }
    
    mutating func completeGame(homeScore: Int, awayScore: Int, overtime: Bool = false, shootout: Bool = false) {
        self.result = BasicGameResult(
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
            homeScore: homeScore,
            awayScore: awayScore,
            overtime: overtime,
            shootout: shootout,
            date: date
        )
        self.isCompleted = true
    }
    
    func winner() -> UUID? {
        guard let result = result else { return nil }
        return result.homeScore > result.awayScore ? result.homeTeamId : result.awayTeamId
    }
    
    func loser() -> UUID? {
        guard let result = result else { return nil }
        return result.homeScore < result.awayScore ? result.homeTeamId : result.awayTeamId
    }
}

struct Season: Codable, Identifiable {
    var id: UUID
    var year: Int
    var games: [Game]
    var isCompleted: Bool
    var playoffs: [Game]
    
    init(year: Int) {
        self.id = UUID()
        self.year = year
        self.games = []
        self.isCompleted = false
        self.playoffs = []
    }
    
    func gamesFor(teamId: UUID) -> [Game] {
        return games.filter { $0.homeTeamId == teamId || $0.awayTeamId == teamId }
    }
    
    func completedGamesFor(teamId: UUID) -> [Game] {
        return gamesFor(teamId: teamId).filter { $0.isCompleted }
    }
    
    func recordFor(teamId: UUID) -> TeamRecord {
        let completedGames = completedGamesFor(teamId: teamId)
        var record = TeamRecord()
        
        for game in completedGames {
            guard let result = game.result else { continue }
            
            let isHome = game.homeTeamId == teamId
            let teamScore = isHome ? result.homeScore : result.awayScore
            let opponentScore = isHome ? result.awayScore : result.homeScore
            
            if teamScore > opponentScore {
                record.wins += 1
            } else if result.overtime || result.shootout {
                record.overtimeLosses += 1
            } else {
                record.losses += 1
            }
        }
        
        return record
    }
}

struct SavedGame: Codable, Identifiable {
    var id: UUID
    var gameName: String
    var playerTeamId: UUID
    var league: League
    var calendar: SeasonCalendar
    var currentSeason: Season
    var seasons: [Season] = []
    var saveDate: Date
    
    var currentDate: Date {
        return calendar.currentDate
    }
    
    var currentPhase: SeasonPhase {
        return calendar.phase
    }
    
    var seasonDisplayString: String {
        return calendar.seasonDisplayString
    }
    
    init(gameName: String, playerTeamId: UUID, league: League, season: Season) {
        self.id = UUID()
        self.gameName = gameName
        self.playerTeamId = playerTeamId
        self.league = league
        self.calendar = SeasonCalendar(startYear: season.year)
        self.currentSeason = season
        self.seasons = [season]
        self.saveDate = Date()
    }
    
    mutating func advanceDate(by days: Int) throws {
        try calendar.advanceDate(by: days)
        
        // Check if we need to advance season
        if calendar.phase == .preseason && calendar.season > currentSeason.year {
            advanceToNextSeason()
        }
    }
    
    mutating func advanceToNextSeason() {
        currentSeason.isCompleted = true
        let nextSeason = Season(year: calendar.season)
        seasons.append(currentSeason)
        currentSeason = nextSeason
    }
    
    func totalGamesPlayed() -> Int {
        return seasons.reduce(0) { total, season in
            total + season.games.filter { $0.isCompleted }.count
        } + currentSeason.games.filter { $0.isCompleted }.count
    }
    
    func playerTeamRecord() -> TeamRecord {
        return currentSeason.recordFor(teamId: playerTeamId)
    }
    
    func getUpcomingEvents(limit: Int = 5) -> [SimulationEvent] {
        return calendar.eventQueue.getUpcomingEvents(limit: limit)
    }
    
    func isTradeDeadline() -> Bool {
        return calendar.isTradeDeadline()
    }
    
    func isAllStarBreak() -> Bool {
        return calendar.isAllStarBreak()
    }
}