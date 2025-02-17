import Foundation

struct APIService {
    static func fetchPokemons() async throws -> [Pokemon] {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        return decodedResponse.results.map { result in
            Pokemon(id: result.id, name: result.name, imageURL: result.imageURL, types: result.types, stats: result.stats)
        }
    }
}
