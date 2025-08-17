import Foundation

class GameDataGenerator {
    
    // MARK: - Team Data
    private let teamNames = [
        "Wolves", "Eagles", "Sharks", "Lions", "Bears", "Tigers", "Hawks", "Dragons",
        "Thunder", "Lightning", "Storm", "Ice", "Fire", "Steel", "Crusaders", "Warriors",
        "Knights", "Rangers", "Hunters", "Titans", "Phoenix", "Avalanche", "Blizzard", "Cyclones"
    ]
    
    private let cityNames = [
        "Calgary", "Vancouver", "Toronto", "Montreal", "Ottawa", "Edmonton", "Winnipeg", "Quebec City",
        "Halifax", "Victoria", "Regina", "Saskatoon", "London", "Hamilton", "Windsor", "Kingston",
        "Thunder Bay", "Sudbury", "Barrie", "Oshawa", "Kelowna", "Red Deer", "Lethbridge", "Kamloops"
    ]
    
    // MARK: - Player Names
    private let firstNames = [
        "Alex", "Connor", "Dylan", "Ethan", "Jake", "Logan", "Mason", "Nathan", "Owen", "Ryan",
        "Tyler", "Brady", "Carter", "Drew", "Evan", "Hunter", "Jack", "Kyle", "Luke", "Max",
        "Noah", "Sam", "Zach", "Blake", "Chase", "Cole", "Derek", "Finn", "Gage", "Ian",
        "Jaden", "Kale", "Liam", "Matt", "Nick", "Parker", "Quinn", "Reed", "Sean", "Tanner",
        "Victor", "Wade", "Xavier", "Yanni", "Zane", "Austin", "Bryce", "Cody", "Damon", "Ellis"
    ]
    
    private let lastNames = [
        "Anderson", "Brown", "Campbell", "Davis", "Evans", "Fisher", "Green", "Harris", "Johnson", "Kelly",
        "Lewis", "Miller", "Nelson", "O'Brien", "Parker", "Quinn", "Roberts", "Smith", "Taylor", "Wilson",
        "Adams", "Baker", "Clark", "Davies", "Edwards", "Fraser", "Grant", "Hughes", "Irving", "Jackson",
        "King", "Lee", "Moore", "Nash", "Oliver", "Phillips", "Reid", "Stone", "Turner", "Young",
        "Bell", "Cooper", "Duncan", "Ford", "Gray", "Hall", "Jones", "Kane", "Long", "Martin"
    ]
    
    private let cities = [
        "Toronto", "Montreal", "Vancouver", "Calgary", "Edmonton", "Ottawa", "Winnipeg", "Quebec City",
        "Hamilton", "London", "Victoria", "Regina", "Saskatoon", "Halifax", "Thunder Bay", "Sudbury"
    ]
    
    // MARK: - Main Generation Methods
    func createLeague() -> League {
        var league = League(name: "USER LEAGUE", teams: [], currentSeason: 2025)
        
        var usedCombinations: Set<String> = []
        
        for _ in 0..<10 {
            var team: Team
            var combinationKey: String
            
            repeat {
                let city = cityNames.randomElement()!
                let name = teamNames.randomElement()!
                combinationKey = "\(city)-\(name)"
                
                team = Team(
                    name: name,
                    city: city,
                    abbreviation: createAbbreviation(city: city, name: name),
                    primaryColor: generateRandomColor(),
                    secondaryColor: generateRandomColor()
                )
            } while usedCombinations.contains(combinationKey)
            
            usedCombinations.insert(combinationKey)
            
            // Generate roster
            team.roster = generateRoster()
            
            // Update player team IDs now that we have the team
            for i in 0..<team.roster.count {
                team.roster[i].teamId = team.id
            }
            
            team.salary = calculateTeamSalary(roster: team.roster)
            
            league.teams.append(team)
        }
        
        return league
    }
    
    func createSeason(for league: League) -> Season {
        var season = Season(year: league.currentSeason)
        season.games = generateCompleteSchedule(for: league, year: league.currentSeason)
        return season
    }
    
