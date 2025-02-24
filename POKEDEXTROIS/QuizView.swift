import SwiftUI

struct QuizView: View {
    @State private var pokemons: [Pokemon] = []
    @State private var currentPokemon: Pokemon? = nil
    @State private var scrambledName: String = ""
    @State private var userGuess: String = ""
    @State private var isCorrect: Bool? = nil
    @State private var quizMessage: String = "Try to unscramble the name!"
    
    var body: some View {
        VStack {
            Text(quizMessage)
                .font(.title2)
                .padding()

            if let currentPokemon = currentPokemon {
                // Display the scrambled name
                Text("Scrambled Name: \(scrambledName)")
                    .font(.headline)
                    .padding()

                // User input field to guess the name
                TextField("Your Guess", text: $userGuess)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Submit Button
                Button(action: checkAnswer) {
                    Text("Check Answer")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                // Display feedback message
                if let isCorrect = isCorrect {
                    if isCorrect {
                        Text("Correct!")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else {
                        Text("Wrong! Try again.")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }

                // Retry Button
                Button(action: loadRandomPokemon) {
                    Text("Next Pokémon")
                        .font(.title2)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                await fetchPokemonsAndStartQuiz()
            }
        }
    }

    private func fetchPokemonsAndStartQuiz() async {
        do {
            pokemons = try await APIService.fetchPokemons()
            loadRandomPokemon()
        } catch {
            print("Failed to fetch pokemons: \(error)")
        }
    }

    private func loadRandomPokemon() {
        guard let randomPokemon = pokemons.randomElement() else { return }
        currentPokemon = randomPokemon
        scrambledName = scrambleName(randomPokemon.name)
        userGuess = ""
        isCorrect = nil
        quizMessage = "Try to unscramble the name!"
    }

    private func scrambleName(_ name: String) -> String {
        let nameArray = Array(name)
        let shuffledArray = nameArray.shuffled()
        return String(shuffledArray)
    }

    private func checkAnswer() {
        guard let currentPokemon = currentPokemon else { return }
        
        if userGuess.lowercased() == currentPokemon.name.lowercased() {
            isCorrect = true
            quizMessage = "Correct! Here's another one."
        } else {
            isCorrect = false
        }
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}
