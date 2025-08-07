//
//  PropertyAddress.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import CoreLocation
import MapKit

// MARK: - Property Address Model

struct PropertyAddress: Codable, Equatable, Hashable {
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    let coordinate: CLLocationCoordinate2D?
    
    // Optional additional fields
    let unitNumber: String?
    let buildingName: String?
    let neighborhood: String?
    let county: String?
    
    init(
        street: String,
        city: String,
        state: String,
        postalCode: String,
        country: String = "United States",
        coordinate: CLLocationCoordinate2D? = nil,
        unitNumber: String? = nil,
        buildingName: String? = nil,
        neighborhood: String? = nil,
        county: String? = nil
    ) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.coordinate = coordinate
        self.unitNumber = unitNumber
        self.buildingName = buildingName
        self.neighborhood = neighborhood
        self.county = county
    }
    
    // MARK: - Computed Properties
    
    var formattedAddress: String {
        var components: [String] = []
        
        // Add building name if available
        if let buildingName = buildingName, !buildingName.isEmpty {
            components.append(buildingName)
        }
        
        // Add street with unit number
        var streetComponent = street
        if let unitNumber = unitNumber, !unitNumber.isEmpty {
            streetComponent += " \(unitNumber)"
        }
        components.append(streetComponent)
        
        // Add city, state postal code
        components.append("\(city), \(state) \(postalCode)")
        
        // Add country if not US
        if country != "United States" && country != "US" {
            components.append(country)
        }
        
        return components.joined(separator: "\n")
    }
    
    var singleLineAddress: String {
        var components: [String] = []
        
        // Add building name if available
        if let buildingName = buildingName, !buildingName.isEmpty {
            components.append(buildingName)
        }
        
        // Add street with unit number
        var streetComponent = street
        if let unitNumber = unitNumber, !unitNumber.isEmpty {
            streetComponent += " \(unitNumber)"
        }
        components.append(streetComponent)
        
        // Add city, state postal code
        components.append("\(city), \(state) \(postalCode)")
        
        // Add country if not US
        if country != "United States" && country != "US" {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
    
    var shortAddress: String {
        var streetComponent = street
        if let unitNumber = unitNumber, !unitNumber.isEmpty {
            streetComponent += " \(unitNumber)"
        }
        return "\(streetComponent), \(city)"
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        return !street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               isValidPostalCode
    }
    
    var isValidPostalCode: Bool {
        let trimmedPostalCode = postalCode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // US postal code validation (5 digits or 5-4 format)
        if country == "United States" || country == "US" {
            let usPostalCodeRegex = "^[0-9]{5}(-[0-9]{4})?$"
            return NSPredicate(format: "SELF MATCHES %@", usPostalCodeRegex).evaluate(with: trimmedPostalCode)
        }
        
        // Basic validation for other countries (non-empty)
        return !trimmedPostalCode.isEmpty
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Street address is required")
        }
        
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("City is required")
        }
        
        if state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("State is required")
        }
        
        if postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Postal code is required")
        } else if !isValidPostalCode {
            errors.append("Postal code format is invalid")
        }
        
        return errors
    }
    
    // MARK: - Codable Conformance
    
    private enum CodingKeys: String, CodingKey {
        case street, city, state, postalCode, country
        case unitNumber, buildingName, neighborhood, county
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        street = try container.decode(String.self, forKey: .street)
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        postalCode = try container.decode(String.self, forKey: .postalCode)
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? "United States"
        
        unitNumber = try container.decodeIfPresent(String.self, forKey: .unitNumber)
        buildingName = try container.decodeIfPresent(String.self, forKey: .buildingName)
        neighborhood = try container.decodeIfPresent(String.self, forKey: .neighborhood)
        county = try container.decodeIfPresent(String.self, forKey: .county)
        
        // Decode coordinates if available
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(street, forKey: .street)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        
        try container.encodeIfPresent(unitNumber, forKey: .unitNumber)
        try container.encodeIfPresent(buildingName, forKey: .buildingName)
        try container.encodeIfPresent(neighborhood, forKey: .neighborhood)
        try container.encodeIfPresent(county, forKey: .county)
        
        // Encode coordinates if available
        if let coordinate = coordinate {
            try container.encode(coordinate.latitude, forKey: .latitude)
            try container.encode(coordinate.longitude, forKey: .longitude)
        }
    }
    
    // MARK: - Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(street)
        hasher.combine(city)
        hasher.combine(state)
        hasher.combine(postalCode)
        hasher.combine(country)
        hasher.combine(unitNumber)
        hasher.combine(buildingName)
    }
}

// MARK: - Factory Methods

extension PropertyAddress {
    
    static func fromMKPlacemark(_ placemark: MKPlacemark) -> PropertyAddress? {
        guard let street = placemark.thoroughfare,
              let city = placemark.locality,
              let state = placemark.administrativeArea,
              let postalCode = placemark.postalCode else {
            return nil
        }
        
        return PropertyAddress(
            street: street,
            city: city,
            state: state,
            postalCode: postalCode,
            country: placemark.country ?? "United States",
            coordinate: placemark.coordinate,
            unitNumber: placemark.subThoroughfare,
            buildingName: placemark.name,
            neighborhood: placemark.subLocality,
            county: placemark.subAdministrativeArea
        )
    }
    
    static func fromCLPlacemark(_ placemark: CLPlacemark) -> PropertyAddress? {
        guard let street = placemark.thoroughfare,
              let city = placemark.locality,
              let state = placemark.administrativeArea,
              let postalCode = placemark.postalCode else {
            return nil
        }
        
        return PropertyAddress(
            street: street,
            city: city,
            state: state,
            postalCode: postalCode,
            country: placemark.country ?? "United States",
            coordinate: placemark.location?.coordinate,
            unitNumber: placemark.subThoroughfare,
            buildingName: placemark.name,
            neighborhood: placemark.subLocality,
            county: placemark.subAdministrativeArea
        )
    }
}

// MARK: - Search and Geocoding Support

extension PropertyAddress {
    
    // Convert to MKMapItem for search and navigation
    func toMKMapItem() -> MKMapItem? {
        guard let coordinate = coordinate else { return nil }
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = buildingName ?? shortAddress
        return mapItem
    }
    
    // Geocode address string to get coordinates
    static func geocode(addressString: String) async throws -> PropertyAddress? {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(addressString)
        
        guard let placemark = placemarks.first else { return nil }
        return PropertyAddress.fromCLPlacemark(placemark)
    }
    
    // Reverse geocode coordinates to get address
    static func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> PropertyAddress? {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.first else { return nil }
        return PropertyAddress.fromCLPlacemark(placemark)
    }
}

// MARK: - Utility Extensions

extension PropertyAddress {
    
    // Calculate distance between two addresses
    func distance(to other: PropertyAddress) -> CLLocationDistance? {
        guard let coordinate1 = self.coordinate,
              let coordinate2 = other.coordinate else { return nil }
        
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        
        return location1.distance(from: location2)
    }
    
    // Check if address is in the same city
    func isSameCity(as other: PropertyAddress) -> Bool {
        return city.lowercased() == other.city.lowercased() &&
               state.lowercased() == other.state.lowercased() &&
               country.lowercased() == other.country.lowercased()
    }
    
    // Create a copy with updated coordinate
    func withCoordinate(_ coordinate: CLLocationCoordinate2D) -> PropertyAddress {
        return PropertyAddress(
            street: street,
            city: city,
            state: state,
            postalCode: postalCode,
            country: country,
            coordinate: coordinate,
            unitNumber: unitNumber,
            buildingName: buildingName,
            neighborhood: neighborhood,
            county: county
        )
    }
}