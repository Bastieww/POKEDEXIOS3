import SwiftUI

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
    }

    private func saveFavorite() {
        // Implémentez ici la logique Core Data pour ajouter aux favoris
    }
}

