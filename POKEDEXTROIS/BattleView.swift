import SwiftUI

struct BattleView: View {
    @State var playerPokemon: Pokemon
    @State var enemyPokemon: Pokemon
    @State private var playerHP: Double
    @State private var enemyHP: Double
    @State private var isPlayerTurn: Bool
    @State private var battleMessage: String = "The battle begins!"
    @State private var isBattleInProgress = false

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
                AsyncImage(url: URL(string: playerPokemon.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image.resizable().scaledToFit().frame(width: 80, height: 80)
                    case .failure:
                        Image(systemName: "xmark.circle.fill")
                            .frame(width: 80, height: 80)
                    @unknown default:
                        EmptyView()
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
                AsyncImage(url: URL(string: enemyPokemon.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image.resizable().scaledToFit().frame(width: 80, height: 80)
                    case .failure:
                        Image(systemName: "xmark.circle.fill")
                            .frame(width: 80, height: 80)
                    @unknown default:
                        EmptyView()
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
                    .frame(width: CGFloat(playerHP), height: 20)
                    .animation(.easeInOut(duration: 0.5))
            }
            .padding()

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
                    .frame(width: CGFloat(enemyHP), height: 20)
                    .animation(.easeInOut(duration: 0.5))
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
                let attackPower = bestAttack(for: playerPokemon)
                let defensePower = bestDefense(for: enemyPokemon)
                let damage = attackPower - defensePower
                enemyHP = max(0, enemyHP - Double(damage))
            } else {
                battleMessage = "\(enemyPokemon.name.capitalized) attacks!"
                let attackPower = bestAttack(for: enemyPokemon)
                let defensePower = bestDefense(for: playerPokemon)
                let damage = attackPower - defensePower
                playerHP = max(0, playerHP - Double(damage))
            }

            isPlayerTurn.toggle()

            // Continue the battle automatically until one side wins
            runAutomaticBattle()
        }
    }

    private func endBattle() {
        if playerHP == 0 {
            battleMessage = "\(enemyPokemon.name.capitalized) wins!"
        } else if enemyHP == 0 {
            battleMessage = "\(playerPokemon.name.capitalized) wins!"
        }
        isBattleInProgress = false
    }

    private func bestAttack(for pokemon: Pokemon) -> Int {
        let highestStat = pokemon.stats.filter { $0.key == "attack" || $0.key == "special-attack" }
        let bestAttack = highestStat.max(by: { $0.value < $1.value })
        return bestAttack?.value ?? 0
    }


    private func bestDefense(for pokemon: Pokemon) -> Int {
        let highestDefense = pokemon.stats.filter { $0.key.contains("defense") }
        let bestDefense = highestDefense.max(by: { $0.value < $1.value })
        return bestDefense?.value ?? 0
    }
}
