import Foundation

struct Pokemon: Identifiable {
    var id: Int
    var name: String
    var imageURL: String
    var types: [String]
    var stats: [String: Int]
}

struct PokemonListResponse: Decodable {
    let results: [PokemonResult]
}

struct PokemonResult: Decodable {
    let name: String
    let url: String
    var id: Int {
        return Int(url.split(separator: "/").last ?? "0") ?? 0
    }
    var imageURL: String {
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
    }
    var types: [String] {
        // Implémentation à adapter avec les détails de l'API pour récupérer les types.
        return ["Normal"]
    }
    var stats: [String: Int] {
        // Implémentation à adapter avec les détails de l'API pour récupérer les stats.
        return ["HP": 50, "Attack": 60, "Defense": 55, "Speed": 40]
    }
}
