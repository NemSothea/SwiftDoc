//
//  User.swift
//  Week03ExviewDidLoad
//
//  Created by sothea007 on 3/11/25.
//


// User Model matching JSONPlaceholder structure
struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let address: Address
    let company: Company
    
    struct Address: Codable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: Geo
        
        var formattedAddress: String {
            return "\(street), \(city), \(zipcode)"
        }
    }
    
    struct Geo: Codable {
        let lat: String
        let lng: String
    }
    
    struct Company: Codable {
        let name: String
        let catchPhrase: String
        let bs: String
    }
}
