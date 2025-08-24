import Foundation

// MARK: - Main Player Model

/// Comprehensive model for a hockey player containing personal details and complete statistics
/// This is the unified player model combining identity, physical attributes, and performance data
struct PlayerModel: Codable {
    
    /// Personal details and identity information
    let personalDetails: PlayerPersonalDetails
    
    /// Complete statistical performance data
    let statistics: PlayerStats
    
    /// Initialize a complete player model
    init(
        personalDetails: PlayerPersonalDetails,
        statistics: PlayerStats = PlayerStats()
    ) {
        self.personalDetails = personalDetails
        self.statistics = statistics
    }
}

// MARK: - PlayerPersonalDetails Structure

/// A comprehensive model for player personal details and identity information.
/// This struct focuses exclusively on personal characteristics, background, and physical attributes.
/// 
/// **Usage:**
/// ```swift
/// let player = PlayerPersonalDetails(
///     firstName: "Connor",
///     lastName: "McDavid", 
///     nationality: "Canadian",
///     birthDate: Date(timeIntervalSince1970: 631152000), // Jan 13, 1997
///     height: 73, // 6'1"
///     weight: 193,
///     handedness: .left,
///     eyeColor: "Brown",
///     hairColor: "Brown",
///     birthplace: "Richmond Hill, Ontario, Canada"
/// )
/// ```
struct PlayerPersonalDetails: Codable {
    
    // MARK: - Core Identity Properties
    
    /// Unique identifier for the player
    let id: UUID
    
    /// Player's first/given name
    let firstName: String
    
    /// Player's last/family name  
    let lastName: String
    
    /// Optional nickname or moniker (e.g., "The Great One", "Sid the Kid")
    let nickname: String?
    
    /// Primary nationality (e.g., "Canadian", "American", "Swedish", "Finnish")
    let nationality: String
    
    /// Secondary nationality for players with dual citizenship
    let dualCitizenship: String?
    
    // MARK: - Enhanced Physical Properties
    
    /// Player's date of birth for accurate age calculations
    let birthDate: Date
    
    /// Height in inches (e.g., 73 inches = 6'1")
    let height: Int
    
    /// Weight in pounds
    let weight: Int
    
    /// Wingspan/reach in inches - particularly important for goalies and defensemen
    let reach: Int?
    
    /// Shooting/catching hand preference
    let handedness: HandednessShoot
    
    // MARK: - Geographic Background
    
    /// Full birthplace including city, province/state, and country
    /// Example: "Toronto, Ontario, Canada" or "Detroit, Michigan, USA"
    let birthplace: String
    
    /// Where the player grew up (may differ from birthplace)
    /// Example: Player born in one city but raised in another
    let hometown: String?
    
    /// Country of origin (typically extracted from nationality)
    let country: String
    
    // MARK: - Essential Computed Properties
    
    /// Current age calculated from birth date
    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
    
    /// Display name - uses nickname if available, otherwise first name
    var displayName: String {
        return nickname ?? firstName
    }
    
    /// Full formal name (first + last)
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    /// Height formatted as feet and inches (e.g., "6'1\"")
    var heightFormatted: String {
        let feet = height / 12
        let inches = height % 12
        return "\(feet)'\(inches)\""
    }
    
    /// True if player is from outside North America
    var isInternational: Bool {
        let northAmericanCountries = ["Canada", "United States", "USA", "Canadian", "American"]
        return !northAmericanCountries.contains(country) && !northAmericanCountries.contains(nationality)
    }
    
    /// Formal display name with nickname in quotes if it exists
    /// Examples: "Connor McDavid" or "Sidney Crosby \"Sid the Kid\""
    var fullDisplayName: String {
        if let nickname = nickname {
            return "\(firstName) \(lastName) \"\(nickname)\""
        }
        return fullName
    }
    
    // MARK: - Initialization
    
