# Claude CLI Instructions: Hockey Simulation Date Logic (Swift)

## Project Overview
You are building a comprehensive date logic system for a hockey simulation game in Swift. This system needs to handle:
- Season progression and scheduling
- Player development over time
- Contract management and salary cap
- Trade deadlines and free agency periods
- Injury recovery timelines
- Statistical tracking across seasons

## Core Requirements

### 1. Season Structure & Calendar System
Create a robust calendar system that handles:
- **Regular Season:** ~82 games from October to April
- **Playoffs:** April to June (4 rounds, best of 7)
- **Off-Season:** June to September
- **Pre-Season:** September training camps and exhibition games
- **All-Star Break:** Mid-season break in February
- **Trade Deadline:** Typically late February/early March
- **Draft:** Late June
- **Free Agency:** Begins July 1st

### 2. Game Scheduling Logic
Implement scheduling that considers:
- Home/away game distribution
- Back-to-back game limitations
- Travel time between cities
- Arena availability conflicts
- Holiday scheduling (Christmas break, etc.)
- TV broadcast preferences (weekends, prime time)

### 3. Player Development Timeline
Create age-based development curves:
- **Prospects (18-21):** Rapid skill growth potential
- **Prime Years (22-29):** Peak performance plateau
- **Veterans (30+):** Gradual decline with experience gains
- **Injury Recovery:** Time-based healing with attribute impacts
- **Training Effects:** Off-season and in-season development

### 4. Contract & Salary Management
Build systems for:
- Contract expiration tracking
- Salary cap calculations by season
- Performance bonuses triggered by stats/achievements
- Buyout calculations and cap penalties
- Entry-level contract progression
- Arbitration eligibility windows

## Technical Implementation Guidelines

### File Structure
Create the following core modules:
```
Sources/
├── Calendar/
│   ├── SeasonCalendar.swift
│   ├── GameScheduler.swift
│   └── ImportantDates.swift
├── Simulation/
│   ├── DateSimulator.swift
│   ├── PlayerDevelopment.swift
│   └── ContractManager.swift
├── Events/
│   ├── TradeDeadline.swift
│   ├── FreeAgency.swift
│   └── Draft.swift
└── Utils/
    ├── DateHelpers.swift
    └── Constants.swift
```

### Key Classes/Structs to Implement

#### 1. SeasonPhase Enum
```swift
enum SeasonPhase: String, CaseIterable, Codable {
    case preseason = "PRESEASON"
    case regular = "REGULAR"
    case playoffs = "PLAYOFFS" 
    case offseason = "OFFSEASON"
    
    var displayName: String {
        switch self {
        case .preseason: return "Pre-Season"
        case .regular: return "Regular Season"
        case .playoffs: return "Playoffs"
        case .offseason: return "Off-Season"
        }
    }
}
```

#### 2. SeasonCalendar Class
```swift
class SeasonCalendar: ObservableObject, Codable {
    @Published var currentDate: Date
    @Published var season: Int
    @Published var phase: SeasonPhase
    
    init(startYear: Int) {
        self.currentDate = Date()
        self.season = startYear
        self.phase = .preseason
    }
    
    // Methods to implement:
    // func advanceDate(by days: Int)
    // func getCurrentPhase() -> SeasonPhase
    // func getDaysUntilNextPhase() -> Int
    // func isTradeDeadline() -> Bool
    // func isAllStarBreak() -> Bool
    // func getGamesRemainingInSeason() -> Int
    // func transitionToNextPhase()
}
```

#### 3. PlayerDevelopment Class
```swift
class PlayerDevelopment: Codable {
    // Handle age-based attribute changes
    // Implement development curves using mathematical functions
    // Process injuries and recovery with TimeInterval
    // Apply training effects with modifiers
    // Manage potential ratings vs current ratings
    
    static func calculateDevelopmentCurve(age: Int, potential: Int, position: PlayerPosition) -> Double {
        // Age-based development curve calculation
    }
    
    func processAging(for player: Player, calendar: SeasonCalendar) {
        // Apply yearly development/decline
    }
    
    func applyInjuryRecovery(for player: Player, days: Int) {
        // Handle injury healing over time
    }
}
```

#### 4. GameScheduler Class
```swift
class GameScheduler {
    private let teams: [Team]
    private let calendar: SeasonCalendar
    
    // Generate season schedules with proper distribution
    func generateSeasonSchedule() -> [Game] {
        // Create 82-game schedule for each team
        // Balance home/away games
        // Avoid too many back-to-backs
        // Consider travel distances
    }
    
    func scheduleGame(homeTeam: Team, awayTeam: Team, date: Date) -> Game? {
        // Check for conflicts and create game
    }
    
    func optimizeScheduleForTravel() {
        // Minimize travel fatigue
    }
}
```

### Critical Features to Include

#### Date Progression System
```swift
protocol DateSimulationDelegate: AnyObject {
    func willAdvanceDate(to newDate: Date)
    func didAdvanceDate(from oldDate: Date, to newDate: Date)
    func shouldPauseForEvent(_ event: SimulationEvent) -> Bool
}

class DateSimulator {
    weak var delegate: DateSimulationDelegate?
    private let calendar: SeasonCalendar
    private let eventQueue: EventQueue
    
    func simulateToDate(_ targetDate: Date, speed: SimulationSpeed) {
        // Advance day by day, processing events
    }
    
    func processEventsForDate(_ date: Date) {
        // Handle all events scheduled for this date
    }
}
```

