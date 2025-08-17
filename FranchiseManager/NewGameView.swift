import SwiftUI

struct NewGameView: View {
    @State private var saveName: String = ""
    @State private var isCreatingLeague = false
    @State private var createdSavedGame: SavedGame?
    @State private var shouldShowGameView = false
    @State private var finalSavedGame: SavedGame?
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "hockey.puck")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Create New Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Save Game Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Enter save name...", text: $saveName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 400)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                // Allow Enter key to trigger create game if name is valid
                                if !saveName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    createNewGame()
                                }
                            }
                    }
                    
                    if isCreatingLeague {
                        VStack(spacing: 15) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Creating league and generating teams...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                    } else {
                        HStack(spacing: 20) {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            
                            Button("Create Game") {
                                createNewGame()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(saveName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .sheet(item: $createdSavedGame) { savedGame in
            TeamSelectionView(
                savedGame: savedGame,
                onTeamSelected: { updatedSavedGame in
                    createdSavedGame = nil
                    finalSavedGame = updatedSavedGame
                    shouldShowGameView = true
                }
            )
        }
        .navigationDestination(isPresented: $shouldShowGameView) {
            if let savedGame = finalSavedGame {
                MainGameView(savedGame: savedGame)
            }
        }
    }
    
    private func createNewGame() {
        // Dismiss keyboard/text field focus first
        isTextFieldFocused = false
        isCreatingLeague = true
        
        // Add a small delay to ensure UI state is clean
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            DispatchQueue.global(qos: .userInitiated).async {
                let generator = GameDataGenerator()
                let league = generator.createLeague()
                let season = generator.createSeason(for: league)
                let savedGame = SavedGame(
                    gameName: self.saveName.trimmingCharacters(in: .whitespacesAndNewlines),
                    playerTeamId: league.teams.first?.id ?? UUID(),
                    league: league,
                    season: season
                )
                
                DispatchQueue.main.async {
                    self.isCreatingLeague = false
                    self.createdSavedGame = savedGame
                }
            }
        }
    }
}


struct TeamSelectionView: View {
    let savedGame: SavedGame
    let onTeamSelected: (SavedGame) -> Void
    @State private var selectedTeamId: UUID?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Text("Select Your Team")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(savedGame.league.name)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(savedGame.league.teams, id: \.id) { team in
                            TeamSelectionCard(
                                team: team,
                                isSelected: selectedTeamId == team.id
                            ) {
                                selectedTeamId = team.id
                            }
                        }
                    }
                    .padding()
                }
                
                if selectedTeamId != nil {
                    Button("Start Managing") {
                        startGame()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                
                Spacer()
            }
        }
        .navigationTitle("")
    }
    
    private func startGame() {
        guard let selectedTeamId = selectedTeamId else { return }
        
        var updatedSavedGame = savedGame
        updatedSavedGame.playerTeamId = selectedTeamId
        
        presentationMode.wrappedValue.dismiss()
        onTeamSelected(updatedSavedGame)
    }
}

struct TeamSelectionCard: View {
    let team: Team
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(team.fullName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                Text("\(team.rosterCount) Players")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NewGameView()
}