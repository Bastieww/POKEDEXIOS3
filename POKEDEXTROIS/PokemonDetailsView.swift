import SwiftUI
import CoreData

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite: Bool = false

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                image.resizable().scaledToFit().frame(height: 200)
            } placeholder: {
                ProgressView()
            }
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .padding()

            Text("Types: \(pokemon.types.joined(separator: ", "))")
                .padding()

            ForEach(pokemon.stats.keys.sorted(), id: \.self) { stat in
                Text("\(stat.capitalized): \(pokemon.stats[stat] ?? 0)")
            }

            Button(action: {
                isFavorite.toggle()
                saveFavorite()
            }) {
                Text(isFavorite ? "Remove from Favorites" : "Add to Favorites")
                    .foregroundColor(.white)
                    .padding()
                    .background(isFavorite ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            checkIfFavorite()
        }
    }

    private func checkIfFavorite() {
        let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)

        do {
            if let result = try viewContext.fetch(fetchRequest).first {
                isFavorite = result.isFavorite
            }
        } catch {
            print("Failed to fetch favorite status: \(error)")
        }
    }

    private func saveFavorite() {
        let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)

        do {
            let results = try viewContext.fetch(fetchRequest)
            if let pokemonEntity = results.first {
                pokemonEntity.isFavorite = isFavorite
            } else {
                let newPokemonEntity = PokemonEntity(context: viewContext)
                newPokemonEntity.name = pokemon.name
                newPokemonEntity.imageURL = pokemon.imageURL
                newPokemonEntity.types = pokemon.types as NSObject
                newPokemonEntity.stats = pokemon.stats as NSObject
                newPokemonEntity.isFavorite = isFavorite
            }
            try viewContext.save()
        } catch {
            print("Failed to save favorite status: \(error)")
        }
    }
}
