//
//  MapView.swift
//  DemoApp
//
//  Created by Costantino Pistagna on 02/02/24.
//

import SwiftUI
import SynapsesSDK

struct MapView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    private let dynamicMap = DynamicMapView(frame: .zero)
    private let mapDelegate = MapViewDelegate()
    private var url: String
    private var toolbox = ToolboxModel()
    private var showModel = ShowModel(me: true, all: true, room: true, park: false, desk: false)
    private var configuration: ConfigurationModel
    private let resources: [Resource]?
    private let genericResource: GenericResourceModel?

    init(url: String,
         configuration: ConfigurationModel? = nil,
         showModel: ShowModel? = nil,
         toolbox: ToolboxModel? = nil,
         resources: [Resource]? = nil,
         genericResource: GenericResourceModel? = nil
    ) {
        self.url = url
        self.resources = resources
        self.genericResource = genericResource

        if let showModel {
            self.showModel = showModel
        }
        if let toolbox {
            self.toolbox = toolbox
        }
        if let configuration {
            self.configuration = configuration
        } else {
            self.configuration = ConfigurationModel(tagid: "FOO",
                                                    toolbox: self.toolbox,
                                                    show: self.showModel)
        }
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        dynamicMap.delegate = mapDelegate
        mapDelegate.resources = resources
        mapDelegate.genericResource = genericResource
        
        Task {
            do {
                let payload = try await BlueGPS.shared.getOrCreateConfiguration()
                let newConfiguration = ConfigurationModel(tagid: payload.iosadvConf.tagid,
                                                          style: self.configuration.style,
                                                          toolbox: self.configuration.toolbox,
                                                          show: self.configuration.show,
                                                          callbackType: self.configuration.callbackType,
                                                          visualization: self.configuration.visualization,
                                                          customOption: self.configuration.customOption)
                dynamicMap.load(url, configuration: newConfiguration)
            } catch {
                dynamicMap.load(url, configuration: configuration)
            }
        }

        viewController.view = UIView()
        viewController.view.addSubview(dynamicMap)

        dynamicMap.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dynamicMap.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            dynamicMap.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            dynamicMap.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            dynamicMap.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
        ])

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

fileprivate class MapViewDelegate: DynamicMapViewDelegate {
    var resources: [Resource]?
    var genericResource: GenericResourceModel?

    func mapViewInitDidComplete(_ mapView: SynapsesSDK.DynamicMapView, operationId: String) {
        NSLog("⚠️ MapViewDelegate mapViewInitDidComplete: \(operationId)")
        if let resources {
            mapView.showResourceOnMap(resources: resources, autoFloor: true) { response, error in
                if let error {
                    NSLog("⚠️ MapViewDelegate showResourceOnMap: \(error)")
                } else {
                    NSLog("⚠️ MapViewDelegate \(resources.count) resource(s) shown")
                }
            }
        } else if let genericResource {
            mapView.selectPoi(poi: genericResource, changeFloor: true) { response, error in
                if let error {
                    NSLog("⚠️ MapViewDelegate showResourceOnMap: \(error)")
                } else {
                    NSLog("⚠️ MapViewDelegate \(genericResource) shown")
                }
            }
        }
    }
    
    func mapViewInitDidFail(_ mapView: SynapsesSDK.DynamicMapView, error: Error) {
        NSLog("⚠️ MapViewDelegate mapViewInitDidFail: \(error)")
    }
    
    func didReceiveEvent(_ mapView: SynapsesSDK.DynamicMapView, event: SynapsesSDK.MapEvent, payload: Any?) {
        if let payload = payload as? GenericEventResponse {
            NSLog("⚠️ MapViewDelegate didReceiveEvent: \(String(describing: event.decodedPayload)) - \(String(describing: payload.message))")
        } else {
            NSLog("⚠️ MapViewDelegate didReceiveEvent: \(String(describing: event.decodedPayload))")
        }
    }
    
    func didReceiveError(_ mapView: SynapsesSDK.DynamicMapView, error: Error) {
        NSLog("⚠️ MapViewDelegate didReceiveError: \(error.localizedDescription)")

    }
}
