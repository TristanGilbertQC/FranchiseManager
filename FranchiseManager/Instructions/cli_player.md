Looking at your code, I can see the issue. The problem is with how SwiftUI's navigationDestination works - it needs to be attached to the NavigationStack, not nested inside it.
Here's the issue: Your navigationDestination is inside the NavigationStack's content, but it should be a modifier on the NavigationStack itself.
Here's the fix:
swiftstruct ContentView: View {
    @State private var showGame = false
    @State private var loadedGame: SavedGame?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // ... your gradient background ...
                
                VStack(spacing: 40) {
                    // ... your UI content ...
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: NewGameView()) {
                            MenuButton(title: "New Game", icon: "plus.circle.fill")
                        }
                        
                        Button(action: {
                            print("📂 BUTTON: Load Game button clicked!")
                            simpleLoadWithList()
                        }) {
                            MenuButton(title: "Load Game", icon: "folder.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // ... other buttons ...
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showGame) {  // Move this OUTSIDE the NavigationStack content
            if let game = loadedGame {
                MainGameView(savedGame: game)
                    .onAppear {
                        print("📂 NAVIGATION: MainGameView appeared for game: \(game.gameName)")
                    }
            } else {
                Text("Error: No game loaded")
                    .foregroundColor(.red)
                    .onAppear {
                        print("📂 NAVIGATION: ❌ loadedGame is nil!")
                    }
            }
        }
        .onChange(of: showGame) { oldValue, newValue in
            print("📂 NAVIGATION: showGame changed from \(oldValue) to \(newValue)")
        }
    }
    
    // ... rest of your code ...
}
The key change is moving .navigationDestination(isPresented:) to be a modifier on the NavigationStack itself, not on a view inside the stack.
Your load logic is working correctly (I can see from your logs that it's successfully loading the game and setting showGame = true), but the navigation isn't triggering because the destination modifier wasn't properly attached to the navigation stack.
This should fix the navigation issue and make your load game functionality work properly!