    /// Initialize a new player with required personal details
    /// - Parameters:
    ///   - firstName: Player's first name
    ///   - lastName: Player's last name
    ///   - nationality: Primary nationality
    ///   - birthDate: Date of birth
    ///   - height: Height in inches
    ///   - weight: Weight in pounds
    ///   - handedness: Shooting/catching hand preference
    ///   - eyeColor: Eye color
    ///   - hairColor: Hair color
    ///   - birthplace: Full birthplace string
    ///   - nickname: Optional nickname
    ///   - dualCitizenship: Optional secondary nationality
    ///   - reach: Optional wingspan in inches
    ///   - hometown: Optional hometown (if different from birthplace)
    ///   - province: Optional province/state
    ///   - country: Country (defaults to nationality if not specified)
    init(
        firstName: String,
        lastName: String,
        nationality: String,
        birthDate: Date,
        height: Int,
        weight: Int,
        handedness: HandednessShoot,
        eyeColor: String,
        hairColor: String,
        birthplace: String,
        nickname: String? = nil,
        dualCitizenship: String? = nil,
        reach: Int? = nil,
        hometown: String? = nil,
        province: String? = nil,
        country: String? = nil
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.nationality = nationality
        self.dualCitizenship = dualCitizenship
        self.birthDate = birthDate
        self.height = height
        self.weight = weight
        self.reach = reach
        self.handedness = handedness
        self.eyeColor = eyeColor
        self.hairColor = hairColor
        self.birthplace = birthplace
        self.hometown = hometown
        self.province = province
        self.country = country ?? nationality
    }
}

// MARK: - PlayerPersonalDetails Extensions

extension PlayerPersonalDetails {
    
    /// Convenience computed property for BMI calculation
    var bmi: Double {
        let heightInMeters = Double(height) * 0.0254 // Convert inches to meters
        let weightInKg = Double(weight) * 0.453592 // Convert pounds to kg
        return weightInKg / (heightInMeters * heightInMeters)
    }
    
    /// Computed property to determine if player is considered tall for hockey
    var isTallForHockey: Bool {
        return height >= 74 // 6'2" or taller
    }
    
    /// Age category for development purposes
    var ageCategory: String {
        switch age {
        case 0..<18:
            return "Junior"
        case 18..<25:
            return "Young Professional"
        case 25..<30:
            return "Prime"
        case 30..<35:
            return "Veteran"
        default:
            return "Elder Statesman"
        }
    }
    
    /// Years until or since typical peak age (27 for skaters)
    var yearsToPeak: Int {
        return 27 - age
    }
}

// MARK: - PlayerStats Container

/// Comprehensive statistics container for a hockey player
/// Contains current season stats, career totals, game-by-game logs, and streak tracking
struct PlayerStats: Codable {
    
    /// Current season performance statistics
    let seasonStats: SeasonStats
    
    /// Career and historical statistics totals
    let careerStats: CareerStats
    
    /// Individual game performance log
    let gameLog: [GameStats]
    
    /// Current and longest streaks for various statistics
    let streaks: StatStreaks
    
    /// Initialize player statistics with default empty values
    init(
        seasonStats: SeasonStats = SeasonStats(),
        careerStats: CareerStats = CareerStats(),
        gameLog: [GameStats] = [],
        streaks: StatStreaks = StatStreaks()
    ) {
        self.seasonStats = seasonStats
        self.careerStats = careerStats
        self.gameLog = gameLog
        self.streaks = streaks
    }
}

// MARK: - SeasonStats Structure

/// Current season performance statistics for a hockey player
/// Tracks all standard and advanced hockey statistics for the current season
struct SeasonStats: Codable {
    
    // MARK: - Basic Statistics
    
    /// Number of games played this season
    let gamesPlayed: Int
    
    /// Goals scored this season
    let goals: Int
    
    /// Assists recorded this season
    let assists: Int
    
    /// Plus/minus rating for the season
    let plusMinus: Int
    
    /// Total penalty minutes accumulated
    let penaltyMinutes: Int
    
    /// Total shots taken on goal
    let shots: Int
    
