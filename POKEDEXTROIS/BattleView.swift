import SwiftUI

struct BattleView: View {
    @State var playerPokemon: Pokemon
    @State var enemyPokemon: Pokemon
    @State private var playerHP: Double
    @State private var enemyHP: Double
    @State private var isPlayerTurn: Bool
    @State private var battleMessage: String = "The battle begins!"
    @State private var isBattleInProgress = false
    @State private var attackAnimation: Bool = false
    @State private var playerOffset: CGFloat = 0
    @State private var enemyOffset: CGFloat = 0
    @State private var playerDamageText: String? = nil
    @State private var enemyDamageText: String? = nil
    @State private var playerDamageOpacity: Double = 1.0
    @State private var enemyDamageOpacity: Double = 1.0

    init(playerPokemon: Pokemon, enemyPokemon: Pokemon) {
        self._playerPokemon = State(initialValue: playerPokemon)
        self._enemyPokemon = State(initialValue: enemyPokemon)
        self._playerHP = State(initialValue: Double(playerPokemon.stats["hp"] ?? 100))
        self._enemyHP = State(initialValue: Double(enemyPokemon.stats["hp"] ?? 100))
        self._isPlayerTurn = State(initialValue: playerPokemon.stats["speed"] ?? 0 > enemyPokemon.stats["speed"] ?? 0)
    }

    var body: some View {
        VStack {
            Text(battleMessage)
                .font(.title)
                .padding()

            HStack {
                // Player Pokémon Image with animation
                ZStack {
                    AsyncImage(url: URL(string: playerPokemon.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image.resizable().scaledToFit()
                                .frame(width: 80, height: 80)
                                .offset(x: playerOffset)
                                .animation(.easeInOut(duration: 0.5), value: playerOffset)
                        case .failure:
                            Image(systemName: "xmark.circle.fill")
                                .frame(width: 80, height: 80)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    if let damageText = playerDamageText {
                        Text(damageText)
                            .foregroundColor(.red)
                            .font(.title)
                            .bold()
                            .offset(y: -40)
                            .opacity(playerDamageOpacity)
                            .animation(.easeOut(duration: 1.0), value: playerDamageOpacity)
                    }
                }

                VStack {
                    Text(playerPokemon.name.capitalized)
                        .font(.title2)
                    Text("HP: \(Int(playerHP))")
                        .foregroundColor(.green)
                }
            }

            HStack {
                // Enemy Pokémon Image with animation
                ZStack {
                    AsyncImage(url: URL(string: enemyPokemon.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image.resizable().scaledToFit()
                                .frame(width: 80, height: 80)
                                .offset(x: enemyOffset)
                                .animation(.easeInOut(duration: 0.5), value: enemyOffset)
                        case .failure:
                            Image(systemName: "xmark.circle.fill")
                                .frame(width: 80, height: 80)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    if let damageText = enemyDamageText {
                        Text(damageText)
                            .foregroundColor(.red)
                            .font(.title)
                            .bold()
                            .offset(y: -40)
                            .opacity(enemyDamageOpacity)
                            .animation(.easeOut(duration: 1.0), value: enemyDamageOpacity)
                    }
                }

                VStack {
                    Text(enemyPokemon.name.capitalized)
                        .font(.title2)
                    Text("HP: \(Int(enemyHP))")
                        .foregroundColor(.red)
                }
            }

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: CGFloat(playerHP / Double(playerPokemon.stats["hp"] ?? 100)) * 200, height: 20)
                    .animation(.easeInOut(duration: 0.5), value: playerHP)
            }
            .padding()

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
                    .frame(width: CGFloat(enemyHP / Double(enemyPokemon.stats["hp"] ?? 100)) * 200, height: 20)
                    .animation(.easeInOut(duration: 0.5), value: enemyHP)
            }
            .padding()
        }
        .onAppear {
            startAutomaticBattle()
        }
    }

    private func startAutomaticBattle() {
        isBattleInProgress = true
        battleMessage = "The battle begins!"
        runAutomaticBattle()
    }

    private func runAutomaticBattle() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard playerHP > 0 && enemyHP > 0 else {
                endBattle()
                return
            }

            if isPlayerTurn {
                battleMessage = "\(playerPokemon.name.capitalized) attacks!"
                playerOffset = 20  // Move player towards the enemy
                let attackPower = bestAttack(for: playerPokemon)
                let defensePower = bestDefense(for: enemyPokemon, isSpecialAttack: attackPower == bestAttack(for: playerPokemon, isSpecial: true))
                let damage = max(1, attackPower - defensePower) // Ensure at least 1 damage
                enemyHP = max(0, enemyHP - Double(damage))
                enemyDamageText = "-\(damage)"
                enemyDamageOpacity = 1.0
                withAnimation {
                    enemyDamageOpacity = 0.0
                }
            } else {
                battleMessage = "\(enemyPokemon.name.capitalized) attacks!"
                enemyOffset = -20  // Move enemy towards the player
                let attackPower = bestAttack(for: enemyPokemon)
                let defensePower = bestDefense(for: playerPokemon, isSpecialAttack: attackPower == bestAttack(for: enemyPokemon, isSpecial: true))
                let damage = max(1, attackPower - defensePower) // Ensure at least 1 damage
                playerHP = max(0, playerHP - Double(damage))
                playerDamageText = "-\(damage)"
                playerDamageOpacity = 1.0
                withAnimation {
                    playerDamageOpacity = 0.0
                }
            }

            // Reset the offsets to return Pokémon to starting positions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                playerOffset = 0
                enemyOffset = 0
            }

            isPlayerTurn.toggle()

            // Continue the battle automatically until one side wins
            runAutomaticBattle()
        }
    }

    private func bestAttack(for pokemon: Pokemon, isSpecial: Bool = false) -> Int {
        if isSpecial {
            let specialAttack = pokemon.stats["special-attack"] ?? 0
            return specialAttack
        } else {
            let attack = pokemon.stats["attack"] ?? 0
            return attack
        }
    }

    private func bestDefense(for pokemon: Pokemon, isSpecialAttack: Bool) -> Int {
        let defenseKey = isSpecialAttack ? "special-defense" : "defense"
        let defense = pokemon.stats[defenseKey] ?? 0
        return defense
    }

    private func endBattle() {
        if playerHP == 0 {
            battleMessage = "\(enemyPokemon.name.capitalized) wins!"
        } else if enemyHP == 0 {
            battleMessage = "\(playerPokemon.name.capitalized) wins!"
        }
        isBattleInProgress = false
    }
}
