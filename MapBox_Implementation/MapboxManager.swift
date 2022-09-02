//
//  MapboxManager.swift
//  Flight
//
//  Created by Muhammad Asar on 5/28/22.
//

import UIKit
import MapboxMaps
import CoreLocation

struct MapboxIdentifiers {
    static let dataSourceIdentifier  = "dataSourceIdentifier"
    static let airportLayer          = "airportLayerIdentifier"
    static let bermudaLayer          = "bermudaLayerIdentifier"
    static let antarcticaLayer       = "atarcticaLayerIdentifier"
    static let clusteredLayer        = "clusteredLayerIdentifier"
    static let clusteredCountLayer   = "clusteredCountLayerIdentifier"
    static let unclusteredLayer      = "unclusteredLayerIdentifier"
    static let unclusteredImageLayer = "unclusteredImageLayerIdentifier"
    static let pointCount            = "point_count"
    static let viewAnnotationPrefix  = "view_annotation_"
}

class MapboxManager: NSObject {
    
    // Load GeoJSON file from local bundle and decode into a `FeatureCollection`.
    fileprivate static func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
            preconditionFailure("File '\(fileName)' not found.")
        }
        let filePath = URL(fileURLWithPath: path)
        var featureCollection: FeatureCollection?
        do {
            let data = try Data(contentsOf: filePath)
            featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }
        return featureCollection
    }
    
    // MARK: - managing clustered/unclustered layers -
    
    static func addPointClusters(for mapView: MapView, at points: [CLLocationCoordinate2D], completion: @escaping (()->Void)) {
        
        let style = mapView.mapboxMap.style
        
        var source = GeoJSONSource()
        var features = [Feature]()
        
        for (index,cord) in points.enumerated() {
            var feature = Feature(geometry: .point(Point(cord)))
            feature.identifier = .string("\(MapboxIdentifiers.viewAnnotationPrefix)\(index)")
            features.append(feature)
        }
        
        let featureCollection = FeatureCollection(features: features)
        source.data = .featureCollection(featureCollection)
        
        // Set the clustering properties directly on the source.
        source.cluster = true
        source.clusterRadius = 150
        
        // The maximum zoom level where points will be clustered.
        source.clusterMaxZoom = 10
        let sourceID = "pilot-source"
        
        // Create three separate layers from the same source.
        // `clusteredLayer` contains clustered point features.
        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = sourceID
        
        /// `unclusteredLayer` contains individual point features that do not represent clusters.
//        var unclusteredLayer = createUnclusteredLayer()
//        unclusteredLayer.source = sourceID
        
        /// `unclusteredImageLayer` contains individual point features that represent icons.
        
        var unclusteredImageLayer = createUnclusteredImageLayer()
        unclusteredImageLayer.source = sourceID
        
        // `clusterCountLayer` is a `SymbolLayer` that represents the point count within individual clusters.
        var clusterCountLayer = createNumberLayer()
        clusterCountLayer.source = sourceID
        
        // Add source and layers to the map view's style.
        try? style.addSource(source, id: sourceID)
        try? style.addLayer(clusteredLayer)
//        try? style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
        try? style.addLayer(unclusteredImageLayer, layerPosition: .below(clusteredLayer.id))
        try? style.addLayer(clusterCountLayer)
        
        completion()
        
    }
    
    fileprivate static func createUnclusteredImageLayer() -> SymbolLayer {
        var imageLayer = SymbolLayer(id: MapboxIdentifiers.unclusteredImageLayer)

        // Filter out clusters by checking for point_count.
        imageLayer.filter = Exp(.not) {
            Exp(.has) { MapboxIdentifiers.pointCount }
        }

        imageLayer.iconImage = .constant(.name("fire-station-11"))
        imageLayer.iconSize = .constant(0.1)
        return imageLayer
    }
    
    fileprivate static func createClusteredLayer() -> CircleLayer {
        
        let baseColor = UIColor.blue
        
        // Create a `CircleLayer` that only contains clustered points.
        var clusteredLayer = CircleLayer(id: MapboxIdentifiers.clusteredLayer)
        clusteredLayer.filter = Exp(.has) { MapboxIdentifiers.pointCount }
        
        // Set the circle's color and radius based on the number of points within each cluster.
        clusteredLayer.circleColor =  .expression(Exp(.step) {
            Exp(.get) { MapboxIdentifiers.pointCount }
            baseColor
            9
            baseColor
            99
            baseColor
        })
        
        clusteredLayer.circleRadius = .expression(Exp(.step) {
            Exp(.get) { MapboxIdentifiers.pointCount }
            16
            9
            24
            99
            40
        })
        
        clusteredLayer.circleStrokeWidth = .constant(4)
        clusteredLayer.circleStrokeColor = .constant(.init(baseColor.withAlphaComponent(0.4)))
        
        return clusteredLayer
    }
    
    fileprivate static func createUnclusteredLayer() -> CircleLayer {
        
        let baseColor = UIColor.blue
        
        var unclusteredLayer = CircleLayer(id: MapboxIdentifiers.unclusteredLayer)
        
        // Filter out clusters by checking for  pointCount.
        unclusteredLayer.filter = Exp(.not) {
            Exp(.has) { MapboxIdentifiers.pointCount }
        }
        
        unclusteredLayer.circleColor = .constant(StyleColor(baseColor))
        unclusteredLayer.circleRadius = .constant(4)
        //        unclusteredLayer.circleStrokeWidth = .constant(1)
        //        unclusteredLayer.circleStrokeColor = .constant(StyleColor(.black))
        
        return unclusteredLayer
    }
    
    fileprivate static func createNumberLayer() -> SymbolLayer {
        var numberLayer = SymbolLayer(id: MapboxIdentifiers.clusteredCountLayer)
        
        // Check whether the point feature is clustered.
        numberLayer.filter = Exp(.has) { MapboxIdentifiers.pointCount }
        
        // Display the value for 'pointCount' in the text field.
        numberLayer.textField = .expression(Exp(.get) { MapboxIdentifiers.pointCount })
        //        numberLayer.textFont
        numberLayer.textSize = .expression(Exp(.step) {
            Exp(.get) { MapboxIdentifiers.pointCount }
            14
            9
            18
            99
            30
        })
        numberLayer.textFont = .constant(["Montserrat Bold"]) //Rubik-SemiBold
        numberLayer.textColor = .constant(.init(.white))
        return numberLayer
    }
    
    // MARK: - adding circle layer around the airports -
    
