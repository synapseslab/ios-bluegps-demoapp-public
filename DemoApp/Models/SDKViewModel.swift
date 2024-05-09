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
    @Published var debugLog: String = ""
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

                _ = try await BlueGPS.shared.networkSetup()
                debugLog.append("\nSDK Initialized successfully")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func login() {
        Task {
            do {
                _ = try await BlueGPS.shared.keycloakLogin()
                authenticated = true
                debugLog.append("\nUser logged successfully")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func backgroundLogin() {
        Task {
            do {
                _ = try await BlueGPS.shared.backgroundLogin(username: "testuser", password: "testUser#2023!")
                authenticated = true
                debugLog.append("\nUser logged successfully")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func guestLogin() {
        Task {
            do {
                _ = try await BlueGPS.shared.keycloakGuestLogin()
                authenticated = true
                debugLog.append("\nGuest logged successfully")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func logout() {
        KeycloakManager.shared?.logout() { [weak self] _, error in
            if let error {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self?.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self?.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            } else {
                self?.authenticated = false
                self?.debugLog.append("\nLogout completed successfully")
            }
        }
    }

    func createConfig(tagId: String) {
        Task {
            do {
                networkConfig = try await BlueGPS.shared.getOrCreateConfiguration(tagid: tagId)
                debugLog.append("GetOrCreateConfiguration completed successfully.\nTagid: \(networkConfig?.iosadvConf.tagid ?? "n/a")")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func createBooking() {
        Task {
            do {
                // create a schedule request according to your resource
                let scheduleRequest = ScheduleRequest(
                    elementId: "your.resource.id.goes.here",
                    elementType: ResourceType.ROOM,
                    meetingName: "meetingName",
                    meetingNote: "meetingDescription",
                    dayStart: "2024-05-09",
                    start: "11:00",
                    end: "12:00")
                let response = try await BlueGPS.shared.schedule(scheduleRequest)
                debugLog.append("\nBooking completed: \(response.bookingId ?? "n/a")")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func fetchAgenda() {
        Task {
            do {
                let response = try await BlueGPS.shared.getAgendaMy(dateStart: nil, dateEnd: nil)
                debugLog.append("\ngetAgendaMy: \(response)")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func deleteBooking() {
        Task {
            do {
                _ = try await BlueGPS.shared.deleteSchedule(resourceId: "your.booking.id.goes.here")
                self.debugLog.append(contentsOf: "\nBooking successfully deleted.")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
            }
        }
    }

    func getConfig() {
        Task {
            do {
                networkConfig = try await BlueGPS.shared.getOrCreateConfiguration()
                debugLog.append("GetOrCreateConfiguration completed successfully.\nTagid: \(networkConfig?.iosadvConf.tagid ?? "n/a")")
            } catch {
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
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
                NSLog(error.localizedDescription)
                if let error = error as? APIError {
                    self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
                } else {
                    self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
                }
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
            NSLog(error.localizedDescription)
            if let error = error as? APIError {
                self.debugLog.append(contentsOf: "\n\(error.responseMessage.trace ?? error.localizedDescription)")
            } else {
                self.debugLog.append(contentsOf: "\n\(error.localizedDescription)")
            }
            throw error
        }
    }
}