    // MARK: - Roster Generation
    private func generateRoster() -> [Player] {
        var roster: [Player] = []
        var usedJerseyNumbers: Set<Int> = []
        var usedNames: Set<String> = []
        
        // Generate 21 skaters
        let skaterPositions: [Position] = [
            .center, .center, .center, .center,  // 4 centers
            .leftWing, .leftWing, .leftWing, .leftWing,  // 4 left wings
            .rightWing, .rightWing, .rightWing, .rightWing,  // 4 right wings
            .leftDefense, .leftDefense, .leftDefense,  // 3 left defense
            .rightDefense, .rightDefense, .rightDefense,  // 3 right defense
            .center, .leftWing, .rightWing  // 3 additional forwards
        ]
        
        // We need the team ID, but we don't have it yet in this context
        // We'll need to update this after team creation
        let tempTeamId = UUID()
        
        for position in skaterPositions {
            let player = generateSkater(
                position: position,
                usedJerseyNumbers: &usedJerseyNumbers,
                usedNames: &usedNames,
                teamId: tempTeamId
            )
            roster.append(player)
        }
        
        // Generate 2 goalies
        for _ in 0..<2 {
            let player = generateGoalie(
                usedJerseyNumbers: &usedJerseyNumbers,
                usedNames: &usedNames,
                teamId: tempTeamId
            )
            roster.append(player)
        }
        
        return roster
    }
    
    private func generateSkater(position: Position, usedJerseyNumbers: inout Set<Int>, usedNames: inout Set<String>, teamId: UUID) -> Player {
        let (firstName, lastName) = generateUniqueName(usedNames: &usedNames)
        let jerseyNumber = generateUniqueJerseyNumber(usedNumbers: &usedJerseyNumbers)
        
        var player = Player(
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: jerseyNumber,
            position: position,
            age: Int.random(in: 18...38),
            height: Int.random(in: 68...78), // inches
            weight: Int.random(in: 165...230), // pounds
            handedness: HandednessShoot.allCases.randomElement()!,
            birthplace: cities.randomElement()!,
            teamId: teamId
        )
        
        // Generate contract
        player.contract = generateContract()
        
        // Generate randomized skater attributes
        if var attributes = player.skaterAttributes {
            attributes = randomizeSkaterAttributes(attributes, position: position)
            player.skaterAttributes = attributes
        }
        
        return player
    }
    
    private func generateGoalie(usedJerseyNumbers: inout Set<Int>, usedNames: inout Set<String>, teamId: UUID) -> Player {
        let (firstName, lastName) = generateUniqueName(usedNames: &usedNames)
        let jerseyNumber = generateUniqueJerseyNumber(usedNumbers: &usedJerseyNumbers, preferredRange: 30...39)
        
        var player = Player(
            firstName: firstName,
            lastName: lastName,
            jerseyNumber: jerseyNumber,
            position: .goalie,
            age: Int.random(in: 19...40),
            height: Int.random(in: 70...76), // inches
            weight: Int.random(in: 180...220), // pounds
            handedness: HandednessShoot.allCases.randomElement()!,
            birthplace: cities.randomElement()!,
            teamId: teamId
        )
        
        // Generate contract
        player.contract = generateContract()
        
        // Generate randomized goalie attributes
        if var attributes = player.goalieAttributes {
            attributes = randomizeGoalieAttributes(attributes)
            player.goalieAttributes = attributes
        }
        
        return player
    }
    
