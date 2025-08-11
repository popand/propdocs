//
//  PropertyViewModel.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import Combine
import CoreLocation
import SwiftUI

extension AnyPublisher {
    func async() async throws -> Output {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

@MainActor
class PropertyViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var properties: [Property] = []
    @Published var activeProperty: Property?
    @Published var isLoading = false
    @Published var error: String?
    
    // Property creation/editing state
    @Published var isCreatingProperty = false
    @Published var isEditingProperty = false
    @Published var selectedProperty: Property?
    
    // Form state
    @Published var propertyName = ""
    @Published var selectedPropertyType: PropertyType = .house
    @Published var propertyAddress = ""
    @Published var addressComponents: PropertyAddress?
    
    // Search state
    @Published var searchQuery = ""
    @Published var searchResults: [Property] = []
    @Published var isSearching = false
    
    // Multi-property state
    @Published var isMultiPropertyMode = false
    @Published var propertyStatistics: PropertyStatistics?
    
    // Validation state
    @Published var nameValidationError: String?
    @Published var addressValidationError: String?
    @Published var formValidationError: String?
    
    // MARK: - Dependencies
    
    private let propertyRepository: PropertyRepositoryProtocol
    private let authenticationManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        propertyRepository: PropertyRepositoryProtocol = PropertyRepository(),
        authenticationManager: AuthenticationManager = AuthenticationManager.shared
    ) {
        self.propertyRepository = propertyRepository
        self.authenticationManager = authenticationManager
        
        setupBindings()
        loadProperties()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Observe authentication state changes
        authenticationManager.$authenticationStatus
            .sink { [weak self] status in
                if status.isAuthenticated {
                    self?.loadProperties()
                } else {
                    self?.clearData()
                }
            }
            .store(in: &cancellables)
        
        // Observe search query changes
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
        
        // Validate form fields
        $propertyName
            .map { [weak self] name in
                self?.validatePropertyName(name)
            }
            .assign(to: \.nameValidationError, on: self)
            .store(in: &cancellables)
        
        $propertyAddress
            .map { [weak self] address in
                self?.validateAddress(address)
            }
            .assign(to: \.addressValidationError, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadProperties() {
        guard let user = authenticationManager.getCoreDataUser() else {
            error = "User not authenticated"
            return
        }
        
        isLoading = true
        error = nil
        
        propertyRepository.fetchProperties(for: user)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] properties in
                    self?.properties = properties
                    self?.isMultiPropertyMode = properties.count > 1
                    self?.loadActiveProperty()
                    self?.loadStatistics()
                }
            )
            .store(in: &cancellables)
    }
    
    func loadActiveProperty() {
        guard let user = authenticationManager.getCoreDataUser() else { return }
        
        propertyRepository.getActiveProperty(for: user)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] property in
                    self?.activeProperty = property
                }
            )
            .store(in: &cancellables)
    }
    
    func setActiveProperty(_ property: Property) {
        guard let user = authenticationManager.getCoreDataUser() else { return }
        
        activeProperty = property
        
        propertyRepository.setActiveProperty(property, for: user)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = "Failed to set active property: \(error.localizedDescription)"
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Property Creation
    
    func startCreatingProperty() {
        clearForm()
        isCreatingProperty = true
    }
    
    func cancelCreatingProperty() {
        clearForm()
        isCreatingProperty = false
    }
    
    func createProperty() {
        guard let user = authenticationManager.getCoreDataUser() else {
            error = "User not authenticated"
            return
        }
        
        guard validateForm() else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                // Create property address from string
                let addressComponents = propertyAddress.components(separatedBy: ", ")
                let propertyAddressObj = PropertyAddress(
                    street: addressComponents.first ?? "",
                    city: addressComponents.count > 1 ? addressComponents[1] : "",
                    state: addressComponents.count > 2 ? addressComponents[2] : "",
                    postalCode: addressComponents.count > 3 ? addressComponents[3] : ""
                )
                
                let createData = CreatePropertyData(
                    name: propertyName,
                    address: propertyAddressObj,
                    propertyType: selectedPropertyType
                )
                
                let property = try await propertyRepository.createProperty(createData, for: user).async()
                
                await MainActor.run {
                    self.properties.append(property)
                    self.activeProperty = property
                    self.isCreatingProperty = false
                    self.isLoading = false
                    self.clearForm()
                    self.loadStatistics()
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Property Editing
    
    func startEditingProperty(_ property: Property) {
        selectedProperty = property
        propertyName = property.name ?? ""
        selectedPropertyType = property.propertyTypeEnum
        propertyAddress = property.address ?? ""
        addressComponents = property.addressComponents
        isEditingProperty = true
    }
    
    func cancelEditingProperty() {
        clearForm()
        selectedProperty = nil
        isEditingProperty = false
    }
    
    func updateProperty() {
        guard let property = selectedProperty else { return }
        guard validateForm() else { return }
        
        isLoading = true
        error = nil
        
        let updateData = UpdatePropertyData(
            name: propertyName,
            address: addressComponents,
            propertyType: selectedPropertyType
        )
        
        propertyRepository.updateProperty(property, with: updateData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedProperty in
                    if let index = self?.properties.firstIndex(where: { $0.id == updatedProperty.id }) {
                        self?.properties[index] = updatedProperty
                    }
                    if self?.activeProperty?.id == updatedProperty.id {
                        self?.activeProperty = updatedProperty
                    }
                    self?.isEditingProperty = false
                    self?.selectedProperty = nil
                    self?.clearForm()
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Property Deletion
    
    func deleteProperty(_ property: Property) {
        isLoading = true
        error = nil
        
        propertyRepository.deleteProperty(property)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.properties.removeAll { $0.id == property.id }
                    if self?.activeProperty?.id == property.id {
                        self?.activeProperty = self?.properties.first
                    }
                    self?.loadStatistics()
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Search
    
    private func performSearch(query: String) {
        guard !query.isEmpty, let user = authenticationManager.getCoreDataUser() else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        propertyRepository.searchProperties(query: query, for: user)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isSearching = false
                },
                receiveValue: { [weak self] results in
                    self?.searchResults = results
                }
            )
            .store(in: &cancellables)
    }
    
    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }
    
    // MARK: - Statistics
    
    private func loadStatistics() {
        guard authenticationManager.currentUser != nil else { return }
        
        // TODO: Implement getPropertyStatistics in repository protocol
        // propertyRepository.getPropertyStatistics(for: user)
        //     .receive(on: DispatchQueue.main)
        //     .sink(
        //         receiveCompletion: { _ in },
        //         receiveValue: { [weak self] statistics in
        //             self?.propertyStatistics = statistics
        //         }
        //     )
        //     .store(in: &cancellables)
    }
    
    // MARK: - Validation
    
    private func validatePropertyName(_ name: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return "Property name is required"
        }
        if trimmedName.count < 2 {
            return "Property name must be at least 2 characters"
        }
        if trimmedName.count > 100 {
            return "Property name must be less than 100 characters"
        }
        return nil
    }
    
    private func validateAddress(_ address: String) -> String? {
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedAddress.isEmpty {
            return "Address is required"
        }
        if trimmedAddress.count < 5 {
            return "Please enter a complete address"
        }
        return nil
    }
    
    private func validateForm() -> Bool {
        var hasErrors = false
        
        if let nameError = validatePropertyName(propertyName) {
            nameValidationError = nameError
            hasErrors = true
        }
        
        if let addressError = validateAddress(propertyAddress) {
            addressValidationError = addressError
            hasErrors = true
        }
        
        if hasErrors {
            formValidationError = "Please fix the errors above"
            return false
        }
        
        formValidationError = nil
        return true
    }
    
    // MARK: - Form Management
    
    private func clearForm() {
        propertyName = ""
        selectedPropertyType = .house
        propertyAddress = ""
        addressComponents = nil
        nameValidationError = nil
        addressValidationError = nil
        formValidationError = nil
    }
    
    private func clearData() {
        properties = []
        activeProperty = nil
        propertyStatistics = nil
        searchResults = []
        clearForm()
    }
    
    // MARK: - Utility Methods
    
    func clearError() {
        error = nil
    }
    
    func hasActiveProperty() -> Bool {
        return activeProperty != nil
    }
    
    func canDeleteProperty(_ property: Property) -> Bool {
        // Don't allow deletion if it's the only property and has assets
        if properties.count == 1 && property.assetCount > 0 {
            return false
        }
        return true
    }
    
    func getPropertyDisplayName(_ property: Property) -> String {
        return property.displayName
    }
    
    func getPropertyStats(_ property: Property) -> Property.PropertyStats {
        return property.stats
    }
    
    // MARK: - Geocoding Support
    
    func geocodeAddress(_ addressString: String) async {
        do {
            let geocodedAddress = try await PropertyAddress.geocode(addressString: addressString)
            await MainActor.run {
                self.addressComponents = geocodedAddress
            }
        } catch {
            await MainActor.run {
                self.addressValidationError = "Unable to verify address"
            }
        }
    }
}