    /// Total hits delivered
    let hits: Int
    
    /// Total shots blocked
    let blocks: Int
    
    /// Successful takeaways from opponents
    let takeaways: Int
    
    /// Turnovers/giveaways committed
    let giveaways: Int
    
    // MARK: - Faceoff Statistics
    
    /// Faceoffs won
    let faceoffWins: Int
    
    /// Total faceoff attempts
    let faceoffAttempts: Int
    
    // MARK: - Time Statistics
    
    /// Total time on ice in seconds
    let timeOnIceSeconds: Int
    
    // MARK: - Special Teams Statistics
    
    /// Goals scored on power play
    let powerPlayGoals: Int
    
    /// Assists recorded on power play
    let powerPlayAssists: Int
    
    /// Goals scored while short-handed
    let shortHandedGoals: Int
    
    /// Goals scored in overtime
    let overtimeGoals: Int
    
    /// Goals scored in shootout
    let shootoutGoals: Int
    
    // MARK: - Computed Properties
    
    /// Total points (goals + assists)
    var points: Int {
        return goals + assists
    }
    
    /// Faceoff win percentage
    var faceoffPercentage: Double {
        guard faceoffAttempts > 0 else { return 0.0 }
        return Double(faceoffWins) / Double(faceoffAttempts) * 100.0
    }
    
    /// Time on ice formatted as MM:SS
    var timeOnIceFormatted: String {
        let minutes = timeOnIceSeconds / 60
        let seconds = timeOnIceSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Average time on ice per game formatted as MM:SS
    var averageTimeOnIce: String {
        guard gamesPlayed > 0 else { return "0:00" }
        let avgSeconds = timeOnIceSeconds / gamesPlayed
        let minutes = avgSeconds / 60
        let seconds = avgSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Shooting percentage (goals/shots * 100)
    var shootingPercentage: Double {
        guard shots > 0 else { return 0.0 }
        return Double(goals) / Double(shots) * 100.0
    }
    
    /// Points per game average
    var pointsPerGame: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return Double(points) / Double(gamesPlayed)
    }
    
    /// Power play points (PP goals + PP assists)
    var powerPlayPoints: Int {
        return powerPlayGoals + powerPlayAssists
    }
    
    // MARK: - Initialization
    
    /// Initialize season stats with default zero values
    init(
        gamesPlayed: Int = 0,
        goals: Int = 0,
        assists: Int = 0,
        plusMinus: Int = 0,
        penaltyMinutes: Int = 0,
        shots: Int = 0,
        hits: Int = 0,
        blocks: Int = 0,
        takeaways: Int = 0,
        giveaways: Int = 0,
        faceoffWins: Int = 0,
        faceoffAttempts: Int = 0,
        timeOnIceSeconds: Int = 0,
        powerPlayGoals: Int = 0,
        powerPlayAssists: Int = 0,
        shortHandedGoals: Int = 0,
        overtimeGoals: Int = 0,
        shootoutGoals: Int = 0
    ) {
        self.gamesPlayed = gamesPlayed
        self.goals = goals
        self.assists = assists
        self.plusMinus = plusMinus
        self.penaltyMinutes = penaltyMinutes
        self.shots = shots
        self.hits = hits
        self.blocks = blocks
        self.takeaways = takeaways
        self.giveaways = giveaways
        self.faceoffWins = faceoffWins
        self.faceoffAttempts = faceoffAttempts
        self.timeOnIceSeconds = timeOnIceSeconds
        self.powerPlayGoals = powerPlayGoals
        self.powerPlayAssists = powerPlayAssists
        self.shortHandedGoals = shortHandedGoals
        self.overtimeGoals = overtimeGoals
        self.shootoutGoals = shootoutGoals
    }
}

// MARK: - CareerStats Structure

/// Career and historical statistics totals
/// Tracks lifetime performance and previous season comparisons
struct CareerStats: Codable {
    
    /// Total career games played
    let careerGamesPlayed: Int
    
