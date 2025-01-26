import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/consent_manager.dart';
import 'package:flutter_application/database.dart';
import 'package:flutter_application/plant.dart';
import 'package:flutter_application/plant_home_widget.dart';
import 'package:flutter_application/plant_search_delegate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _consentManager = ConsentManager();
  var _isMobileAdsInitializeCalled = false;
  // ignore: unused_field
  var _isPrivacyOptionsRequired = false;
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final String _adUnitId = 'ca-app-pub-3940256099942544/9214589741';

  final SqlDb _sqldb = SqlDb();
  final SearchController controller = SearchController();
  late Timer _timer;

  readData() async {
    var plants = await _sqldb.readData('SELECT * FROM plants');
    return plants;
  }

  @override
  void initState() {
    super.initState();

    _consentManager.gatherConsent((consentGatheringError) {
      if (consentGatheringError != null) {
        // Consent not obtained in current session.
        debugPrint(
            "${consentGatheringError.errorCode}: ${consentGatheringError.message}");
      }
      // Check if a privacy options entry point is required.
      _getIsPrivacyOptionsRequired();
      // Attempt to initialize the Mobile Ads SDK.
      _initializeMobileAdsSDK();
    });
    // This sample attempts to load ads using consent obtained in the previous session.
    _initializeMobileAdsSDK();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leadingWidth: 45,
          leading: const Image(image: AssetImage('assets/FoodGardenAppLogo.png')),
          title: Text('Food Garden', style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 25)),
          backgroundColor: const Color.fromARGB(255, 19, 160, 19),
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.black, size: 30.0),
                onPressed: () async {
                  var plantName = await showSearch(
                    context: context,
                    delegate: PlantSearchDelegate(),
                  );
                  if (plantName != null) {
                    setState(() {
                      _sqldb.insertData('''
                  INSERT INTO plants(name, date) VALUES("$plantName","${DateTime.now().toString()}")
                    ''');
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    _timer.cancel();
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        Plant plant = Plant(
                            snapshot.data![index]['name'],
                            snapshot.data![index]['date'],
                            snapshot.data![index]['id']);
                        if (plant.getProgress() != 1.0 &&
                            _timer.isActive == false) {
                          _timer =
                              Timer.periodic(Duration(seconds: 1), (timer) {
                            setState(() {});
                          });
                        }
                        return PlantWidget(plant, _sqldb, setState);
                      },
                    );
                  } else {
                    return const Center();
                  }
                },
                future: readData(),
              ),
            ),
            if (_bannerAd != null && _isLoaded)
              SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _loadAd() async {
    // Only load an ad if the Mobile Ads SDK has gathered consent aligned with
    // the app's configured messages.
    var canRequestAds = await _consentManager.canRequestAds();
    if (!canRequestAds) {
      return;
    }
    if (!mounted) {
      return;
    }
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      // Unable to get width of anchored banner.
      return;
    }

    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  /// Redraw the app bar actions if a privacy options entry point is required.
  void _getIsPrivacyOptionsRequired() async {
    if (await _consentManager.isPrivacyOptionsRequired()) {
      setState(() {
        _isPrivacyOptionsRequired = true;
      });
    }
  }
  /// Initialize the Mobile Ads SDK if the SDK has gathered consent aligned with
  /// the app's configured messages.
  void _initializeMobileAdsSDK() async {
    if (_isMobileAdsInitializeCalled) {
      return;
    }

    if (await _consentManager.canRequestAds()) {
      _isMobileAdsInitializeCalled = true;

      // Initialize the Mobile Ads SDK.
      MobileAds.instance.initialize();

      // Load an ad.
      _loadAd();
    }
  }
}