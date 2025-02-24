import Foundation

struct APIService {
    static func fetchPokemons() async throws -> [Pokemon] {
        let listURL = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100")!
        let (data, _) = try await URLSession.shared.data(from: listURL)
        let decodedListResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)

        var pokemons = [Pokemon]()

        for entry in decodedListResponse.results {
            let detailURL = URL(string: entry.url)!
            let (detailData, _) = try await URLSession.shared.data(from: detailURL)
            let decodedDetailResponse = try JSONDecoder().decode(PokemonDetailResponse.self, from: detailData)

            let types = decodedDetailResponse.types.map { $0.type.name }
            var stats = [String: Int]()
            for stat in decodedDetailResponse.stats {
                stats[stat.stat.name] = stat.base_stat
            }

            let pokemon = Pokemon(
                id: decodedDetailResponse.id,
                name: decodedDetailResponse.name,
                imageURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(decodedDetailResponse.id).png",
                types: types,
                stats: stats
            )

            pokemons.append(pokemon)
        }

        return pokemons
    }
}
