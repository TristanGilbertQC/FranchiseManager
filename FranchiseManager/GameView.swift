import SwiftUI

// Legacy GameView.swift - Content moved to organized Views directory

#Preview {
    let samplePlayer = Player(
        firstName: "Connor",
        lastName: "McDavid",
        jerseyNumber: 97,
        position: .center,
        age: 26,
        height: 73,
        weight: 193,
        handedness: .left,
        birthplace: "Richmond Hill, ON"
    )
    
    var sampleTeam = Team(
        name: "Oilers",
        city: "Edmonton",
        abbreviation: "EDM",
        primaryColor: "blue",
        secondaryColor: "orange"
    )
    sampleTeam.addPlayer(samplePlayer)
    
    let sampleLeague = League(name: "USER LEAGUE", teams: [sampleTeam], currentSeason: 2025)
    let sampleSeason = Season(year: 2025)
    let sampleSavedGame = SavedGame(
        gameName: "Test Save", 
        playerTeamId: sampleTeam.id, 
        league: sampleLeague, 
        season: sampleSeason
    )
    
    return MainGameView(savedGame: sampleSavedGame)
}