import SwiftUI

struct MainGameView: View {
    @State var savedGame: SavedGame
    @State private var selectedTab = 0
    
    var playerTeam: Team? {
        return savedGame.league.teams.first { $0.id == savedGame.playerTeamId }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(savedGame: $savedGame)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            CalendarView(savedGame: $savedGame)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)
            
            RosterView(savedGame: $savedGame)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Roster")
                }
                .tag(2)
            
            LinesView(savedGame: $savedGame)
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Lines")
                }
                .tag(3)
            
            TradesView(savedGame: $savedGame)
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Trades")
                }
                .tag(4)
        }
        .navigationTitle(playerTeam?.fullName ?? "Franchise Manager")
    }
}