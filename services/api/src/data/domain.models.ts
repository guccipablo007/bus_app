export interface Region { id: string; name: string }
export interface City { id: string; regionId: string; name: string }

export interface Trip {
  id: string;
  originCityId: string;
  destinationCityId: string;
  originCity: string;
  destinationCity: string;
  originTerminal: { id: string; name: string };
  destinationTerminal: { id: string; name: string };
  arrivalTerminalId: string;
  departureTime: string;
  arrivalEstimate: string;
  agency: { id: string; name: string };
  busClass: string;
  fareXaf: number;
  basePriceXaf: number;
  availableSeats: string[];
  availableSeatCount: number;
}

export type BookingStatus = 'pending_payment' | 'paid' | 'confirmed';

export interface Booking {
  id: string;
  passengerId: string;
  tripId: string;
  seatNumber: string;
  status: BookingStatus;
  ticketId?: string;
}

export interface Ticket {
  id: string;
  bookingId: string;
  ticketCode: string;
  createdAt: string;
}

export interface ResidentialArea {
  id: string;
  cityId: string;
  name: string;
  active: boolean;
  verifiedByAdmin: boolean;
  distanceMeters: number;
}

export interface TaxiRide {
  id: string;
  bookingId: string;
  passengerId: string;
  pickupTerminalId: string;
  destinationAreaId: string;
  destinationLandmark: string;
  estimatedFareXaf: number;
  status: 'requested';
}