    // MARK: - Attribute Randomization
    private func randomizeSkaterAttributes(_ attributes: SkaterAttributes, position: Position) -> SkaterAttributes {
        var newAttributes = attributes
        
        // Base randomization for all attributes (30-80 range with normal distribution)
        newAttributes.passingAccuracy = generateAttribute()
        newAttributes.passingVision = generateAttribute()
        newAttributes.passingCreativity = generateAttribute()
        newAttributes.passingUnderPressure = generateAttribute()
        
        newAttributes.shootingAccuracy = generateAttribute()
        newAttributes.shootingPower = generateAttribute()
        newAttributes.quickRelease = generateAttribute()
        newAttributes.oneTimer = generateAttribute()
        newAttributes.reboundControl = generateAttribute()
        
        newAttributes.positioning = generateAttribute()
        newAttributes.anticipation = generateAttribute()
        newAttributes.decisionMaking = generateAttribute()
        newAttributes.gameAwareness = generateAttribute()
        newAttributes.adaptability = generateAttribute()
        
        newAttributes.stickChecking = generateAttribute()
        newAttributes.gapControl = generateAttribute()
        newAttributes.shotBlocking = generateAttribute()
        newAttributes.defensivePositioning = generateAttribute()
        
        newAttributes.bodyChecking = generateAttribute()
        newAttributes.pokeChecking = generateAttribute()
        newAttributes.forechecking = generateAttribute()
        newAttributes.backchecking = generateAttribute()
        newAttributes.intimidation = generateAttribute()
        
        newAttributes.speed = generateAttribute()
        newAttributes.acceleration = generateAttribute()
        newAttributes.agility = generateAttribute()
        newAttributes.balance = generateAttribute()
        newAttributes.stamina = generateAttribute()
        newAttributes.strength = generateAttribute()
        
        newAttributes.clutch = generateAttribute()
        newAttributes.composure = generateAttribute()
        newAttributes.focus = generateAttribute()
        newAttributes.resilience = generateAttribute()
        newAttributes.competitiveDrive = generateAttribute()
        newAttributes.coachability = generateAttribute()
        newAttributes.workEthic = generateAttribute()
        newAttributes.learningRate = generateAttribute()
        newAttributes.peakAge = Int.random(in: 24...30)
        newAttributes.declineRate = generateAttribute()
        newAttributes.injuryRecovery = generateAttribute()
        newAttributes.leadership = generateAttribute()
        newAttributes.discipline = generateAttribute()
        newAttributes.ego = generateAttribute()
        newAttributes.mediaHandling = generateAttribute()
        newAttributes.loyalty = generateAttribute()
        newAttributes.consistency = generateAttribute()
        newAttributes.injuryProne = generateAttribute(inverse: true) // Lower is better
        newAttributes.dirtyPlayer = generateAttribute(lowRange: true) // Most players aren't dirty
        
        // Position-based adjustments
        switch position {
        case .center:
            newAttributes.passingVision += 5
            newAttributes.decisionMaking += 5
            newAttributes.positioning += 3
        case .leftWing, .rightWing:
            newAttributes.shootingAccuracy += 4
            newAttributes.shootingPower += 3
            newAttributes.speed += 3
        case .leftDefense, .rightDefense:
            newAttributes.defensivePositioning += 6
            newAttributes.stickChecking += 5
            newAttributes.shotBlocking += 4
            newAttributes.bodyChecking += 3
        case .goalie:
            break // Handled separately
        }
        
        // Clamp all values to valid range
        return clampSkaterAttributes(newAttributes)
    }
    
    private func randomizeGoalieAttributes(_ attributes: GoalieAttributes) -> GoalieAttributes {
        var newAttributes = attributes
        
        newAttributes.anglePlay = generateAttribute()
        newAttributes.depthManagement = generateAttribute()
        newAttributes.netCoverage = generateAttribute()
        newAttributes.postPlay = generateAttribute()
        newAttributes.screenManagement = generateAttribute()
        
        newAttributes.gloveHand = generateAttribute()
        newAttributes.blocker = generateAttribute()
        newAttributes.padSaves = generateAttribute()
        newAttributes.reactionTime = generateAttribute()
        newAttributes.secondSaves = generateAttribute()
        
        newAttributes.reboundDirection = generateAttribute()
        newAttributes.absorption = generateAttribute()
        newAttributes.recoverySpeed = generateAttribute()
        newAttributes.scrambleAbility = generateAttribute()
        newAttributes.freezeTiming = generateAttribute()
        
        newAttributes.lateralMovement = generateAttribute()
        newAttributes.postToPost = generateAttribute()
        newAttributes.butterflyTechnique = generateAttribute()
        newAttributes.recovery = generateAttribute()
        newAttributes.flexibility = generateAttribute()
        
        newAttributes.puckPlaying = generateAttribute()
        newAttributes.passingAccuracy = generateAttribute()
        newAttributes.decisionMaking = generateAttribute()
        newAttributes.behindNet = generateAttribute()
        newAttributes.breakoutAssistance = generateAttribute()
        
        newAttributes.focus = generateAttribute()
        newAttributes.tracking = generateAttribute()
        newAttributes.anticipation = generateAttribute()
        
        newAttributes.clutch = generateAttribute()
        newAttributes.composure = generateAttribute()
        newAttributes.resilience = generateAttribute()
        newAttributes.competitiveDrive = generateAttribute()
        newAttributes.coachability = generateAttribute()
        newAttributes.workEthic = generateAttribute()
        newAttributes.learningRate = generateAttribute()
        newAttributes.peakAge = Int.random(in: 26...32)
        newAttributes.declineRate = generateAttribute()
        newAttributes.injuryRecovery = generateAttribute()
        newAttributes.leadership = generateAttribute()
        newAttributes.discipline = generateAttribute()
        newAttributes.ego = generateAttribute()
        newAttributes.mediaHandling = generateAttribute()
        newAttributes.loyalty = generateAttribute()
        newAttributes.adaptability = generateAttribute()
        newAttributes.consistency = generateAttribute()
        newAttributes.injuryProne = generateAttribute(inverse: true)
        newAttributes.dirtyPlayer = generateAttribute(lowRange: true)
        
        return clampGoalieAttributes(newAttributes)
    }
    
