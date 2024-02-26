//
//  SDKViewModel.swift
//  DemoApp
//
//  Created by Costantino Pistagna on 02/02/24.
//

import SwiftUI
import SynapsesSDK

@MainActor
class SDKViewModel: ObservableObject {
    @Published var authenticated: Bool = false
    @Published var error: Error?
    @Published var networkConfig: NetworkResponseConfiguration?
    @Published var isAdvertising: Bool = false
    @Published var advertisingError: String?
    @Published var searchError: String?
    @Published var resources: [Resource]?
    @Published var locatingEnabled: Bool = false
    @Published var locatingError: String?

    func commonInit() {
        Task.init { // init SynapsesSDK
            do {
                let authEnv = KeycloakEnvironment(authMethod: .CUSTOM,
                                                  loginMode: .USER,
                                                  clientId: "your.client.goes.here",
                                                  guestClientId: "your.client.goes.here",
                                                  guestSecretKey: "your.secret.goes.here",
                                                  redirectURI: "yourschema://your.redirect.uri",
                                                  discoverURL: "https://your.keycloak.discovery.url")

                BlueGPS.setupSDK(EnvironmentModel(endpoint: "https://your.default.url/",
                                                  keycloakEnv: authEnv))

                let _ = try await BlueGPS.shared.networkSetup()
            } catch {
                NSLog("\(error)")
            }
        }
    }

    func login() {
        Task {
            do {
                let _ = try await BlueGPS.shared.keycloakLogin()
                authenticated = true
            } catch {
                self.error = error
                NSLog(error.localizedDescription)
            }
        }
    }

    func guestLogin() {
        Task {
            do {
                let _ = try await BlueGPS.shared.keycloakGuestLogin()
                authenticated = true
            } catch {
                self.error = error
                NSLog(error.localizedDescription)
            }
        }
    }

    func logout() {
        KeycloakManager.shared?.logout() { [weak self] _, error in
            if let error {
                self?.error = error
                NSLog(error.localizedDescription)
            } else {
                self?.authenticated = false
            }
        }
    }

    func createConfig(tagId: String) {
        Task {
            do {
                networkConfig = try await BlueGPS.shared.getOrCreateConfiguration(tagid: tagId)
            } catch {
                self.error = error
                NSLog("\(error.localizedDescription)")
            }
        }
    }

    func getConfig() {
        Task {
            do {
                networkConfig = try await BlueGPS.shared.getOrCreateConfiguration()
            } catch {
                self.error = error
                NSLog("\(error.localizedDescription)")
            }
        }
    }

    func startAdvertising() {
        Task {
            do {
                if let configuration = self.networkConfig?.iosadvConf {
                    let _ = try await BlueGPS.shared.startAdvertisingRegion(with: configuration)
                    isAdvertising = true
                }
            } catch {
                if let apiError = error as? APIError {
                    self.advertisingError = apiError.localizedDescription
                } else {
                    self.advertisingError = error.localizedDescription
                }
                isAdvertising = false
            }
        }
    }

    func stopAdvertising() {
        BlueGPS.shared.stopAdvertisingRegion()
        isAdvertising = false
    }

    func simpleSearch(text: String? = nil, nearMe: Bool = false) async throws -> [Resource]? {
        do {
            var filter = try await BlueGPS.shared.getFilters(.SEARCH)

            filter.search = text

            if nearMe,
               let orderByFilterIndex = filter.filters?.firstIndex(where: { $0.filterId == "orderById"}),
               var orderByFilter = filter.filters?[orderByFilterIndex],
               var payload = orderByFilter.value?.value as? [[String: Any]]
            {
                for (index, var dictionary) in payload.enumerated() {
                    dictionary["value"] = false
                    payload[index] = dictionary
                }

                for (index, var dictionary) in payload.enumerated() {
                    for (key, value) in dictionary {
                        if key == "id",
                           let value = value as? String,
                           value == "filter-near-to-me"
                        {
                            dictionary["value"] = true
                        }
                    }
                    payload[index] = dictionary
                }
                orderByFilter.value?.value = payload
                filter.filters?[orderByFilterIndex] = orderByFilter
            }

            resources = try await BlueGPS.shared.search(filter)
            return resources
        } catch {
            if let apiError = error as? APIError {
                self.searchError = apiError.localizedDescription
            } else {
                self.searchError = error.localizedDescription
            }
            throw error
        }
    }
}
