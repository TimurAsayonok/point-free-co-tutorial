//
//  WolframAlpha.swift
//  StateManagment
//
//  Created by Timur Asayonok on 28/06/2022.
//

import Foundation

func ordinal(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: number) ?? ""
}

func isPrime(_ number: Int) -> Bool {
    if number <= 1 { return false }
    if number <= 3 { return true }
    for index in 2...Int(sqrtf(Float(number))) {
        if number % index == 0 { return false }
    }
    
    return true
}

struct WolframAlphaResponse: Decodable {
    let queryresult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPods]
            
            struct SubPods: Decodable {
                let plaintext: String
            }
        }
    }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResponse?) -> Void) -> Void {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: "6H69Q3-828TKQJ4EP")
    ]
    
    URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
        callback(data.flatMap{ try? JSONDecoder().decode(WolframAlphaResponse.self, from: $0) })
    }.resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
    wolframAlpha(query: "prime \(n)") { result in
        callback(
            result.flatMap{
                $0.queryresult
                    .pods
                    .first(where: { $0.primary == .some(true) })?
                    .subpods
                    .first?
                    .plaintext
            }
            .flatMap(Int.init)
        )
    }
}

struct PrimeValue: Identifiable {
    var id: Int { value }
    let value: Int
}