    // MARK: - Helper Methods
    private func generateAttribute(inverse: Bool = false, lowRange: Bool = false) -> Int {
        if lowRange {
            return Int.random(in: 1...30) // For negative traits
        }
        
        // Normal distribution around 55 with range 25-85, occasional higher values
        let base = Int.random(in: 25...85)
        let bonus = Int.random(in: 0...100) < 10 ? Int.random(in: 0...14) : 0 // 10% chance of 86-99
        let value = min(99, max(1, base + bonus))
        
        return inverse ? (100 - value) : value
    }
    
    private func generateUniqueName(usedNames: inout Set<String>) -> (String, String) {
        var firstName: String
        var lastName: String
        var fullName: String
        
        repeat {
            firstName = firstNames.randomElement()!
            lastName = lastNames.randomElement()!
            fullName = "\(firstName) \(lastName)"
        } while usedNames.contains(fullName)
        
        usedNames.insert(fullName)
        return (firstName, lastName)
    }
    
    private func generateUniqueJerseyNumber(usedNumbers: inout Set<Int>, preferredRange: ClosedRange<Int>? = nil) -> Int {
        var number: Int
        
        if let range = preferredRange {
            // Try preferred range first
            let availableInRange = Set(range).subtracting(usedNumbers)
            if !availableInRange.isEmpty {
                number = availableInRange.randomElement()!
            } else {
                // Fall back to any available number
                number = generateAnyAvailableNumber(usedNumbers: usedNumbers)
            }
        } else {
            number = generateAnyAvailableNumber(usedNumbers: usedNumbers)
        }
        
        usedNumbers.insert(number)
        return number
    }
    
    private func generateAnyAvailableNumber(usedNumbers: Set<Int>) -> Int {
        let allNumbers = Set(1...99)
        let available = allNumbers.subtracting(usedNumbers)
        return available.randomElement() ?? Int.random(in: 1...99)
    }
    
    private func generateContract() -> Contract {
        let salary = Int.random(in: 700_000...8_000_000)
        let years = Int.random(in: 1...7)
        let ntc = Int.random(in: 1...100) <= 15 // 15% chance
        let nmc = Int.random(in: 1...100) <= 8  // 8% chance
        
        return Contract(salary: salary, yearsRemaining: years, noTradeClause: ntc, noMovementClause: nmc)
    }
    
    private func calculateTeamSalary(roster: [Player]) -> Int {
        return roster.compactMap { $0.contract?.salary }.reduce(0, +)
    }
    
    private func createAbbreviation(city: String, name: String) -> String {
        let cityInitial = String(city.prefix(1))
        let nameInitials = name.count >= 2 ? String(name.prefix(2)) : name
        return cityInitial + nameInitials
    }
    
    private func generateRandomColor() -> String {
        let colors = ["blue", "red", "green", "orange", "purple", "black", "white", "yellow", "gray", "navy"]
        return colors.randomElement()!
    }
    
