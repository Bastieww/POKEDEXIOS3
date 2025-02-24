import SwiftUI
import CoreData

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var isFavorite: Bool = false

    var body: some View {
        VStack {
            // Bouton de fermeture
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding()
                }
                Spacer()
            }

            // Image du Pokémon
            AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } placeholder: {
                ProgressView()
            }

            // Nom du Pokémon
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .padding()
                .foregroundColor(typeColor(pokemon.types.first ?? "Normal"))

            HStack {
                ForEach(pokemon.types, id: \.self) { type in
                    Text(type.capitalized)
                        .padding(8)
                        .background(typeColor(type))
                        .cornerRadius(8)
                        .foregroundColor(type == "normal" ? .black : .white) // Ensure visibility
                        .font(.headline)
                }
            }
            .padding()

            // Statistiques
            VStack(spacing: 8) {
                ForEach(pokemon.stats.keys.sorted(), id: \.self) { stat in
                    HStack {
                        Text(stat.capitalized)
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.primary)

                        GeometryReader { geometry in
                            let value = CGFloat(pokemon.stats[stat] ?? 0)
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 10)

                                RoundedRectangle(cornerRadius: 5)
                                    .fill(colorForStat(value))
                                    .frame(width: (value / 150) * geometry.size.width, height: 10)
                                    .animation(.easeInOut(duration: 0.5), value: value)
                            }
                        }
                        .frame(height: 10)

                        Text("\(pokemon.stats[stat] ?? 0)")
                            .frame(width: 50, alignment: .leading)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()

            // Bouton Favori
            Button(action: {
                withAnimation {
                    isFavorite.toggle()
                }
                saveFavorite()
            }) {
                HStack {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.white)
                    Text(isFavorite ? "Remove from Favorites" : "Add to Favorites")
                        .foregroundColor(.white)
                }
                .padding()
                .background(isFavorite ? Color.red : Color.blue)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            checkIfFavorite()
        }
    }

    // Vérifie si le Pokémon est déjà en favori
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

    // Sauvegarde l'état de favori
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

    // Couleurs pour les types de Pokémon
    private func typeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "fire": return .red
        case "water": return .blue
        case "grass": return .green
        case "electric": return .yellow
        case "psychic": return .purple
        case "ice": return .cyan
        case "dragon": return .orange
        case "dark": return .gray
        case "fairy": return .pink
        case "rock": return .brown
        case "ground": return .yellow
        case "poison": return .purple
        case "bug": return .green
        case "fighting": return .orange
        case "ghost": return .indigo
        case "steel": return .gray
        case "normal": return .white
        default: return .gray
        }
    }


    // Couleur pour les statistiques en fonction de leur valeur
    private func colorForStat(_ value: CGFloat) -> Color {
        let progress = value / 150
        return Color(
            red: 1.0 - progress,
            green: progress,
            blue: 0.0
        )
    }
}

// Extension pour utiliser des couleurs hexadécimales
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue >> 16) & 0xff) / 255.0
        let green = Double((rgbValue >> 8) & 0xff) / 255.0
        let blue = Double(rgbValue & 0xff) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
