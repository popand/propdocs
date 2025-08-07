//
//  Property.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import CoreData
import CoreLocation

// MARK: - Property Core Data Extensions

extension Property {
    
    // MARK: - Computed Properties
    
    var propertyTypeEnum: PropertyType {
        get {
            return PropertyType.from(string: propertyType)
        }
        set {
            propertyType = newValue.rawValue
        }
    }
    
    var coordinate: CLLocationCoordinate2D? {
        get {
            guard latitude != 0 || longitude != 0 else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            if let coordinate = newValue {
                latitude = coordinate.latitude
                longitude = coordinate.longitude
            } else {
                latitude = 0
                longitude = 0
            }
        }
    }
    
    var addressComponents: PropertyAddress? {
        get {
            guard let address = address, !address.isEmpty else { return nil }
            
            // Try to parse existing address string into components
            // This is a basic implementation - in a real app you might store components separately
            let components = address.components(separatedBy: ", ")
            guard components.count >= 3 else { return nil }
            
            let street = components[0]
            let city = components[1]
            let stateZip = components[2].components(separatedBy: " ")
            guard stateZip.count >= 2 else { return nil }
            
            let state = stateZip[0]
            let postalCode = stateZip[1]
            
            return PropertyAddress(
                street: street,
                city: city,
                state: state,
                postalCode: postalCode,
                coordinate: coordinate
            )
        }
        set {
            if let addressComponents = newValue {
                address = addressComponents.singleLineAddress
                coordinate = addressComponents.coordinate
            } else {
                address = nil
                coordinate = nil
            }
        }
    }
    
    var syncStatusEnum: SyncStatus {
        get {
            return SyncStatus(rawValue: syncStatus ?? "pending") ?? .pending
        }
        set {
            syncStatus = newValue.rawValue
        }
    }
    
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        } else if let address = address, !address.isEmpty {
            return address
        } else {
            return "Unnamed Property"
        }
    }
    
    var assetCount: Int {
        return assets?.count ?? 0
    }
    
    var activeMaintenanceTaskCount: Int {
        let activeTasks = maintenanceTasks?.filter { task in
            if let maintenanceTask = task as? MaintenanceTask {
                return maintenanceTask.status != "completed"
            }
            return false
        }
        return activeTasks?.count ?? 0
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        return !displayName.isEmpty && propertyTypeEnum != .other
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if name?.isEmpty ?? true {
            errors.append("Property name is required")
        }
        
        if address?.isEmpty ?? true {
            errors.append("Property address is required")
        }
        
        if propertyType?.isEmpty ?? true {
            errors.append("Property type is required")
        }
        
        return errors
    }
    
    // MARK: - Factory Methods
    
    static func create(
        in context: NSManagedObjectContext,
        name: String,
        address: PropertyAddress,
        propertyType: PropertyType,
        user: User
    ) -> Property {
        let property = Property(context: context)
        property.id = UUID()
        property.name = name
        property.addressComponents = address
        property.propertyTypeEnum = propertyType
        property.user = user
        property.createdAt = Date()
        property.updatedAt = Date()
        property.syncStatusEnum = .pending
        
        return property
    }
    
    // MARK: - Update Methods
    
    func updateBasicInfo(name: String, propertyType: PropertyType) {
        self.name = name
        self.propertyTypeEnum = propertyType
        self.updatedAt = Date()
        self.syncStatusEnum = .pending
    }
    
    func updateAddress(_ address: PropertyAddress) {
        self.addressComponents = address
        self.updatedAt = Date()
        self.syncStatusEnum = .pending
    }
    
    func markAsNeedingSync() {
        self.updatedAt = Date()
        self.syncStatusEnum = .pending
    }
    
    // MARK: - Asset Management
    
    func addAsset(_ asset: Asset) {
        asset.property = self
        self.markAsNeedingSync()
    }
    
    func removeAsset(_ asset: Asset) {
        asset.property = nil
        self.markAsNeedingSync()
    }
    
    // MARK: - Maintenance Task Management
    
    func addMaintenanceTask(_ task: MaintenanceTask) {
        task.property = self
        self.markAsNeedingSync()
    }
    
    func removeMaintenanceTask(_ task: MaintenanceTask) {
        task.property = nil
        self.markAsNeedingSync()
    }
}

// MARK: - Sync Status Enum

enum SyncStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case syncing = "syncing"
    case synced = "synced"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending Sync"
        case .syncing:
            return "Syncing"
        case .synced:
            return "Synced"
        case .failed:
            return "Sync Failed"
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock"
        case .syncing:
            return "arrow.clockwise"
        case .synced:
            return "checkmark.circle"
        case .failed:
            return "exclamationmark.triangle"
        }
    }
    
    var needsSync: Bool {
        return self == .pending || self == .failed
    }
}

// MARK: - Property Fetch Requests

extension Property {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Property> {
        return NSFetchRequest<Property>(entityName: "Property")
    }
    
    static func fetchRequestForUser(_ user: User) -> NSFetchRequest<Property> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Property.name, ascending: true)
        ]
        return request
    }
    
    static func fetchRequestForSyncStatus(_ status: SyncStatus) -> NSFetchRequest<Property> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "syncStatus == %@", status.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Property.updatedAt, ascending: false)
        ]
        return request
    }
    
    static func fetchRequestForPropertyType(_ type: PropertyType) -> NSFetchRequest<Property> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "propertyType == %@", type.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Property.name, ascending: true)
        ]
        return request
    }
    
    static func searchRequest(query: String) -> NSFetchRequest<Property> {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "name CONTAINS[cd] %@ OR address CONTAINS[cd] %@",
            query, query
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Property.name, ascending: true)
        ]
        return request
    }
}

// MARK: - Property Statistics

extension Property {
    
    struct PropertyStats {
        let totalAssets: Int
        let totalMaintenanceTasks: Int
        let activeMaintenanceTasks: Int
        let overdueTasks: Int
        let lastMaintenanceDate: Date?
        let nextMaintenanceDate: Date?
    }
    
    var stats: PropertyStats {
        let totalAssets = assets?.count ?? 0
        let allTasks = maintenanceTasks?.compactMap { $0 as? MaintenanceTask } ?? []
        let totalMaintenanceTasks = allTasks.count
        let activeTasks = allTasks.filter { $0.status != "completed" }
        let activeMaintenanceTasks = activeTasks.count
        
        let now = Date()
        let overdueTasks = activeTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < now
        }.count
        
        let completedTasks = allTasks.filter { $0.status == "completed" }
        let lastMaintenanceDate = completedTasks
            .compactMap { $0.completedAt }
            .max()
        
        let nextMaintenanceDate = activeTasks
            .compactMap { $0.dueDate }
            .min()
        
        return PropertyStats(
            totalAssets: totalAssets,
            totalMaintenanceTasks: totalMaintenanceTasks,
            activeMaintenanceTasks: activeMaintenanceTasks,
            overdueTasks: overdueTasks,
            lastMaintenanceDate: lastMaintenanceDate,
            nextMaintenanceDate: nextMaintenanceDate
        )
    }
}