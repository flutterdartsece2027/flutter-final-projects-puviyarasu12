import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:animeinfo/screens/splash_screen.dart';

class ConnectionWrapper extends StatefulWidget {
  final Widget child;

  const ConnectionWrapper({super.key, required this.child});

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOfflinePageShown = false;

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity().onConnectivityChanged.listen((results) async {
      if (results.isEmpty || results.first == ConnectivityResult.none) {
        _showOfflinePage();
      } else {
        final connected = await hasInternetConnection();
        if (!connected) {
          _showOfflinePage();
        } else {
          _isOfflinePageShown = false;
        }
      }
    });
  }

  void _showOfflinePage() {
    if (_isOfflinePageShown) return;
    _isOfflinePageShown = true;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const NoInternetPage(),
    ));
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

Future<bool> hasInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  }
}

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity().onConnectivityChanged.listen((results) async {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        final hasInternet = await hasInternetConnection();
        if (hasInternet) {
          _goBackToApp();
        }
      }
    });
  }

  void _goBackToApp() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // go back to previous screen
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Future<void> _retry() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    final hasInternet = await hasInternetConnection();
    if (hasInternet) {
      _goBackToApp();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still offline. Check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isChecking = false);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            const Text(
              'No Internet Connection',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            if (_isChecking)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
