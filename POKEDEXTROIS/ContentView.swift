import SwiftUI

struct ContentView: View {
    @State private var pokemons: [Pokemon] = []
    @State private var showDetail: Bool = false
    @State private var selectedPokemon: Pokemon?

    var body: some View {
        NavigationView {
            List(pokemons) { pokemon in
                HStack {
                    AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                        image.resizable().scaledToFit().frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                    Text(pokemon.name.capitalized)
                        .onTapGesture {
                            selectedPokemon = pokemon
                            showDetail.toggle()
                        }
                }
            }
            .navigationTitle("Pokémons")
            .onAppear {
                Task {
                    do {
                        pokemons = try await APIService.fetchPokemons()
                    } catch {
                        print("Failed to fetch pokemons: \(error)")
                    }
                }
            }
            .sheet(isPresented: $showDetail) {
                if let pokemon = selectedPokemon {
                    PokemonDetailView(pokemon: pokemon)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
