//
//  PropertyType.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import SwiftUI

// MARK: - Property Type Enum

enum PropertyType: String, CaseIterable, Codable {
    case house = "house"
    case condo = "condo"
    case apartment = "apartment"
    case townhouse = "townhouse"
    case commercial = "commercial"
    case land = "land"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .house:
            return "House"
        case .condo:
            return "Condominium"
        case .apartment:
            return "Apartment"
        case .townhouse:
            return "Townhouse"
        case .commercial:
            return "Commercial"
        case .land:
            return "Land"
        case .other:
            return "Other"
        }
    }
    
    var description: String {
        switch self {
        case .house:
            return "Single-family house or detached home"
        case .condo:
            return "Condominium unit in a shared building"
        case .apartment:
            return "Apartment unit in a rental building"
        case .townhouse:
            return "Townhouse or row house"
        case .commercial:
            return "Commercial building or office space"
        case .land:
            return "Vacant land or lot"
        case .other:
            return "Other property type"
        }
    }
    
    var icon: String {
        switch self {
        case .house:
            return "house.fill"
        case .condo:
            return "building.2.fill"
        case .apartment:
            return "building.fill"
        case .townhouse:
            return "house.and.flag.fill"
        case .commercial:
            return "building.2.crop.circle.fill"
        case .land:
            return "tree.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .house:
            return .blue
        case .condo:
            return .green
        case .apartment:
            return .orange
        case .townhouse:
            return .purple
        case .commercial:
            return .gray
        case .land:
            return .brown
        case .other:
            return .secondary
        }
    }
    
    // Typical asset categories for this property type
    var commonAssetCategories: [String] {
        switch self {
        case .house, .townhouse:
            return ["HVAC", "Plumbing", "Electrical", "Roofing", "Flooring", "Windows", "Doors", "Appliances", "Landscaping", "Exterior"]
        case .condo, .apartment:
            return ["HVAC", "Plumbing", "Electrical", "Flooring", "Windows", "Doors", "Appliances", "Interior"]
        case .commercial:
            return ["HVAC", "Plumbing", "Electrical", "Security", "Elevators", "Fire Safety", "Parking", "Signage"]
        case .land:
            return ["Landscaping", "Fencing", "Utilities", "Drainage"]
        case .other:
            return ["General", "Utilities", "Structural"]
        }
    }
    
    // Typical maintenance intervals for this property type
    var maintenanceCategories: [String] {
        switch self {
        case .house, .townhouse:
            return ["Monthly", "Quarterly", "Semi-Annual", "Annual", "Bi-Annual"]
        case .condo, .apartment:
            return ["Monthly", "Quarterly", "Annual"]
        case .commercial:
            return ["Weekly", "Monthly", "Quarterly", "Annual"]
        case .land:
            return ["Seasonal", "Annual"]
        case .other:
            return ["Monthly", "Annual"]
        }
    }
}

// MARK: - Property Type Extensions

extension PropertyType {
    
    // Check if property type requires special permissions or considerations
    var requiresSpecialPermissions: Bool {
        switch self {
        case .commercial:
            return true
        case .land:
            return true
        default:
            return false
        }
    }
    
    // Get property type from string with fallback
    static func from(string: String?) -> PropertyType {
        guard let string = string?.lowercased(),
              let type = PropertyType(rawValue: string) else {
            return .other
        }
        return type
    }
    
    // Validation for property type selection
    var isSelectable: Bool {
        return true // All types are selectable for now
    }
    
    // Property type grouping for UI
    static var residentialTypes: [PropertyType] {
        return [.house, .condo, .apartment, .townhouse]
    }
    
    static var commercialTypes: [PropertyType] {
        return [.commercial]
    }
    
    static var otherTypes: [PropertyType] {
        return [.land, .other]
    }
    
    var category: PropertyTypeCategory {
        switch self {
        case .house, .condo, .apartment, .townhouse:
            return .residential
        case .commercial:
            return .commercial
        case .land, .other:
            return .other
        }
    }
}

// MARK: - Property Type Category

enum PropertyTypeCategory: String, CaseIterable {
    case residential = "residential"
    case commercial = "commercial"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .residential:
            return "Residential"
        case .commercial:
            return "Commercial"
        case .other:
            return "Other"
        }
    }
    
    var types: [PropertyType] {
        return PropertyType.allCases.filter { $0.category == self }
    }
}