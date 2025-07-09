import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

void main() {
  ArcGISEnvironment.apiKey = '作成した API キーをここに入力';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geocoding',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Geocoding'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textEditingController = TextEditingController(text: '東京都千代田区平河町2-7-1');
  final _searchFocusNode = FocusNode();

    //ジオコードサービスの URL を指定して、ジオコーディング用のタスクを作成します。
  final _locatorTask = LocatorTask.withUri(
    Uri.parse(
      'https://geocode-api.arcgis.com/arcgis/rest/services/World/GeocodeServer',
    ),
  );

  // マップビューのコントローラーを作成します。
  final _mapViewController = ArcGISMapView.createController();

  void _onMapViewReady() {
    // ベースマップのラベルを日本語表記にするためのパラメーターを設定します。
    final bsp = BasemapStyleParameters();
    bsp.specificLanguage = "ja";

    // 道路地図のベースマップ スタイルを使用してマップを作成します。
    final basemap = Basemap.withStyle(
      BasemapStyle.arcGISStreets,
      parameters: bsp
    );
    final map = ArcGISMap.withBasemap(basemap);

    // 緯度経度とスケールを指定してマップの初期表示位置を指定します。
    final initialPoint = ArcGISPoint(
      x: 139.745461,
      y: 35.65856,
      spatialReference: SpatialReference.wgs84,
    );

    map.initialViewpoint = Viewpoint.fromCenter(initialPoint, scale: 10000);

    // マップビュー コントローラーに作成したマップを設定します。
    _mapViewController.arcGISMap = map;

    // 後の作業でマップ上にシンボルを追加するために使用するグラフィックス オーバーレイを作成し、それをマップビュー コントローラーに追加します。
    final graphicsOverlay = GraphicsOverlay();
    _mapViewController.graphicsOverlays.add(graphicsOverlay);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                focusNode: _searchFocusNode,
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: '住所を入力...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: dismissSearch,
                    icon: const Icon(Icons.clear),
                  ),
                ),
                onSubmitted: onSearchSubmitted,
              ),

              Expanded(
                // ウィジェット ツリーにマップビューを追加し、コントローラーを設定します。
                child: ArcGISMapView(
                  controllerProvider: () => _mapViewController,
                  onMapViewReady: _onMapViewReady,
                  onTap: onSearchTap,
                ),
              ),
            ],
          ),
      ),
    );
  }

  void onSearchSubmitted(String value) async {
    // ジオコーディング（文字列から座標を取得）用の検索パラメーターを作成します。
    final geocodeParameters = 
        GeocodeParameters()
          ..outputSpatialReference = _mapViewController.spatialReference;

    // TextField に入力された文字列をもとにジオコーディングを実行して結果を取得します。
    final geocodeResult = await _locatorTask.geocode(
      searchText: value,
      parameters: geocodeParameters,
    );
    if (geocodeResult.isEmpty) return;
    final firstResult = geocodeResult.first;

    // 結果の座標にアイコンを表示して、中心になるようにマップを移動します。
    final pictureMarkerSymbol = PictureMarkerSymbol.withUri(
      Uri.parse(
        "https://static.arcgis.com/images/Symbols/Shapes/BlueStarLargeB.png",
      ),
    );
    pictureMarkerSymbol.height = 50;
    pictureMarkerSymbol.width = 50;
    final graphic = Graphic(
      geometry: firstResult.displayLocation,
      symbol: pictureMarkerSymbol,
    );
    _mapViewController.graphicsOverlays[0].graphics.add(graphic);
    _mapViewController.setViewpointCenter(firstResult.displayLocation!);
  }

  void dismissSearch() {
    // テキスト フィールドをクリアして、キーボードを閉じます。
    setState(() => _textEditingController.clear());
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void onSearchTap(Offset localPosition) async {
    // 既存のグラフィックスを削除します。
    final graphicsOverlay = _mapViewController.graphicsOverlays[0];
    if (graphicsOverlay.graphics.isNotEmpty) graphicsOverlay.graphics.clear();

    // スクリーン ポイントをマップ ポイントに変換します。
    final mapTapPoint = _mapViewController.screenToLocation(
      screen: localPosition,
    );
    if (mapTapPoint == null) return;

    // タップした場所を示すグラフィックス オブジェクトを作成します。
    graphicsOverlay.graphics.add(Graphic(geometry: mapTapPoint));

    // リバースジオコード（座標から住所を取得）用の検索パラメーターを作成します。
    final reverseGeocodeParameters = ReverseGeocodeParameters()..maxResults = 1;

    // タップした場所とパラメーターを使用してリバースジオコーディングを実行します。
    final reverseGeocodeResult = await _locatorTask.reverseGeocode(
      location: mapTapPoint,
      parameters: reverseGeocodeParameters,
    );
    if (reverseGeocodeResult.isEmpty) return;

    // 結果から住所文字列を取得してダイアログに表示します。
    final firstResult = reverseGeocodeResult.first;
    final addressString = firstResult.label;

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(content: Text(addressString));
        },
      );
    }
  }
}