#### Event Queue System
```swift
struct SimulationEvent: Codable {
    let id: UUID
    let date: Date
    let type: EventType
    let priority: EventPriority
    let data: [String: Any]
}

enum EventType: String, Codable {
    case gameDay
    case contractExpiry
    case tradeDeadline
    case freeAgencyStart
    case draft
    case playerBirthday
    case injuryRecovery
    case seasonTransition
}

class EventQueue {
    private var events: [SimulationEvent] = []
    
    func scheduleEvent(_ event: SimulationEvent) {
        events.append(event)
        events.sort { $0.date < $1.date }
    }
    
    func getEventsForDate(_ date: Date) -> [SimulationEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func removeProcessedEvents(before date: Date) {
        events.removeAll { $0.date < date }
    }
}
```

#### Performance Considerations
```swift
// Use DateFormatter sparingly - create once and reuse
extension DateFormatter {
    static let gameDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    static let seasonYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}

// Efficient date calculations using Calendar
extension Calendar {
    func daysBetween(_ date1: Date, and date2: Date) -> Int {
        let components = dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
}
```

### Integration Points

#### With Game Simulation
```swift
protocol GameSimulationContext {
    var currentDate: Date { get }
    var seasonPhase: SeasonPhase { get }
    var daysSinceLastGame: Int { get }
    var isBackToBack: Bool { get }
    var travelFatigue: Double { get }
}

extension SeasonCalendar: GameSimulationContext {
    var isBackToBack: Bool {
        // Check if team played yesterday
    }
    
    var travelFatigue: Double {
        // Calculate based on travel distance and time
    }
}
```

#### With SwiftUI Views
```swift
// Make calendar observable for UI updates
class SeasonCalendar: ObservableObject {
    @Published var currentDate: Date
    @Published var phase: SeasonPhase
    
    // Computed properties for UI
    var formattedDate: String {
        DateFormatter.gameDate.string(from: currentDate)
    }
    
    var seasonDisplayString: String {
        return "\(season)-\(String(season + 1).suffix(2))"
    }
}
```

## Specific Implementation Tasks

### Phase 1: Core Calendar Foundation
1. Create `SeasonPhase` enum and `SeasonCalendar` class
2. Implement basic date progression with `advanceDate(by:)`
3. Add season phase transitions with proper date ranges
4. Build `ImportantDates` utility with key hockey calendar dates
5. Create `DateHelpers` extension for common calculations

### Phase 2: Game Scheduling System
1. Implement `GameScheduler` with basic schedule generation
2. Add travel distance calculations between cities
3. Create back-to-back game detection and penalties
4. Implement schedule optimization for rest and travel
5. Add holiday and special event scheduling

### Phase 3: Player Development Timeline
1. Create age-based development curves using mathematical functions
2. Implement `PlayerDevelopment` class with aging processes
3. Add injury system with recovery timelines using `TimeInterval`
4. Build training effects and conditioning systems
5. Create potential vs. current rating progression

### Phase 4: Contract & Business Logic
1. Implement contract expiration tracking with date comparisons
2. Build salary cap calculations by season
3. Create performance bonus trigger system
4. Add trade deadline mechanics and restrictions
5. Implement free agency periods and eligibility

### Phase 5: Advanced Features & Polish
1. Add historical stat tracking across multiple seasons
2. Implement award voting systems with date-based eligibility
3. Create Hall of Fame tracking and retirement logic
4. Add save/load functionality with `Codable`
5. Optimize performance for multi-season simulations

## Swift-Specific Best Practices

### Error Handling
```swift
enum SimulationError: Error {
    case invalidDate(String)
    case scheduleConflict(String)
    case contractCalculationError(String)
    case corruptedSaveData(String)
}

func advanceDate(by days: Int) throws {
    guard days > 0 else {
        throw SimulationError.invalidDate("Cannot advance by negative days")
    }
    // Implementation
}
```

### Memory Management
```swift
// Use weak references for delegates to prevent retain cycles
weak var delegate: DateSimulationDelegate?

// Use value types (structs) for data models when appropriate
struct GameResult: Codable {
    let date: Date
    let homeTeam: TeamID
    let awayTeam: TeamID
    let homeScore: Int
    let awayScore: Int
}

// Use lazy loading for expensive calculations
lazy var developmentCurve: [Int: Double] = {
    return calculateDevelopmentCurve()
}()
```

### Data Persistence
```swift
extension SeasonCalendar {
    func save(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }
    
    static func load(from url: URL) throws -> SeasonCalendar {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(SeasonCalendar.self, from: data)
    }
}
```

### Testing Requirements
- Unit tests for all date calculations and transitions
- Test season rollovers and leap year handling
- Verify contract calculations across multiple seasons
- Performance tests with 30+ season simulations
- Test save/load functionality with various game states

## Documentation Requirements
- Use Swift documentation comments (///) for all public APIs
- Provide code examples for complex calculations
- Document mathematical formulas used in development curves
- Include troubleshooting guide for common date-related issues
- Create sample usage patterns for integration

Begin with Phase 1 and establish a solid Swift foundation using proper value types, error handling, and the Foundation framework's robust date handling capabilities. Focus on making the system type-safe, performant, and thoroughly testable.