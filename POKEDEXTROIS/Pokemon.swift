import Foundation

struct Pokemon: Identifiable {
    var id: Int
    var name: String
    var imageURL: String
    var types: [String]
    var stats: [String: Int]
}

struct PokemonListResponse: Decodable {
    let results: [PokemonListEntry]
}

struct PokemonListEntry: Decodable {
    let name: String
    let url: String
}

struct PokemonDetailResponse: Decodable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let stats: [PokemonStatEntry]
}

struct PokemonTypeEntry: Decodable {
    let type: PokemonType
}

struct PokemonType: Decodable {
    let name: String
}

struct PokemonStatEntry: Decodable {
    let base_stat: Int
    let stat: PokemonStat
}

struct PokemonStat: Decodable {
    let name: String
}
