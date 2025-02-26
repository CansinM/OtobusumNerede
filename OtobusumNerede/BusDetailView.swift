import SwiftUI
import MapKit
import SwiftData

struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct BusDetailView: View {
    var bus: Bus
    var fromCity: String
    var toCity: String
    
    @Environment(\.modelContext) private var modelContext
    @State private var fromCityCoordinate: CLLocationCoordinate2D?
    @State private var toCityCoordinate: CLLocationCoordinate2D?
    
    @State private var route: MKRoute?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.0, longitude: 30.0),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    
    @State private var busLocation: CLLocationCoordinate2D? // Dinamik otobüs konumu
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(bus.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding()

                Text("Kalkış: \(bus.departureTime)")
                Text("Varış: \(bus.arrivalTime)")
                Text("Süre: \(bus.duration)")
                    .foregroundColor(.secondary)
                
                if let fromCityCoordinate = fromCityCoordinate, let toCityCoordinate = toCityCoordinate {
                    MapView(route: $route, region: $region, busLocation: $busLocation)
                        .frame(height: 300)
                        .cornerRadius(15)
                        .padding()
                        .shadow(radius: 10)
                } else {
                    Text("Şehir bilgileri alınamadı.")
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
        }
        .onAppear {
            fetchCityCoordinates()
        }
        .onDisappear {
            // Timer'ı durdurma
            timer?.invalidate()
        }
    }
    
    // Şehirlerin enlem ve boylam bilgilerini veritabanından çekme fonksiyonu
    func fetchCityCoordinates() {
        let fromCityFetch = FetchDescriptor<City>(predicate: #Predicate { $0.name == fromCity })
        let toCityFetch = FetchDescriptor<City>(predicate: #Predicate { $0.name == toCity })
        
        do {
            // Seçilen kalkış şehrinin enlem ve boylamını veritabanından alıyoruz
            if let fromCityResult = try modelContext.fetch(fromCityFetch).first {
                fromCityCoordinate = CLLocationCoordinate2D(latitude: fromCityResult.latitude, longitude: fromCityResult.longitude)
            } else {
                print("Kalkış şehri bulunamadı.")
            }
            
            // Seçilen varış şehrinin enlem ve boylamını veritabanından alıyoruz
            if let toCityResult = try modelContext.fetch(toCityFetch).first {
                toCityCoordinate = CLLocationCoordinate2D(latitude: toCityResult.latitude, longitude: toCityResult.longitude)
            } else {
                print("Varış şehri bulunamadı.")
            }
            
            // Eğer hem kalkış hem de varış şehirleri bulunduysa, rota hesapla
            if let fromCityCoordinate = fromCityCoordinate, let toCityCoordinate = toCityCoordinate {
                calculateRoute(from: fromCityCoordinate, to: toCityCoordinate)
            }
        } catch {
            print("Şehir koordinatları alınırken hata oluştu: \(error)")
        }
    }
    
    // Rota hesaplama fonksiyonu
    func calculateRoute(from fromCoordinate: CLLocationCoordinate2D, to toCoordinate: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: fromCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let response = response, let route = response.routes.first {
                self.route = route
                self.region = MKCoordinateRegion(route.polyline.boundingMapRect)
                
                // Otobüs konumunu dinamik olarak güncelleyen simülasyonu başlat
                startBusLocationSimulation(route: route)
            }
        }
    }

    // Otobüsün rotada rastgele konumunu belirleyen simülasyon
    func startBusLocationSimulation(route: MKRoute) {
        timer?.invalidate() // Mevcut timer varsa durdur
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let randomDistance = Double.random(in: 0...route.distance)
            if let newBusLocation = getCoordinateAlongRoute(route: route, for: randomDistance) {
                busLocation = newBusLocation
                region.center = newBusLocation
            }
        }
    }
    
    // Rotadaki belirli bir mesafedeki konumu bulma fonksiyonu
    func getCoordinateAlongRoute(route: MKRoute, for distance: CLLocationDistance) -> CLLocationCoordinate2D? {
        var accumulatedDistance: CLLocationDistance = 0
        
        for step in route.steps {
            accumulatedDistance += step.distance
            if accumulatedDistance >= distance {
                return step.polyline.coordinate
            }
        }
        
        return nil
    }
}

// Harita üzerinde rotayı ve otobüs konumunu gösteren view
struct MapView: UIViewRepresentable {
    @Binding var route: MKRoute?
    @Binding var region: MKCoordinateRegion
    @Binding var busLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        // Rota çizimi
        if let route = route {
            let polyline = route.polyline
            mapView.addOverlay(polyline)
            mapView.setVisibleMapRect(polyline.boundingMapRect, animated: true)
        }

        // Otobüs konumunu haritaya ekleyelim
        if let busLocation = busLocation {
            let busAnnotation = MKPointAnnotation()
            busAnnotation.coordinate = busLocation
            busAnnotation.title = "Otobüs"
            mapView.addAnnotation(busAnnotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }

        // Otobüs simgesi özelleştirme
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation.title == "Otobüs" {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "bus")
                annotationView.markerTintColor = .green
                annotationView.glyphImage = UIImage(systemName: "bus.fill")
                annotationView.canShowCallout = true
                return annotationView
            }
            return nil
        }
    }
}