    private func clampSkaterAttributes(_ attributes: SkaterAttributes) -> SkaterAttributes {
        var clamped = attributes
        
        clamped.passingAccuracy = max(1, min(99, clamped.passingAccuracy))
        clamped.passingVision = max(1, min(99, clamped.passingVision))
        clamped.passingCreativity = max(1, min(99, clamped.passingCreativity))
        clamped.passingUnderPressure = max(1, min(99, clamped.passingUnderPressure))
        clamped.shootingAccuracy = max(1, min(99, clamped.shootingAccuracy))
        clamped.shootingPower = max(1, min(99, clamped.shootingPower))
        clamped.quickRelease = max(1, min(99, clamped.quickRelease))
        clamped.oneTimer = max(1, min(99, clamped.oneTimer))
        clamped.reboundControl = max(1, min(99, clamped.reboundControl))
        clamped.positioning = max(1, min(99, clamped.positioning))
        clamped.anticipation = max(1, min(99, clamped.anticipation))
        clamped.decisionMaking = max(1, min(99, clamped.decisionMaking))
        clamped.gameAwareness = max(1, min(99, clamped.gameAwareness))
        clamped.adaptability = max(1, min(99, clamped.adaptability))
        clamped.stickChecking = max(1, min(99, clamped.stickChecking))
        clamped.gapControl = max(1, min(99, clamped.gapControl))
        clamped.shotBlocking = max(1, min(99, clamped.shotBlocking))
        clamped.defensivePositioning = max(1, min(99, clamped.defensivePositioning))
        clamped.bodyChecking = max(1, min(99, clamped.bodyChecking))
        clamped.pokeChecking = max(1, min(99, clamped.pokeChecking))
        clamped.forechecking = max(1, min(99, clamped.forechecking))
        clamped.backchecking = max(1, min(99, clamped.backchecking))
        clamped.intimidation = max(1, min(99, clamped.intimidation))
        clamped.speed = max(1, min(99, clamped.speed))
        clamped.acceleration = max(1, min(99, clamped.acceleration))
        clamped.agility = max(1, min(99, clamped.agility))
        clamped.balance = max(1, min(99, clamped.balance))
        clamped.stamina = max(1, min(99, clamped.stamina))
        clamped.strength = max(1, min(99, clamped.strength))
        
        return clamped
    }
    
    private func clampGoalieAttributes(_ attributes: GoalieAttributes) -> GoalieAttributes {
        var clamped = attributes
        
        clamped.anglePlay = max(1, min(99, clamped.anglePlay))
        clamped.depthManagement = max(1, min(99, clamped.depthManagement))
        clamped.netCoverage = max(1, min(99, clamped.netCoverage))
        clamped.postPlay = max(1, min(99, clamped.postPlay))
        clamped.screenManagement = max(1, min(99, clamped.screenManagement))
        clamped.gloveHand = max(1, min(99, clamped.gloveHand))
        clamped.blocker = max(1, min(99, clamped.blocker))
        clamped.padSaves = max(1, min(99, clamped.padSaves))
        clamped.reactionTime = max(1, min(99, clamped.reactionTime))
        clamped.secondSaves = max(1, min(99, clamped.secondSaves))
        
        return clamped
    }
    
    // MARK: - Game Scheduling System
    
