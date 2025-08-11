//
//  CoreDataSendable.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-11.
//

import Foundation

extension User: @unchecked Sendable {}
extension Property: @unchecked Sendable {}
extension Asset: @unchecked Sendable {}
extension AssetPhoto: @unchecked Sendable {}
extension MaintenanceTask: @unchecked Sendable {}
extension ServiceProvider: @unchecked Sendable {}