# Claude CLI Instructions: Hockey Simulation Advance Day System

## Project Overview
Create a complete "Advance Day" system for a hockey simulation game in Swift. When the advance day button is clicked, the system should:
1. Auto-generate optimal lineups for all teams based on player overall ratings
2. Simulate all scheduled games for that day
3. Update team records (wins/losses) and player statistics
4. Save all results to persistent storage

## Core Requirements

### Input Data Structure
You have access to the existing `SkaterAttributes` struct with overall calculation. Build upon this foundation.

### Required Data Models
Create these Swift structs/classes with Codable conformance:

1. **Player Model** - Include: id, name, position, age, teamID, attributes, seasonStats, careerStats, injury status
2. **Team Model** - Include: id, name, city, players array, lineup, seasonRecord
3. **Game Model** - Include: id, homeTeamID, awayTeamID, date, isPlayed, result
4. **PlayerStats Model** - Track: games, goals, assists, +/-, PIM, shots, hits, blocks, faceoffs, TOI
5. **TeamRecord Model** - Track: wins, losses, OT losses, points calculation
6. **GameResult Model** - Store: final score, overtime flag, all player statistics
7. **TeamLineup Model** - Store: 4 forward lines (3 players each), 3 defense pairs (2 each), goalies

### Position-Specific Overall Calculations
Modify the overall calculation to be position-specific:
- **Centers:** Weight passing vision and decision making higher
- **Wingers:** Weight shooting accuracy and speed higher  
- **Defense:** Weight defensive positioning and stick checking higher
- **Goalies:** Use base overall (separate goalie attributes needed later)

## Implementation Tasks

### Phase 1: Data Models and Core Structure
Create all required data models with proper Swift naming conventions, Codable conformance, and computed properties. Include position enum with cases for LW, C, RW, LD, RD, G.

### Phase 2: Lineup Generation System
Build `LineupManager` class with static methods:
- `generateOptimalLineup(for team: Team) -> TeamLineup`
- Sort players by position-specific overall rating
- Distribute talent across lines (best players on line 1, etc.)
- Ensure each line has proper position distribution when possible
- Handle teams with insufficient players gracefully

### Phase 3: Game Simulation Engine
Create `GameSimulator` class with core method:
- `simulateGame(homeTeam: Team, awayTeam: Team) -> GameResult`

**Simulation Logic:**
- Calculate team offensive strength (average of forward shooting/passing/speed)
- Calculate team defensive strength (average of defense positioning/checking + goalie)
- Use simple expected goals model: offense / (opponent defense + 50) * 3.0
- Generate actual goals using randomization with expected goals as baseline
- Handle overtime scenarios (tied games get OT, 50% chance either team wins)
- Distribute individual player stats based on line deployment and randomization

### Phase 4: Player Statistics Generation
For each simulated game, generate realistic individual stats:
- Distribute team goals/assists among players (forwards get most)
- Calculate +/- based on goal differential and ice time
- Generate shots, hits, blocks based on player attributes and position
- Add penalty minutes based on discipline attribute
- Assign appropriate time on ice by line (line 1 = ~20min, line 4 = ~8min)

### Phase 5: Advance Day Coordinator
Create main `AdvanceDayManager` class:
- `advanceDay(league: League, currentDate: Date)`
- Auto-generate lineups for all teams missing them
- Find all games scheduled for current date
- Simulate each game and collect results
- Update team records based on game outcomes
- Update player season/career statistics
- Handle injury recovery (reduce injury days by 1)
- Save all changes to persistent storage

### Phase 6: League Management System
Create `League` class to coordinate everything:
- Store all teams and players
- Maintain game schedule
- Provide methods to get games by date
- Handle league-wide statistics and standings
- Manage save/load functionality

## Technical Specifications

### Error Handling
Use Swift's error handling for:
- Invalid team configurations (not enough players)
- Missing game data
- Save/load failures
- Malformed lineup data

### Performance Considerations
- Use efficient algorithms for player sorting
- Batch database/file operations
- Cache calculated team strengths
- Minimize object copying during simulation

### Data Persistence
Implement save/load using:
- JSONEncoder/JSONDecoder for Codable conformance
- FileManager for local storage
- Atomic saves to prevent data corruption
- Backup system for critical game state

### Randomization Approach
Use controlled randomization:
- Seed-based random number generation for reproducible results
- Weighted probability distributions for realistic outcomes
- Attribute-based modifiers (higher skill = better performance probability)
- Prevent extreme outliers while allowing for surprises

## Integration Points

### UI Integration
Design the system to work with SwiftUI:
- Use ObservableObject for league state
- Provide computed properties for UI display
- Include progress tracking for simulation
- Handle async operations properly

### Future Extensibility
Structure code to easily add:
- Injuries during games
- Coaching systems and strategies
- Player chemistry and line combinations
- Advanced statistics and analytics
- Trade and roster management

## Validation Requirements

### Test Scenarios
Ensure the system handles:
- Teams with exactly minimum players (18 skaters + 2 goalies)
- Teams with injury-depleted rosters
- Multiple games on same day
- Season transitions and playoffs
- Statistical accuracy and accumulation

### Realistic Output Validation
Verify that simulated results produce:
- Reasonable scoring totals (2-6 goals per team average)
- Proper statistical distributions (top players get most points)
- Realistic +/- ranges (-3 to +3 typical)
- Appropriate penalty minute totals
- Sensible time on ice distributions

## Implementation Order
1. Start with core data models and ensure they compile
2. Build lineup generation and test with sample teams
3. Create basic game simulation without player stats
4. Add individual player statistics generation
5. Integrate everything into AdvanceDayManager
6. Add persistence and error handling
7. Create comprehensive test suite

## Success Criteria
- System can simulate a full day of NHL games (15+ games) in under 2 seconds
- Generated statistics appear realistic when compared to real NHL data
- All data persists correctly between app sessions
- UI remains responsive during simulation
- No crashes or data corruption under normal usage

Focus on creating a robust foundation that can be extended rather than trying to implement every hockey nuance immediately. The goal is a working simulation that produces believable results and can be enhanced over time.
