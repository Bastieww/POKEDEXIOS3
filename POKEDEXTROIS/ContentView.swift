import SwiftUI

struct ContentView: View {
    @State private var pokemons: [Pokemon] = []
    @State private var filteredPokemons: [Pokemon] = []
    @State private var searchText: String = ""
    @State private var selectedType: String = "All"
    @State private var sortOption: SortOption = .alphabetical
    @State private var showDetail: Bool = false
    @State private var selectedPokemon: Pokemon?

    let types: [String] = ["All", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark", "Fairy", "Rock", "Ground", "Poison", "Bug", "Fighting", "Ghost", "Steel", "Normal"]

    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case highestAttack = "Highest Attack"
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search Pokémon...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { _ in filterPokemons() }

                // Filter and sort controls
                HStack {
                    // Type filter
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedType) { _ in filterPokemons() }

                    Spacer()

                    // Sort options
                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: sortOption) { _ in filterPokemons() }
                }
                .padding()

                // Pokémon list
                List(filteredPokemons) { pokemon in
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
                            filterPokemons()
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

    private func filterPokemons() {
        var result = pokemons

        // Filter by name
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        // Filter by type
        if selectedType != "All" {
            result = result.filter { $0.types.contains(selectedType.lowercased()) }
        }

        // Sort results
        switch sortOption {
        case .alphabetical:
            result.sort { $0.name < $1.name }
        case .highestAttack:
            result.sort { ($0.stats["attack"] ?? 0) > ($1.stats["attack"] ?? 0) }
        }

        filteredPokemons = result
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
