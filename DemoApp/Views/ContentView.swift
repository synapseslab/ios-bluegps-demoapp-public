//
//  ContentView.swift
//  DemoApp
//
//  Created by Costantino Pistagna on 02/02/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sdkViewModel: SDKViewModel

    @State private var showingMap = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                loginButton
                Spacer().frame(height: 20)
                createConfigButton
                Spacer().frame(height: 20)
                simpleMapButton
                Spacer().frame(height: 20)
                mapWithResourcesButton
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingMap) {
                VStack {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 60, height: 4, alignment: .center)
                        .foregroundStyle(.primary)
                        .padding(.top, 8)
                    MapView(url: "/api/public/resource/sdk/v1/mobile.html",
                            resources: sdkViewModel.resources
                    )
                }
                .ignoresSafeArea()
            }
            .navigationBarTitle("Sample App", displayMode: .inline)
        }
    }
}

extension ContentView {
    @ViewBuilder private var loginButton: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                if sdkViewModel.authenticated {
                    sdkViewModel.logout()
                } else {
                    sdkViewModel.guestLogin()
                }
            }, label: {
                HStack {
                    Image(systemName: sdkViewModel.authenticated ? "lock.icloud.fill" : "icloud.fill")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text(sdkViewModel.authenticated ? "Logout" : "Guest login")
                }
            })
            .padding()
            .frame(maxWidth: .infinity)
            .background(.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            Text(sdkViewModel.authenticated ? "Logged in" : "Not authenticated")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var createConfigButton: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                sdkViewModel.createConfig(tagId: "0123456789")
            }, label: {
                HStack {
                    Image(systemName: "wave.3.right.circle")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Create config")
                }
            })
            .padding()
            .frame(maxWidth: .infinity)
            .background(.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            Text(sdkViewModel.networkConfig?.iosadvConf.tagid != nil ?
                 "Tag \(sdkViewModel.networkConfig!.iosadvConf.tagid) is ready"
                 : "No tag configured")
            .font(.caption2).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var simpleMapButton: some View {
        VStack {
            Button(action: {
                showingMap.toggle()
            }, label: {
                HStack {
                    Image(systemName: "map")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Show map")
                }
            })
            .padding()
            .frame(maxWidth: .infinity)
            .background(.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
    }

    @ViewBuilder private var mapWithResourcesButton: some View {
        VStack {
            Button(action: {
                Task {
                    do {
                        let _ = try await sdkViewModel.simpleSearch()
                        showingMap.toggle()
                    } catch {
                        NSLog("\(error)")
                    }
                }
            }, label: {
                HStack {
                    Image(systemName: "map")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Show map with resources")
                }
            })
            .padding()
            .frame(maxWidth: .infinity)
            .background(.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
    }
}

struct PreviewContainer: View {
    @StateObject private var sdkViewModel = SDKViewModel()

    var body: some View {
        ContentView()
            .onAppear {
                sdkViewModel.commonInit()
            }
            .environmentObject(sdkViewModel)
    }
}

#Preview {
    PreviewContainer()
}