    /// Total career goals
    let careerGoals: Int
    
    /// Total career assists
    let careerAssists: Int
    
    /// Total career penalty minutes
    let careerPenaltyMinutes: Int
    
    /// Career plus/minus rating
    let careerPlusMinus: Int
    
    /// Previous season games played
    let previousSeasonGamesPlayed: Int
    
    /// Previous season goals
    let previousSeasonGoals: Int
    
    /// Previous season assists
    let previousSeasonAssists: Int
    
    /// Previous season plus/minus
    let previousSeasonPlusMinus: Int
    
    /// Number of NHL seasons played
    let seasonsPlayed: Int
    
    // MARK: - Computed Properties
    
    /// Total career points
    var careerPoints: Int {
        return careerGoals + careerAssists
    }
    
    /// Previous season points
    var previousSeasonPoints: Int {
        return previousSeasonGoals + previousSeasonAssists
    }
    
    /// Career points per game average
    var careerPointsPerGame: Double {
        guard careerGamesPlayed > 0 else { return 0.0 }
        return Double(careerPoints) / Double(careerGamesPlayed)
    }
    
    // MARK: - Initialization
    
    /// Initialize career stats with default zero values
    init(
        careerGamesPlayed: Int = 0,
        careerGoals: Int = 0,
        careerAssists: Int = 0,
        careerPenaltyMinutes: Int = 0,
        careerPlusMinus: Int = 0,
        previousSeasonGamesPlayed: Int = 0,
        previousSeasonGoals: Int = 0,
        previousSeasonAssists: Int = 0,
        previousSeasonPlusMinus: Int = 0,
        seasonsPlayed: Int = 0
    ) {
        self.careerGamesPlayed = careerGamesPlayed
        self.careerGoals = careerGoals
        self.careerAssists = careerAssists
        self.careerPenaltyMinutes = careerPenaltyMinutes
        self.careerPlusMinus = careerPlusMinus
        self.previousSeasonGamesPlayed = previousSeasonGamesPlayed
        self.previousSeasonGoals = previousSeasonGoals
        self.previousSeasonAssists = previousSeasonAssists
        self.previousSeasonPlusMinus = previousSeasonPlusMinus
        self.seasonsPlayed = seasonsPlayed
    }
}

// MARK: - GameStats Structure

/// Individual game performance statistics
/// Tracks detailed performance for a single game
struct GameStats: Codable, Identifiable {
    
    /// Unique identifier for this game stat entry
    let id = UUID()
    
    /// Unique identifier for the game
    let gameId: UUID
    
    /// Date the game was played
    let date: Date
    
    /// Opponent team identifier or name
    let opponent: String
    
    /// Goals scored in this game
    let goals: Int
    
    /// Assists recorded in this game
    let assists: Int
    
    /// Plus/minus rating for this game
    let plusMinus: Int
    
    /// Shots taken in this game
    let shots: Int
    
    /// Hits delivered in this game
    let hits: Int
    
    /// Shots blocked in this game
    let blocks: Int
    
    /// Penalty minutes accumulated in this game
    let penaltyMinutes: Int
    
    /// Time on ice in seconds for this game
    let timeOnIceSeconds: Int
    
    /// Power play time in seconds
    let powerPlayTime: Int
    
    /// Short-handed time in seconds
    let shortHandedTime: Int
    
    // MARK: - Computed Properties
    
    /// Total points for this game
    var points: Int {
        return goals + assists
    }
    