    /// Generates a complete 82-game schedule for all teams in the league
    private func generateCompleteSchedule(for league: League, year: Int) -> [Game] {
        let teams = league.teams
        guard teams.count >= 2 else { return [] }
        
        var allGames: [Game] = []
        let seasonStart = ImportantDates.regularSeasonStartDate(for: year)
        let seasonEnd = ImportantDates.regularSeasonEndDate(for: year)
        
        // Calculate available game days (excluding All-Star break)
        let allStarBreak = ImportantDates.allStarBreakDate(for: year)
        let allStarBreakStart = Calendar.current.date(byAdding: .day, value: -3, to: allStarBreak) ?? allStarBreak
        let allStarBreakEnd = Calendar.current.date(byAdding: .day, value: 3, to: allStarBreak) ?? allStarBreak
        
        var gameDates: [Date] = []
        var currentDate = seasonStart
        
        while currentDate <= seasonEnd {
            let weekday = Calendar.current.component(.weekday, from: currentDate)
            // Schedule games on Tue(3), Thu(5), Sat(7), Sun(1) - typical NHL schedule
            if [3, 5, 7, 1].contains(weekday) {
                // Skip All-Star break
                if !(currentDate >= allStarBreakStart && currentDate <= allStarBreakEnd) {
                    gameDates.append(currentDate)
                }
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Create matchup schedule ensuring each team plays exactly 82 games
        let schedule = createBalancedSchedule(teams: teams, availableDates: gameDates)
        
        // Convert schedule to Game objects
        for (date, matchups) in schedule {
            for (homeTeam, awayTeam) in matchups {
                let game = Game(homeTeamId: homeTeam.id, awayTeamId: awayTeam.id, date: date)
                allGames.append(game)
            }
        }
        
        return allGames.sorted { $0.date < $1.date }
    }
    
    /// Creates a balanced schedule where each team plays exactly 82 games
    private func createBalancedSchedule(teams: [Team], availableDates: [Date]) -> [Date: [(Team, Team)]] {
        var schedule: [Date: [(Team, Team)]] = [:]
        var teamGameCounts: [UUID: Int] = [:]
        var teamLastGameDate: [UUID: Date] = [:]
        
        // Initialize game counts
        for team in teams {
            teamGameCounts[team.id] = 0
        }
        
        // Create all possible matchups
        var allMatchups: [(Team, Team)] = []
        for i in 0..<teams.count {
            for j in (i+1)..<teams.count {
                let homeTeam = teams[i]
                let awayTeam = teams[j]
                
                // Each team plays each other team multiple times
                let gamesPerOpponent = calculateGamesPerOpponent(totalTeams: teams.count)
                
                for gameNum in 0..<gamesPerOpponent {
                    // Alternate home/away
                    if gameNum % 2 == 0 {
                        allMatchups.append((homeTeam, awayTeam))
                    } else {
                        allMatchups.append((awayTeam, homeTeam))
                    }
                }
            }
        }
        
        // Shuffle matchups for realistic scheduling
        allMatchups.shuffle()
        
        // Distribute games across available dates
        var dateIndex = 0
        var matchupIndex = 0
        let maxGamesPerDate = teams.count / 2 // Can't have more games than teams/2 per date
        
        while matchupIndex < allMatchups.count && dateIndex < availableDates.count {
            let currentDate = availableDates[dateIndex]
            var gamesThisDate: [(Team, Team)] = []
            var teamsUsedToday: Set<UUID> = []
            
            // Try to schedule games for this date
            var attemptCount = 0
            let maxAttempts = allMatchups.count
            
            while gamesThisDate.count < maxGamesPerDate && attemptCount < maxAttempts && matchupIndex < allMatchups.count {
                let (homeTeam, awayTeam) = allMatchups[matchupIndex]
                
                // Check if both teams are available and haven't exceeded game limits
                let homeGameCount = teamGameCounts[homeTeam.id] ?? 0
                let awayGameCount = teamGameCounts[awayTeam.id] ?? 0
                
                let canSchedule = !teamsUsedToday.contains(homeTeam.id) &&
                                !teamsUsedToday.contains(awayTeam.id) &&
                                homeGameCount < 82 &&
                                awayGameCount < 82 &&
                                isValidGameSpacing(team: homeTeam, date: currentDate, lastGameDates: teamLastGameDate) &&
                                isValidGameSpacing(team: awayTeam, date: currentDate, lastGameDates: teamLastGameDate)
                
                if canSchedule {
                    gamesThisDate.append((homeTeam, awayTeam))
                    teamsUsedToday.insert(homeTeam.id)
                    teamsUsedToday.insert(awayTeam.id)
                    
                    // Update counters
                    teamGameCounts[homeTeam.id] = homeGameCount + 1
                    teamGameCounts[awayTeam.id] = awayGameCount + 1
                    teamLastGameDate[homeTeam.id] = currentDate
                    teamLastGameDate[awayTeam.id] = currentDate
                    
                    // Remove this matchup from the list
                    allMatchups.remove(at: matchupIndex)
                } else {
                    matchupIndex += 1
                }
                
                attemptCount += 1
            }
            
            if !gamesThisDate.isEmpty {
                schedule[currentDate] = gamesThisDate
            }
            
            dateIndex += 1
            matchupIndex = 0 // Reset to try remaining matchups on next date
        }
        
        // If some teams haven't reached 82 games, add extra games
        fillRemainingGames(teams: teams, schedule: &schedule, teamGameCounts: &teamGameCounts, availableDates: availableDates)
        
        return schedule
    }
    
    /// Calculate how many games each team should play against each opponent
    private func calculateGamesPerOpponent(totalTeams: Int) -> Int {
        // For 10 teams: each team plays the other 9 teams
        // 82 games / 9 opponents = ~9 games per opponent (some will be 9, some 10 to reach exactly 82)
        let opponents = totalTeams - 1
        return 82 / opponents // This will be adjusted in fillRemainingGames
    }
    
    /// Check if enough time has passed since team's last game (avoid back-to-back unless necessary)
    private func isValidGameSpacing(team: Team, date: Date, lastGameDates: [UUID: Date]) -> Bool {
        guard let lastGame = lastGameDates[team.id] else { return true }
        
        let daysSinceLastGame = Calendar.current.dateComponents([.day], from: lastGame, to: date).day ?? 0
        
        // Prefer at least 1 day rest, but allow back-to-back if necessary later in scheduling
        return daysSinceLastGame >= 1
    }
    
    /// Fill in remaining games to ensure each team reaches exactly 82 games
    private func fillRemainingGames(teams: [Team], schedule: inout [Date: [(Team, Team)]], teamGameCounts: inout [UUID: Int], availableDates: [Date]) {
        
        // Find teams that need more games
        var teamsNeedingGames: [Team] = []
        for team in teams {
            let gameCount = teamGameCounts[team.id] ?? 0
            if gameCount < 82 {
                teamsNeedingGames.append(team)
            }
        }
        
        // Create additional matchups for teams that need more games
        while !teamsNeedingGames.isEmpty {
            teamsNeedingGames.shuffle()
            
            var i = 0
            while i < teamsNeedingGames.count - 1 {
                let team1 = teamsNeedingGames[i]
                let team2 = teamsNeedingGames[i + 1]
                
                let team1Games = teamGameCounts[team1.id] ?? 0
                let team2Games = teamGameCounts[team2.id] ?? 0
                
                if team1Games < 82 && team2Games < 82 {
                    // Find available date
                    if let availableDate = findAvailableDate(for: [team1, team2], in: schedule, availableDates: availableDates) {
                        
                        // Alternate home/away
                        let matchup = team1Games % 2 == 0 ? (team1, team2) : (team2, team1)
                        
                        if schedule[availableDate] == nil {
                            schedule[availableDate] = []
                        }
                        schedule[availableDate]?.append(matchup)
                        
                        teamGameCounts[team1.id] = team1Games + 1
                        teamGameCounts[team2.id] = team2Games + 1
                        
                        // Remove teams that have reached 82 games
                        if teamGameCounts[team1.id] == 82 {
                            teamsNeedingGames.removeAll { $0.id == team1.id }
                        }
                        if teamGameCounts[team2.id] == 82 {
                            teamsNeedingGames.removeAll { $0.id == team2.id }
                        }
                        
                        i += 2 // Skip both teams
                    } else {
                        i += 1
                    }
                } else {
                    // Remove teams that have reached their limit
                    if team1Games >= 82 {
                        teamsNeedingGames.removeAll { $0.id == team1.id }
                    }
                    if team2Games >= 82 {
                        teamsNeedingGames.removeAll { $0.id == team2.id }
                    }
                    i += 1
                }
            }
            
            // If we can't pair teams, break to avoid infinite loop
            if teamsNeedingGames.count == 1 {
                break
            }
        }
    }
    
    /// Find an available date for the given teams
    private func findAvailableDate(for teams: [Team], in schedule: [Date: [(Team, Team)]], availableDates: [Date]) -> Date? {
        for date in availableDates {
            let gamesThisDate = schedule[date] ?? []
            let teamsUsedThisDate = Set(gamesThisDate.flatMap { [$0.0.id, $0.1.id] })
            
            // Check if all required teams are available this date
            let teamsAvailable = teams.allSatisfy { !teamsUsedThisDate.contains($0.id) }
            
            if teamsAvailable && gamesThisDate.count < teams.count / 2 {
                return date
            }
        }
        return nil
    }
}