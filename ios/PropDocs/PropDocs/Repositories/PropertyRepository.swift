//
//  PropertyRepository.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import CoreData
import Combine

// MARK: - Property Repository Protocol

protocol PropertyRepositoryProtocol {
    func fetchProperties(for user: User) -> AnyPublisher<[Property], Error>
    func fetchProperty(by id: UUID) -> AnyPublisher<Property?, Error>
    func createProperty(_ propertyData: CreatePropertyData, for user: User) -> AnyPublisher<Property, Error>
    func updateProperty(_ property: Property, with data: UpdatePropertyData) -> AnyPublisher<Property, Error>
    func deleteProperty(_ property: Property) -> AnyPublisher<Void, Error>
    func searchProperties(query: String, for user: User) -> AnyPublisher<[Property], Error>
    func getPropertiesNeedingSync(for user: User) -> AnyPublisher<[Property], Error>
    func markPropertyAsSynced(_ property: Property) -> AnyPublisher<Property, Error>
    func setActiveProperty(_ property: Property?, for user: User) -> AnyPublisher<Void, Error>
    func getActiveProperty(for user: User) -> AnyPublisher<Property?, Error>
}

// MARK: - Property Data Transfer Objects

struct CreatePropertyData {
    let name: String
    let address: PropertyAddress
    let propertyType: PropertyType
}

struct UpdatePropertyData {
    let name: String?
    let address: PropertyAddress?
    let propertyType: PropertyType?
}

// MARK: - Property Repository Implementation

class PropertyRepository: PropertyRepositoryProtocol {
    
