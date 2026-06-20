class RegionModel {
  const RegionModel({required this.id, required this.name});

  final String id;
  final String name;

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );
}

class CityModel {
  const CityModel({
    required this.id,
    required this.regionId,
    required this.name,
  });

  final String id;
  final String regionId;
  final String name;

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json['id'] as String? ?? '',
    regionId: json['regionId'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );
}

class TerminalSummary {
  const TerminalSummary({required this.id, required this.name});

  final String id;
  final String name;

  factory TerminalSummary.fromJson(Map<String, dynamic> json) =>
      TerminalSummary(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}

class TripModel {
  const TripModel({
    required this.id,
    required this.originCity,
    required this.destinationCity,
    required this.originTerminal,
    required this.destinationTerminal,
    required this.departureTime,
    required this.arrivalEstimate,
    required this.agencyName,
    required this.busClass,
    required this.basePriceXaf,
    required this.availableSeats,
  });

  final String id;
  final String originCity;
  final String destinationCity;
  final TerminalSummary originTerminal;
  final TerminalSummary destinationTerminal;
  final DateTime departureTime;
  final DateTime arrivalEstimate;
  final String agencyName;
  final String busClass;
  final int basePriceXaf;
  final List<String> availableSeats;

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final agency = json['agency'] as Map<String, dynamic>? ?? const {};
    return TripModel(
      id: json['id'] as String? ?? '',
      originCity: json['originCity'] as String? ?? '',
      destinationCity: json['destinationCity'] as String? ?? '',
      originTerminal: TerminalSummary.fromJson(
        json['originTerminal'] as Map<String, dynamic>? ?? const {},
      ),
      destinationTerminal: TerminalSummary.fromJson(
        json['destinationTerminal'] as Map<String, dynamic>? ?? const {},
      ),
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalEstimate: DateTime.parse(json['arrivalEstimate'] as String),
      agencyName: agency['name'] as String? ?? '',
      busClass: json['busClass'] as String? ?? 'standard',
      basePriceXaf: (json['basePriceXaf'] as num?)?.toInt() ?? 0,
      availableSeats: (json['availableSeats'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class BookingModel {
  const BookingModel({
    required this.id,
    required this.tripId,
    required this.seatNumber,
    required this.status,
    this.ticketId,
  });

  final String id;
  final String tripId;
  final String seatNumber;
  final String status;
  final String? ticketId;

  bool get isPaid => status == 'paid' || status == 'confirmed';

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'] as String? ?? '',
    tripId: json['tripId'] as String? ?? '',
    seatNumber: json['seatNumber'] as String? ?? '',
    status: json['status'] as String? ?? '',
    ticketId: json['ticketId'] as String?,
  );
}

class TicketModel {
  const TicketModel({
    required this.id,
    required this.code,
    required this.createdAt,
  });

  final String id;
  final String code;
  final DateTime createdAt;

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: json['id'] as String? ?? '',
    code: json['ticketCode'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class PaymentConfirmation {
  const PaymentConfirmation({required this.booking, required this.ticket});

  final BookingModel booking;
  final TicketModel ticket;
}

class TaxiAreaModel {
  const TaxiAreaModel({
    required this.id,
    required this.name,
    required this.distanceMeters,
    required this.estimatedFareXaf,
  });

  final String id;
  final String name;
  final int distanceMeters;
  final int estimatedFareXaf;

  factory TaxiAreaModel.fromJson(Map<String, dynamic> json) => TaxiAreaModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
    estimatedFareXaf: (json['estimatedFareXaf'] as num?)?.toInt() ?? 0,
  );
}

class TaxiEligibilityModel {
  const TaxiEligibilityModel({
    required this.bookingId,
    required this.arrivalTerminalName,
    required this.arrivalCity,
    required this.areas,
  });

  final String bookingId;
  final String arrivalTerminalName;
  final String arrivalCity;
  final List<TaxiAreaModel> areas;

  factory TaxiEligibilityModel.fromJson(Map<String, dynamic> json) {
    final terminal =
        json['arrivalTerminal'] as Map<String, dynamic>? ?? const {};
    return TaxiEligibilityModel(
      bookingId: json['bookingId'] as String? ?? '',
      arrivalTerminalName: terminal['name'] as String? ?? '',
      arrivalCity: terminal['city'] as String? ?? '',
      areas: (json['eligibleAreas'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaxiAreaModel.fromJson)
          .toList(growable: false),
    );
  }
}

class TaxiRideModel {
  const TaxiRideModel({
    required this.id,
    required this.status,
    required this.estimatedFareXaf,
  });

  final String id;
  final String status;
  final int estimatedFareXaf;

  factory TaxiRideModel.fromJson(Map<String, dynamic> json) => TaxiRideModel(
    id: json['id'] as String? ?? '',
    status: json['status'] as String? ?? '',
    estimatedFareXaf: (json['estimatedFareXaf'] as num?)?.toInt() ?? 0,
  );
}