    /// Time on ice formatted as MM:SS
    var timeOnIceFormatted: String {
        let minutes = timeOnIceSeconds / 60
        let seconds = timeOnIceSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Power play time formatted as MM:SS
    var powerPlayTimeFormatted: String {
        let minutes = powerPlayTime / 60
        let seconds = powerPlayTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Initialization
    
    /// Initialize game stats
    init(
        gameId: UUID,
        date: Date,
        opponent: String,
        goals: Int = 0,
        assists: Int = 0,
        plusMinus: Int = 0,
        shots: Int = 0,
        hits: Int = 0,
        blocks: Int = 0,
        penaltyMinutes: Int = 0,
        timeOnIceSeconds: Int = 0,
        powerPlayTime: Int = 0,
        shortHandedTime: Int = 0
    ) {
        self.gameId = gameId
        self.date = date
        self.opponent = opponent
        self.goals = goals
        self.assists = assists
        self.plusMinus = plusMinus
        self.shots = shots
        self.hits = hits
        self.blocks = blocks
        self.penaltyMinutes = penaltyMinutes
        self.timeOnIceSeconds = timeOnIceSeconds
        self.powerPlayTime = powerPlayTime
        self.shortHandedTime = shortHandedTime
    }
}

// MARK: - StatStreaks Structure

/// Current and record streak tracking for various statistics
/// Monitors consecutive games with goals, assists, points, etc.
struct StatStreaks: Codable {
    
    // MARK: - Current Streaks
    
    /// Current consecutive games with a goal
    let currentGoalStreak: Int
    
    /// Current consecutive games with an assist
    let currentAssistStreak: Int
    
    /// Current consecutive games with a point (goal or assist)
    let currentPointStreak: Int
    
    /// Current consecutive games played
    let currentGameStreak: Int
    
    // MARK: - Season/Career Records
    
    /// Longest goal streak this season/career
    let longestGoalStreak: Int
    
    /// Longest assist streak this season/career
    let longestAssistStreak: Int
    
    /// Longest point streak this season/career
    let longestPointStreak: Int
    
    // MARK: - Additional Streak Types
    
    /// Current multi-point game streak
    let currentMultiPointStreak: Int
    
    /// Current games without a penalty
    let currentCleanGameStreak: Int
    
    /// Current positive plus/minus streak
    let currentPlusStreak: Int
    
    // MARK: - Computed Properties
    
    /// Whether player is currently on a hot streak (5+ point games)
    var isOnHotStreak: Bool {
        return currentPointStreak >= 5
    }
    
    /// Whether player is having a career-best point streak
    var isCareerBestPointStreak: Bool {
        return currentPointStreak >= longestPointStreak
    }
    
    // MARK: - Initialization
    
    /// Initialize streak tracking with default zero values
    /// TODO: Add validation logic to ensure current streaks don't exceed longest streaks
    init(
        currentGoalStreak: Int = 0,
        currentAssistStreak: Int = 0,
        currentPointStreak: Int = 0,
        currentGameStreak: Int = 0,
        longestGoalStreak: Int = 0,
        longestAssistStreak: Int = 0,
        longestPointStreak: Int = 0,
        currentMultiPointStreak: Int = 0,
        currentCleanGameStreak: Int = 0,
        currentPlusStreak: Int = 0
    ) {
        self.currentGoalStreak = currentGoalStreak
        self.currentAssistStreak = currentAssistStreak
        self.currentPointStreak = currentPointStreak
        self.currentGameStreak = currentGameStreak
        self.longestGoalStreak = longestGoalStreak
        self.longestAssistStreak = longestAssistStreak
        self.longestPointStreak = longestPointStreak
        self.currentMultiPointStreak = currentMultiPointStreak
        self.currentCleanGameStreak = currentCleanGameStreak
        self.currentPlusStreak = currentPlusStreak
        
        // TODO: Add validation that current streaks are valid
        // TODO: Add streak update methods for when games are processed
        // TODO: Add streak comparison methods (is this a new record?)
        // TODO: Add streak history tracking for advanced analytics
    }
}

// MARK: - HandednessShoot Extension
// Note: This references the existing enum from the main codebase
// In a standalone implementation, this would be defined here as well
extension HandednessShoot {
    /// Display name for handedness
    var displayName: String {
        switch self {
        case .left:
            return "Left"
        case .right:
            return "Right"
        }
    }
}

// MARK: - Statistical Extensions and Utilities

extension SeasonStats {
    
    /// Determine if this is a breakout season statistically
    /// TODO: Implement comparison logic with previous seasons and league averages
    var isBreakoutSeason: Bool {
        // TODO: Compare with career averages and league benchmarks
        return false
    }
    
    /// Statistical efficiency rating
    /// TODO: Implement advanced analytics calculation
    var playerEfficiencyRating: Double {
        // TODO: Calculate advanced efficiency metric
        return 0.0
    }
}

extension CareerStats {
    
    /// Determine career trajectory (improving/declining/steady)
    /// TODO: Implement trend analysis based on recent seasons
    var careerTrajectory: String {
        // TODO: Analyze recent performance trends
        return "Unknown"
    }
    
    /// Years until potential milestone achievements
    /// TODO: Calculate projected milestones (100 goals, 500 points, etc.)
    var milestonesWithinReach: [String] {
        // TODO: Calculate approaching milestones
        return []
    }
}

extension GameStats {
    
    /// Determine if this was a standout performance
    /// TODO: Compare against player averages and league performance
    var wasStandoutPerformance: Bool {
        // TODO: Implement performance evaluation logic
        return false
    }
    
    /// Game rating based on overall contribution
    /// TODO: Implement comprehensive game rating system
    var gameRating: Double {
        // TODO: Calculate game performance rating
        return 0.0
    }
}

// MARK: - Player Attributes System

/// Technical attributes representing a player's hockey-specific skills
/// Values typically range from 0-100 with higher values indicating better ability
struct TechnicalAttributes: Codable {
    
    /// Ability to handle the puck smoothly while skating
    let stickhandling: Int
    
    /// Skill in executing advanced dekes and fakes
    let dangles: Int
    
    /// Ability to maintain possession of the puck under pressure
    let puckProtection: Int
    
    /// Precision in making passes to teammates
    let passingAccuracy: Int
    
    /// Ability to deliver hard, fast passes
    let passingPower: Int
    
    /// Skill in executing elevated "saucer" passes
    let saucerPass: Int
    
    /// Precision when shooting the puck at the target
    let shootingAccuracy: Int
    
    /// Ability to shoot with velocity and force
    let shootingPower: Int
    
    /// Speed of shot release and quick shots
    let release: Int
    
    /// Skill in deflecting shots and redirecting the puck
    let deflections: Int
    
    /// Proficiency in taking faceoffs
    let faceoffs: Int
    
    /// Ability to effectively screen the goaltender
    let screening: Int
    
    /// Skill in using stick to disrupt opponent plays
    let stickChecking: Int
    
    /// Ability to position body to block shots
    let shotBlocking: Int
    
    /// Proficiency in poke-checking to steal the puck
    let pokeChecking: Int
    
    /// Effectiveness in delivering body checks
    let bodyChecking: Int
    
    /// Initialize technical attributes with default zero values
    init(
        stickhandling: Int = 0,
        dangles: Int = 0,
        puckProtection: Int = 0,
        passingAccuracy: Int = 0,
        passingPower: Int = 0,
        saucerPass: Int = 0,
        shootingAccuracy: Int = 0,
        shootingPower: Int = 0,
        release: Int = 0,
        deflections: Int = 0,
        faceoffs: Int = 0,
        screening: Int = 0,
        stickChecking: Int = 0,
        shotBlocking: Int = 0,
        pokeChecking: Int = 0,
        bodyChecking: Int = 0
    ) {
        self.stickhandling = stickhandling
        self.dangles = dangles
        self.puckProtection = puckProtection
        self.passingAccuracy = passingAccuracy
        self.passingPower = passingPower
        self.saucerPass = saucerPass
        self.shootingAccuracy = shootingAccuracy
        self.shootingPower = shootingPower
        self.release = release
        self.deflections = deflections
        self.faceoffs = faceoffs
        self.screening = screening
        self.stickChecking = stickChecking
        self.shotBlocking = shotBlocking
        self.pokeChecking = pokeChecking
        self.bodyChecking = bodyChecking
    }
}

/// Mental attributes representing a player's hockey intelligence and psychological traits
/// Values typically range from 0-100 with higher values indicating better mental ability
struct MentalAttributes: Codable {
    
    /// Understanding of offensive systems and positioning
    let offensiveIQ: Int
    
    /// Understanding of defensive systems and positioning
    let defensiveIQ: Int
    
    /// Ability to make quick, correct decisions under pressure
    let decisionMaking: Int
    
    /// Ability to create unexpected and innovative plays
    let creativity: Int
    
    /// Ability to see the ice and anticipate play development
    let vision: Int
    
    /// Sense of when to make plays and execute actions
    let timing: Int
    
    /// Understanding of positioning when not controlling the puck
    let offThePuck: Int
    
    /// Ability to predict what will happen next in the game
    let anticipation: Int
    
    /// Understanding of positioning relative to teammates and opponents
    let spatialAwareness: Int
    
    /// Coordination between visual input and physical response
    let handEyeCoordination: Int
    
    /// Ability to maintain concentration throughout the game
    let focus: Int
    
    /// Performance enhancement in high-pressure situations
    let clutch: Int
    
    /// Ability to remain calm under pressure
    let composure: Int
    
    /// Willingness to engage physically and compete
    let aggression: Int
    
    /// Internal motivation and competitive desire
    let drive: Int
    
    /// Consistent effort level throughout games and practice
    let workRate: Int
    
    /// Initialize mental attributes with default zero values
    init(
        offensiveIQ: Int = 0,
        defensiveIQ: Int = 0,
        decisionMaking: Int = 0,
        creativity: Int = 0,
        vision: Int = 0,
        timing: Int = 0,
        offThePuck: Int = 0,
        anticipation: Int = 0,
        spatialAwareness: Int = 0,
        handEyeCoordination: Int = 0,
        focus: Int = 0,
        clutch: Int = 0,
        composure: Int = 0,
        aggression: Int = 0,
        drive: Int = 0,
        workRate: Int = 0
    ) {
        self.offensiveIQ = offensiveIQ
        self.defensiveIQ = defensiveIQ
        self.decisionMaking = decisionMaking
        self.creativity = creativity
        self.vision = vision
        self.timing = timing
        self.offThePuck = offThePuck
        self.anticipation = anticipation
        self.spatialAwareness = spatialAwareness
        self.handEyeCoordination = handEyeCoordination
        self.focus = focus
        self.clutch = clutch
        self.composure = composure
        self.aggression = aggression
        self.drive = drive
        self.workRate = workRate
    }
}

/// Physical attributes representing a player's athletic capabilities
/// Values typically range from 0-100 with higher values indicating better physical ability
struct PhysicalAttributes: Codable {
    
    /// Top skating speed capability
    let speed: Int
    
    /// Ability to quickly reach top speed
    let acceleration: Int
    
    /// Ability to change direction quickly and smoothly
    let agility: Int
    
    /// Ability to maintain stability while skating
    let balance: Int
    
    /// Overall physical power and muscle strength
    let strength: Int
    
    /// Endurance and ability to maintain performance throughout game
    let stamina: Int
    
    /// Resistance to injury and ability to withstand physical play
    let durability: Int
    
    /// Overall physical size and frame
    let size: Int
    
    /// Wingspan and ability to cover space with stick and body
    let reach: Int
    
    /// Initialize physical attributes with default zero values
    init(
        speed: Int = 0,
        acceleration: Int = 0,
        agility: Int = 0,
        balance: Int = 0,
        strength: Int = 0,
        stamina: Int = 0,
        durability: Int = 0,
        size: Int = 0,
        reach: Int = 0
    ) {
        self.speed = speed
        self.acceleration = acceleration
        self.agility = agility
        self.balance = balance
        self.strength = strength
        self.stamina = stamina
        self.durability = durability
        self.size = size
        self.reach = reach
    }
}