    private let coreDataStack: CoreDataStack
    private let context: NSManagedObjectContext
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
        self.context = coreDataStack.mainContext
    }
    
    // MARK: - Fetch Operations
    
    func fetchProperties(for user: User) -> AnyPublisher<[Property], Error> {
        return Future { promise in
            self.context.perform {
                do {
                    let request = Property.fetchRequestForUser(user)
                    let properties = try self.context.fetch(request)
                    promise(.success(properties))
                } catch {
                    promise(.failure(PropertyRepositoryError.fetchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchProperty(by id: UUID) -> AnyPublisher<Property?, Error> {
        return Future { promise in
            self.context.perform {
                do {
                    let request = Property.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    request.fetchLimit = 1
                    
                    let properties = try self.context.fetch(request)
                    promise(.success(properties.first))
                } catch {
                    promise(.failure(PropertyRepositoryError.fetchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Create Operations
    
    func createProperty(_ propertyData: CreatePropertyData, for user: User) -> AnyPublisher<Property, Error> {
        return Future { promise in
            self.context.perform {
                do {
                    // Validate input data
                    guard self.validateCreatePropertyData(propertyData) else {
                        promise(.failure(PropertyRepositoryError.invalidData))
                        return
                    }
                    
                    let property = Property.create(
                        in: self.context,
                        name: propertyData.name,
                        address: propertyData.address,
                        propertyType: propertyData.propertyType,
                        user: user
                    )
                    
                    try self.context.save()
                    promise(.success(property))
                } catch {
                    promise(.failure(PropertyRepositoryError.createFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Update Operations
    
    func updateProperty(_ property: Property, with data: UpdatePropertyData) -> AnyPublisher<Property, Error> {
        return Future { promise in
            self.context.perform {
                do {
                    // Update name if provided
                    if let name = data.name {
                        property.name = name
                    }
                    
                    // Update address if provided
                    if let address = data.address {
                        property.addressComponents = address
                    }
                    
                    // Update property type if provided
                    if let propertyType = data.propertyType {
                        property.propertyTypeEnum = propertyType
                    }
                    
                    property.markAsNeedingSync()
                    
                    try self.context.save()
                    promise(.success(property))
                } catch {
                    promise(.failure(PropertyRepositoryError.updateFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Delete Operations
    
    func deleteProperty(_ property: Property) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.context.perform {
                do {
                    self.context.delete(property)
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(PropertyRepositoryError.deleteFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Search Operations
    
    func searchProperties(query: String, for user: User) -> AnyPublisher<[Property], Error> {
        return Future { promise in
            self.context.perform {
                do {
                    let request = Property.searchRequest(query: query)
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        request.predicate!,
                        NSPredicate(format: "user == %@", user)
                    ])
                    
                    let properties = try self.context.fetch(request)
                    promise(.success(properties))
                } catch {
                    promise(.failure(PropertyRepositoryError.searchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Sync Operations
    
    func getPropertiesNeedingSync(for user: User) -> AnyPublisher<[Property], Error> {
        return Future { promise in
            self.context.perform {
                do {
                    let request = Property.fetchRequest()
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        NSPredicate(format: "user == %@", user),
                        NSPredicate(format: "syncStatus == %@ OR syncStatus == %@", 
                                   SyncStatus.pending.rawValue, 
                                   SyncStatus.failed.rawValue)
                    ])
                    request.sortDescriptors = [
                        NSSortDescriptor(keyPath: \Property.updatedAt, ascending: false)
                    ]
                    
                    let properties = try self.context.fetch(request)
                    promise(.success(properties))
                } catch {
                    promise(.failure(PropertyRepositoryError.fetchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func markPropertyAsSynced(_ property: Property) -> AnyPublisher<Property, Error> {
        return Future { promise in
            self.context.perform {
                do {
                    property.syncStatusEnum = .synced
                    try self.context.save()
                    promise(.success(property))
                } catch {
                    promise(.failure(PropertyRepositoryError.updateFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Active Property Management
    
    func setActiveProperty(_ property: Property?, for user: User) -> AnyPublisher<Void, Error> {
        return Future { promise in
            UserDefaults.standard.set(property?.id?.uuidString, forKey: "activePropertyId_\(user.id?.uuidString ?? "")")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func getActiveProperty(for user: User) -> AnyPublisher<Property?, Error> {
        return Future { promise in
            self.context.perform {
                do {
                    guard let activePropertyIdString = UserDefaults.standard.string(forKey: "activePropertyId_\(user.id?.uuidString ?? "")"),
                          let activePropertyId = UUID(uuidString: activePropertyIdString) else {
                        // No active property set, return the first property if available
                        let request = Property.fetchRequestForUser(user)
                        request.fetchLimit = 1
                        let properties = try self.context.fetch(request)
                        promise(.success(properties.first))
                        return
                    }
                    
                    let request = Property.fetchRequest()
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        NSPredicate(format: "user == %@", user),
                        NSPredicate(format: "id == %@", activePropertyId as CVarArg)
                    ])
                    request.fetchLimit = 1
                    
                    let properties = try self.context.fetch(request)
                    promise(.success(properties.first))
                } catch {
                    promise(.failure(PropertyRepositoryError.fetchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Validation
    
    private func validateCreatePropertyData(_ data: CreatePropertyData) -> Bool {
        guard !data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        guard data.address.isValid else {
            return false
        }
        
        return true
    }
}

// MARK: - Repository Errors

enum PropertyRepositoryError: Error, LocalizedError {
    case fetchFailed(Error)
    case createFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
    case searchFailed(Error)
    case invalidData
    case propertyNotFound
    case userNotFound
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch properties: \(error.localizedDescription)"
        case .createFailed(let error):
            return "Failed to create property: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update property: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete property: \(error.localizedDescription)"
        case .searchFailed(let error):
            return "Failed to search properties: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid property data provided"
        case .propertyNotFound:
            return "Property not found"
        case .userNotFound:
            return "User not found"
        case .timeout:
            return "Operation timed out"
        }
    }
}

// MARK: - Property Repository Extensions

extension PropertyRepository {
    
    // Convenience method for creating property with address string
    func createProperty(
        name: String,
        addressString: String,
        propertyType: PropertyType,
        for user: User
    ) async throws -> Property {
        
        // Try to geocode the address string
        let address: PropertyAddress
        if let geocodedAddress = try await PropertyAddress.geocode(addressString: addressString) {
            address = geocodedAddress
        } else {
            // Fallback to basic parsing
            let components = addressString.components(separatedBy: ", ")
            guard components.count >= 3 else {
                throw PropertyRepositoryError.invalidData
            }
            
            let street = components[0]
            let city = components[1]
            let stateZip = components[2].components(separatedBy: " ")
            guard stateZip.count >= 2 else {
                throw PropertyRepositoryError.invalidData
            }
            
            let state = stateZip[0]
            let postalCode = stateZip.dropFirst().joined(separator: " ")
            
            address = PropertyAddress(
                street: street,
                city: city,
                state: state,
                postalCode: postalCode
            )
        }
        
        let createData = CreatePropertyData(
            name: name,
            address: address,
            propertyType: propertyType
        )
        
        return try await createProperty(createData, for: user)
            .async()
    }
    
    // Get property statistics
    func getPropertyStatistics(for user: User) -> AnyPublisher<PropertyStatistics, Error> {
        return fetchProperties(for: user)
            .map { properties in
                PropertyStatistics(
                    totalProperties: properties.count,
                    propertiesByType: Dictionary(grouping: properties) { $0.propertyTypeEnum },
                    totalAssets: properties.reduce(0) { $0 + $1.assetCount },
                    activeMaintenanceTasks: properties.reduce(0) { $0 + $1.activeMaintenanceTaskCount }
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Property Statistics

struct PropertyStatistics {
    let totalProperties: Int
    let propertiesByType: [PropertyType: [Property]]
    let totalAssets: Int
    let activeMaintenanceTasks: Int
    
    var mostCommonPropertyType: PropertyType? {
        return propertiesByType.max(by: { $0.value.count < $1.value.count })?.key
    }
}

// MARK: - Publisher Extension for Async/Await

extension Publisher where Failure == Error {
    func async() async throws -> Output {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = first()
                .timeout(.seconds(30), scheduler: DispatchQueue.global()) {
                    PropertyRepositoryError.timeout
                }
                .sink(
                    receiveCompletion: { completion in
                        defer { cancellable = nil }
                        switch completion {
                        case .finished: break
                        case .failure(let error): 
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { value in
                        defer { cancellable = nil }
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}