import SwiftUI
import UserNotifications

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
                TextField("Search Pokémon...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { _ in filterPokemons() }

                HStack {
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedType) { _ in filterPokemons() }

                    Spacer()

                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: sortOption) { _ in filterPokemons() }
                }
                .padding()

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
                .sheet(isPresented: Binding(get: { showDetail }, set: { showDetail = $0 })) {
                    if let pokemon = selectedPokemon {
                        PokemonDetailView(pokemon: pokemon, allPokemons: pokemons)
                    }
                }
            }
        }
    }

    private func filterPokemons() {
        var result = pokemons

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        if selectedType != "All" {
            result = result.filter { $0.types.contains(selectedType.lowercased()) }
        }

        switch sortOption {
        case .alphabetical:
            result.sort { $0.name < $1.name }
        case .highestAttack:
            result.sort { ($0.stats["attack"] ?? 0) > ($1.stats["attack"] ?? 0) }
        }

        filteredPokemons = result
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }
}
