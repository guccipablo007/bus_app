import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../navigation/role_router_screen.dart';
import '../../shared/models/api_models.dart';
import '../../shared/models/user_role.dart';
import '../../shared/widgets/glass_panel.dart';

class PassengerHomeShell extends StatefulWidget {
  const PassengerHomeShell({
    super.key,
    required this.session,
    required this.apiClient,
  });

  final UserSession session;
  final ApiClient apiClient;

  @override
  State<PassengerHomeShell> createState() => _PassengerHomeShellState();
}

class _PassengerHomeShellState extends State<PassengerHomeShell> {
  final _landmark = TextEditingController();
  int _index = 0;
  bool _loadingInitial = true;
  bool _searching = false;
  bool _actionBusy = false;
  Map<String, dynamic>? _health;
  List<CityModel> _cities = const [];
  List<TripModel> _trips = const [];
  String? _originCity;
  String? _destinationCity;
  BookingModel? _booking;
  TicketModel? _ticket;
  TaxiEligibilityModel? _eligibility;
  TaxiAreaModel? _selectedArea;
  TaxiRideModel? _taxiRide;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _landmark.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    try {
      final responses = await Future.wait<dynamic>([
        widget.apiClient.health(),
        widget.apiClient.regions(),
        widget.apiClient.cities(),
      ]);
      final cities = responses[2] as List<CityModel>;
      if (!mounted) return;
      setState(() {
        _health = responses[0] as Map<String, dynamic>;
        _cities = cities;
        _originCity = cities.any((city) => city.name == 'Buea')
            ? 'Buea'
            : cities.firstOrNull?.name;
        _destinationCity = cities.any((city) => city.name == 'Bamenda')
            ? 'Bamenda'
            : cities.elementAtOrNull(1)?.name;
        _loadingInitial = false;
      });
      await _searchTrips();
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _loadingInitial = false;
          _error = error.message;
        });
      }
    }
  }

  Future<void> _searchTrips() async {
    final origin = _originCity;
    final destination = _destinationCity;
    if (origin == null || destination == null || origin == destination) {
      _showError('Choose two different cities.');
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final trips = await widget.apiClient.searchTrips(
        originCity: origin,
        destinationCity: destination,
      );
      if (mounted) setState(() => _trips = trips);
    } on ApiException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _bookTrip(TripModel trip) async {
    final seat = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose a seat'),
        children: trip.availableSeats.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No seats available.'),
                ),
              ]
            : trip.availableSeats
                  .map(
                    (seat) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, seat),
                      child: Row(
                        children: [
                          const Icon(Icons.event_seat_outlined),
                          const SizedBox(width: 12),
                          Text('Seat $seat'),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
      ),
    );
    if (seat == null) return;
    await _runAction(() async {
      final booking = await widget.apiClient.createBooking(
        accessToken: widget.session.accessToken,
        tripId: trip.id,
        seatNumber: seat,
      );
      setState(() {
        _booking = booking;
        _ticket = null;
        _eligibility = null;
        _taxiRide = null;
        _index = 1;
      });
      _showMessage('Seat $seat reserved.');
    });
  }

  Future<void> _confirmPayment() async {
    final booking = _booking;
    if (booking == null) return;
    await _runAction(() async {
      final confirmation = await widget.apiClient.confirmDemoPayment(
        accessToken: widget.session.accessToken,
        bookingId: booking.id,
      );
      setState(() {
        _booking = confirmation.booking;
        _ticket = confirmation.ticket;
      });
      await _loadTaxiAreas(showSuccess: false);
      _showMessage('Demo payment confirmed.');
    });
  }

  Future<void> _loadTaxiAreas({bool showSuccess = true}) async {
    final booking = _booking;
    if (booking == null || !booking.isPaid) return;
    try {
      final eligibility = await widget.apiClient.eligibleTaxiAreas(
        accessToken: widget.session.accessToken,
        bookingId: booking.id,
      );
      if (!mounted) return;
      setState(() {
        _eligibility = eligibility;
        _selectedArea = eligibility.areas.firstOrNull;
      });
      if (showSuccess) _showMessage('Taxi areas updated.');
    } on ApiException catch (error) {
      _showError(error.message);
    }
  }

  Future<void> _requestTaxi() async {
    final booking = _booking;
    final area = _selectedArea;
    if (booking == null || area == null) return;
    if (_landmark.text.trim().length < 2) {
      _showError('Enter a pickup landmark or destination note.');
      return;
    }
    await _runAction(() async {
      final ride = await widget.apiClient.createTaxiRide(
        accessToken: widget.session.accessToken,
        bookingId: booking.id,
        destinationAreaId: area.id,
        destinationLandmark: _landmark.text.trim(),
      );
      setState(() => _taxiRide = ride);
      _showMessage('Taxi request submitted.');
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _actionBusy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _bookings(), _taxi(), _profile()];
    return Scaffold(
      appBar: AppBar(
        title: Text(['Travel', 'Bookings', 'Taxi', 'Profile'][_index]),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => RoleRouterScreen.logout(context, widget.apiClient),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE4F5EF), Color(0xFFFFF7E5), Color(0xFFEDF1F8)],
          ),
        ),
        child: SafeArea(
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_taxi_outlined),
            label: 'Taxi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _home() => RefreshIndicator(
    onRefresh: _loadInitial,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _connectionPanel(),
        const SizedBox(height: 12),
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Find a bus',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _originCity,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    prefixIcon: Icon(Icons.trip_origin),
                  ),
                  items: _cities
                      .map(
                        (city) => DropdownMenuItem(
                          value: city.name,
                          child: Text(city.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _originCity = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _destinationCity,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: _cities
                      .map(
                        (city) => DropdownMenuItem(
                          value: city.name,
                          child: Text(city.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _destinationCity = value),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _searching || _loadingInitial
                      ? null
                      : _searchTrips,
                  icon: _searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_searching ? 'Searching...' : 'Search trips'),
                ),
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Available trips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Text('${_trips.length}'),
          ],
        ),
        const SizedBox(height: 8),
        if (_loadingInitial)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_trips.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No trips found for this route.',
              textAlign: TextAlign.center,
            ),
          )
        else
          ..._trips.map(_tripCard),
      ],
    ),
  );

  Widget _connectionPanel() {
    final connected =
        _health?['status'] == 'ok' && _health?['database'] == 'reachable';
    return GlassPanel(
      child: ListTile(
        leading: Icon(
          connected ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          color: connected ? Colors.green.shade700 : Colors.orange.shade800,
        ),
        title: Text(
          connected
              ? 'Staging service connected'
              : 'Connecting to staging service',
        ),
        subtitle: Text(
          connected ? 'Trips and bookings are live.' : 'Pull down to retry.',
        ),
      ),
    );
  }

  Widget _tripCard(TripModel trip) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${trip.originCity} to ${trip.destinationCity}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${trip.basePriceXaf} XAF',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(trip.agencyName),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(trip.departureTime)}  |  ${trip.availableSeats.length} seats',
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _actionBusy || trip.availableSeats.isEmpty
                  ? null
                  : () => _bookTrip(trip),
              icon: const Icon(Icons.event_seat_outlined),
              label: const Text('Choose seat'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _bookings() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      if (_booking == null)
        const GlassPanel(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Your current staging booking will appear here.',
              textAlign: TextAlign.center,
            ),
          ),
        )
      else ...[
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Seat ${_booking!.seatNumber}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _statusChip(_booking!.status),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText('Booking ${_booking!.id}'),
                if (!_booking!.isPaid) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _actionBusy ? null : _confirmPayment,
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Confirm demo payment'),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_ticket != null) ...[
          const SizedBox(height: 12),
          GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ticket', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Validation code'),
                  const SizedBox(height: 4),
                  SelectableText(
                    _ticket!.code,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ],
  );

  Widget _taxi() {
    final booking = _booking;
    if (booking == null || !booking.isPaid) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Taxi service becomes available after a paid bus booking.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final eligibility = _eligibility;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Destination taxi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  eligibility == null
                      ? 'Load approved arrival areas.'
                      : '${eligibility.arrivalTerminalName}, ${eligibility.arrivalCity}',
                ),
                const SizedBox(height: 14),
                if (eligibility == null)
                  FilledButton.tonalIcon(
                    onPressed: _actionBusy ? null : _loadTaxiAreas,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load eligible areas'),
                  )
                else if (eligibility.areas.isEmpty)
                  const Text(
                    'No verified taxi areas are available for this arrival terminal.',
                  )
                else ...[
                  DropdownButtonFormField<TaxiAreaModel>(
                    initialValue: _selectedArea,
                    decoration: const InputDecoration(
                      labelText: 'Residential area',
                      prefixIcon: Icon(Icons.home_work_outlined),
                    ),
                    items: eligibility.areas
                        .map(
                          (area) => DropdownMenuItem(
                            value: area,
                            child: Text(
                              '${area.name} - ${area.estimatedFareXaf} XAF',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (area) => setState(() => _selectedArea = area),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _landmark,
                    maxLength: 240,
                    decoration: const InputDecoration(
                      labelText: 'Landmark',
                      hintText: 'Near pharmacy, blue gate',
                      prefixIcon: Icon(Icons.edit_location_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _actionBusy ? null : _requestTaxi,
                    icon: const Icon(Icons.local_taxi_outlined),
                    label: const Text('Request taxi'),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_taxiRide != null) ...[
          const SizedBox(height: 12),
          GlassPanel(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Taxi requested'),
              subtitle: Text(
                '${_taxiRide!.status} | ${_taxiRide!.estimatedFareXaf} XAF',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _profile() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      GlassPanel(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(
                  widget.session.fullName.isEmpty
                      ? '?'
                      : widget.session.fullName[0].toUpperCase(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.session.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(widget.session.email),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: widget.session.roles
                    .map((role) => Chip(label: Text(role.label)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    RoleRouterScreen.logout(context, widget.apiClient),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _statusChip(String status) =>
      Chip(label: Text(status.replaceAll('_', ' ')));

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
