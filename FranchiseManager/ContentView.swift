//
//  ContentView.swift
//  FranchiseManager
//
//  Created by Tristan Gilbert on 2025-08-02.
//

import SwiftUI

struct ContentView: View {
    @State private var showGame = false
    @State private var loadedGame: SavedGame?
    @State private var showLoadView = false
    
    var body: some View {
        NavigationStack {
            if showGame && loadedGame != nil {
                MainGameView(savedGame: loadedGame!)
                    .onAppear {
                        print("📂 NAVIGATION: MainGameView appeared for game: \(loadedGame!.gameName)")
                    }
            } else {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 40) {
                        VStack(spacing: 10) {
                            Image(systemName: "hockey.puck")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("Franchise Manager")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 20) {
                            NavigationLink(destination: NewGameView()) {
                                MenuButton(title: "New Game", icon: "plus.circle.fill")
                            }
                            
                            Button(action: {
                                print("📂 BUTTON: Load Game button clicked!")
                                showLoadView = true
                            }) {
                                MenuButton(title: "Load Game", icon: "folder.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            MenuButton(title: "Settings", icon: "gearshape.fill")
                            
                            MenuButton(title: "Exit", icon: "xmark.circle.fill")
                        }
                    }
                    
                    if showLoadView {
                        LoadGameView(
                            showLoadView: $showLoadView,
                            selectedGame: $loadedGame,
                            showGame: $showGame
                        )
                    }
                }
            }
        }
        .onChange(of: showGame) { oldValue, newValue in
            print("📂 NAVIGATION: showGame changed from \(oldValue) to \(newValue)")
            print("📂 NAVIGATION: loadedGame is: \(loadedGame?.gameName ?? "nil")")
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
}