//    static func addCircleLayer(for mapView: MapView, airports: [AIRPORT_MODEL]) {
//        let style = mapView.mapboxMap.style
//
//        // Create a `GeoJSONSource` from a Turf geometry.
//        var source = GeoJSONSource()
//        var features = [Feature]()
//
//        for airport in airports {
//            if let cords = airport.gpsLocation.coordinates {
//                let point = CLLocationCoordinate2D(latitude: cords[1], longitude: cords[0])
//                var feature = Feature(geometry: .point(Point(point)))
//                feature.identifier = .string(airport.id)
//                var properties = JSONObject()
//                properties["airport"] = JSONValue(rawValue: airport.toDictionary())
//                feature.properties = properties
//                features.append(feature)
//
//            }
//        }
//
//        let featureCollection = FeatureCollection(features: features)
//
//        // Set the source's data property to the feature.
//        source.data = .featureCollection(featureCollection)
//
//        // Create a `CircleLayer` from the previously defined source. The source ID
//        // will be set for the source once it is added to the map's style.
//        var circleLayer = CircleLayer(id: MapboxIdentifiers.airportLayer)
//        circleLayer.source = "source-id"
//
//        // This expression simulates a `CircleLayer` with a radius of 150 meters. For features that will be
//        // visible at lower zoom levels, add more stops at the zoom levels where the feature will be more
//        // visible. This keeps the circle's radius more consistent.
//        let circleRadiusExp = Exp(.interpolate) {
//            Exp(.linear)
//            Exp(.zoom)
//            0
//            circleRadius(in: mapView, forZoom: 0)
//            5
//            circleRadius(in: mapView, forZoom: 5)
//            10
//            circleRadius(in: mapView, forZoom: 10)
//            11
//            circleRadius(in: mapView, forZoom: 13)
//            12
//            circleRadius(in: mapView, forZoom: 14)
//            13
//            circleRadius(in: mapView, forZoom: 15)
//            14
//            circleRadius(in: mapView, forZoom: 16)
//            15
//            circleRadius(in: mapView, forZoom: 17)
//        }
//        circleLayer.circleRadius = .expression(circleRadiusExp)
//        circleLayer.circleColor = .constant(.init(UIColor.blue))
//        circleLayer.circleOpacity = .constant(0.3)
//
//        // Add the source and layer to the map's style.
//        try! style.addSource(source, id: "source-id")
//        try! style.addLayer(circleLayer)
//    }
    
    fileprivate static func circleRadius(in mapView: MapView, forZoom zoom: CGFloat) -> Double {
        let centerLatitude = mapView.cameraState.center.latitude

        // Get the meters per pixel at a given latitude and zoom level.
        let metersPerPoint = Projection.metersPerPoint(for: centerLatitude, zoom: zoom)

        // We want to have a circle radius of 150 meters. Calculate how many
        // pixels that radius needs to be.
        let radius = 250 / metersPerPoint
        return radius
    }
    
    // MARK: - generating randon coordinates -
    
    static func generateRandomCoordinates(around point: CLLocationCoordinate2D, min: UInt32, max: UInt32)-> CLLocationCoordinate2D {
        //Get the Current Location's longitude and latitude
        let currentLong = point.longitude
        let currentLat  = point.latitude

        //1 KiloMeter = 0.00900900900901° So, 1 Meter = 0.00900900900901 / 1000
        let meterCord = 0.00900900900901 / 1000

        //Generate random Meters between the maximum and minimum Meters
        let randomMeters = UInt(arc4random_uniform(max) + min)

        //then Generating Random numbers for different Methods
        let randomPM = arc4random_uniform(6)

        //Then we convert the distance in meters to coordinates by Multiplying the number of meters with 1 Meter Coordinate
        let metersCordN = meterCord * Double(randomMeters)

        //here we generate the last Coordinates
        if randomPM == 0 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 1 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 2 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 3 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 4 {
            return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
        }else {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
        }

    }
    
}
