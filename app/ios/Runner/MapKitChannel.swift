import Flutter
import Foundation
import MapKit

/// Маршруты и поиск мест (SPEC §8.5, §12): MKDirections (пешком), MKLocalSearch.
/// Dart — app/lib/features/walks/data/mapkit_routing_backend.dart.
///   route  {points: [[lat, lon], …]} → {points: [[lat, lon], …], distanceM, durationS, steps: [{atM, instruction}]} или nil
///          (пешие маршруты между соседними точками, склеенные по порядку; один участок не построен — nil)
///   search {lat, lon, radiusM, category: grocery|water|pharmacy} → [{name, lat, lon, address?}]
/// Ответы — на главном потоке.
final class MapKitChannel {
  static let name = "sistema/maps"

  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: MapKitChannel.name, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "route":
      guard
        let args = call.arguments as? [String: Any],
        let raw = args["points"] as? [[NSNumber]]
      else {
        result(FlutterError(code: "bad_args", message: "points", details: nil))
        return
      }
      let coords = raw.compactMap { p -> CLLocationCoordinate2D? in
        p.count >= 2 ? CLLocationCoordinate2D(latitude: p[0].doubleValue, longitude: p[1].doubleValue) : nil
      }
      guard coords.count >= 2 else {
        result(nil)
        return
      }
      route(coords) { value in
        DispatchQueue.main.async { result(value) }
      }
    case "search":
      guard
        let args = call.arguments as? [String: Any],
        let lat = (args["lat"] as? NSNumber)?.doubleValue,
        let lon = (args["lon"] as? NSNumber)?.doubleValue
      else {
        result(FlutterError(code: "bad_args", message: "lat/lon", details: nil))
        return
      }
      let radius = (args["radiusM"] as? NSNumber)?.doubleValue ?? 1500
      let category = args["category"] as? String ?? "grocery"
      search(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), radius: radius, category: category) { value in
        DispatchQueue.main.async { result(value) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Маршрут

  private struct Leg {
    let points: [[Double]]
    let distance: Double
    let duration: Double
    let steps: [(atM: Double, instruction: String)]
  }

  /// Участки строятся последовательно (лимит запросов MKDirections) и склеиваются.
  private func route(_ coords: [CLLocationCoordinate2D], completion: @escaping (Any?) -> Void) {
    var legs: [Leg] = []

    func next(_ i: Int) {
      if i >= coords.count - 1 {
        completion(Self.merge(legs))
        return
      }
      let request = MKDirections.Request()
      request.source = MKMapItem(placemark: MKPlacemark(coordinate: coords[i]))
      request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coords[i + 1]))
      request.transportType = .walking
      request.requestsAlternateRoutes = false
      MKDirections(request: request).calculate { response, error in
        guard let r = response?.routes.first, error == nil else {
          NSLog("MapKitChannel route: \(error?.localizedDescription ?? "нет маршрута")")
          completion(nil)
          return
        }
        legs.append(Self.leg(from: r))
        next(i + 1)
      }
    }
    next(0)
  }

  private static func leg(from r: MKRoute) -> Leg {
    let count = r.polyline.pointCount
    var buffer = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: count)
    r.polyline.getCoordinates(&buffer, range: NSRange(location: 0, length: count))
    var steps: [(atM: Double, instruction: String)] = []
    var at = 0.0
    for s in r.steps {
      // Манёвр шага — в его начале; пустая инструкция (первый шаг) — пропускаем.
      if !s.instructions.isEmpty {
        steps.append((atM: at, instruction: s.instructions))
      }
      at += s.distance
    }
    return Leg(
      points: buffer.map { [$0.latitude, $0.longitude] },
      distance: r.distance,
      duration: r.expectedTravelTime,
      steps: steps
    )
  }

  private static func merge(_ legs: [Leg]) -> Any? {
    var points: [[Double]] = []
    var steps: [[String: Any]] = []
    var offset = 0.0
    var duration = 0.0
    for leg in legs {
      // Стык участков — одна точка.
      points.append(contentsOf: points.isEmpty ? leg.points : Array(leg.points.dropFirst()))
      for s in leg.steps {
        steps.append(["atM": offset + s.atM, "instruction": s.instruction])
      }
      offset += leg.distance
      duration += leg.duration
    }
    guard points.count >= 2, offset > 0 else { return nil }
    return ["points": points, "distanceM": offset, "durationS": duration, "steps": steps]
  }

  // MARK: - Места

  private func search(
    center: CLLocationCoordinate2D,
    radius: Double,
    category: String,
    completion: @escaping (Any?) -> Void
  ) {
    let categories: [MKPointOfInterestCategory]
    switch category {
    case "pharmacy":
      categories = [.pharmacy]
    case "water":
      categories = [.foodMarket, .store]
    default:
      categories = [.foodMarket]
    }
    let request = MKLocalPointsOfInterestRequest(center: center, radius: max(100, min(radius, 20000)))
    request.pointOfInterestFilter = MKPointOfInterestFilter(including: categories)
    MKLocalSearch(request: request).start { response, error in
      guard let items = response?.mapItems, error == nil else {
        NSLog("MapKitChannel search: \(error?.localizedDescription ?? "пусто")")
        completion([[String: Any]]())
        return
      }
      let out: [[String: Any]] = items.map { item in
        let c = item.placemark.coordinate
        var e: [String: Any] = ["name": item.name ?? "", "lat": c.latitude, "lon": c.longitude]
        let street = [item.placemark.thoroughfare, item.placemark.subThoroughfare].compactMap { $0 }.joined(separator: ", ")
        if !street.isEmpty { e["address"] = street }
        return e
      }
      completion(out)
    }
  }
}
