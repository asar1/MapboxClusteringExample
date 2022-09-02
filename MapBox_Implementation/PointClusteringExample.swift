import UIKit
import MapboxMaps

@objc(PointClusteringExample)

public class PointClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    
    let cords = [CLLocationCoordinate2D(latitude: 65.5942, longitude: -152.0732),
                 CLLocationCoordinate2D(latitude: 63.1224, longitude: -150.4048),
                 CLLocationCoordinate2D(latitude: 63.1016, longitude: -151.5129),
                 CLLocationCoordinate2D(latitude: 63.0781, longitude: -151.3597),
                 CLLocationCoordinate2D(latitude: 34.299667, longitude: -118.497),
                 CLLocationCoordinate2D(latitude: 12.0623, longitude: -87.6901),
                 CLLocationCoordinate2D(latitude: 63.0719, longitude: -151.5053),
                 CLLocationCoordinate2D(latitude: 20.2873, longitude: -178.4576),
                 CLLocationCoordinate2D(latitude: 63.1725, longitude: -148.789),
                 CLLocationCoordinate2D(latitude: 36.421833, longitude: -120.993164),
                 CLLocationCoordinate2D(latitude: 33.656333, longitude: -117.0155),
                 CLLocationCoordinate2D(latitude: 63.0879, longitude: -151.512),
                 CLLocationCoordinate2D(latitude: 63.0933, longitude: -149.6538),
                 CLLocationCoordinate2D(latitude: 63.2272, longitude: -151.5325),
                 CLLocationCoordinate2D(latitude: 63.0844, longitude: -149.4752),
                 CLLocationCoordinate2D(latitude: 61.8518, longitude: -150.8597),
                 CLLocationCoordinate2D(latitude: 62.9656, longitude: -149.7142),
                 CLLocationCoordinate2D(latitude: 61.2705, longitude: -151.2484)]

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a map view centered over the United States and using the Mapbox Dark style.
        let center = CLLocationCoordinate2D(latitude: 40.669957, longitude: -103.5917968)
        let cameraOptions = CameraOptions(center: center, zoom: 2)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .lightGray

        view.addSubview(mapView)

        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            MapboxManager.addPointClusters(for: self.mapView, at: self.cords) {
                
                for (index,coordinate) in self.cords.enumerated() {
                    let options = ViewAnnotationOptions(
                        geometry: Point(coordinate),
                        associatedFeatureId: "\(MapboxIdentifiers.viewAnnotationPrefix)\(index)",
                        allowOverlap: true,
                        anchor: .center
                    )
                    let annotation = CustomAnnotatoinView.getView()
                    try? self.mapView.viewAnnotations.add(annotation, options: options)
                    let myView = CustomAnnotatoinView()
                    myView.transform = CGAffineTransform(scaleX: 0, y: 0)
                    UIView.animate(withDuration: 3) {
                    myView.transform = .identity
                    }
                }
                
            }
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
    
    internal func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
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
}


extension UIView {
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
extension UIImageView{
    func setImage(_ image: UIImage?, animated: Bool = true) {
        let duration = animated ? 0.75 : 0.0
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}
