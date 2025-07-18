import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
      title: 'Add Shapefile',
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
      home: const MyHomePage(title: 'Add Shapefile'),
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
  // マップビューのコントローラーを作成します。
  final _mapViewController = ArcGISMapView.createController();

  Future<void> _onMapViewReady() async {
    // ベースマップのラベルを日本語表記にするためのパラメーターを設定します。
    final bsp = BasemapStyleParameters();
    bsp.specificLanguage = "ja";

    // 道路地図のベースマップ スタイルを使用してマップを作成します。
    final basemap =
        Basemap.withStyle(BasemapStyle.arcGISDarkGray, parameters: bsp);
    final map = ArcGISMap.withBasemap(basemap);

    // 緯度経度とスケールを指定してマップの初期表示位置を指定します。
    final initialPoint = ArcGISPoint(
      x: 140.123154,
      y: 35.604560,
      spatialReference: SpatialReference.wgs84,
    );

    map.initialViewpoint = Viewpoint.fromCenter(initialPoint, scale: 10000);

    // マップビュー コントローラーに作成したマップを設定します。
    _mapViewController.arcGISMap = map;

    // assets フォルダにあるシェープファイルから、ドキュメントディレクトリに新たにシェープファイルを作成します。
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final fileAssetsList = assetManifest
        .listAssets()
        .where((string) => string.startsWith("assets/shp/"))
        .toList();
    for (int i = 0; i < fileAssetsList.length; i++) {
      String filePath = fileAssetsList[i];
      final byteData = await rootBundle.load(filePath);
      final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$filePath',
      );
      await file.create(recursive: true);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    }

    final shapefile = File(
      '${(await getApplicationDocumentsDirectory()).path}/assets/shp/random_points.shp',
    );

    // ドキュメントディレクトリにあるシェープファイルのパスから ShapefileFeatureTable を作成します。
    final shapefileFeatureTable = ShapefileFeatureTable.withFileUri(
      shapefile.uri,
    );
    await shapefileFeatureTable.load();
    final shapefileFeatureLayer = FeatureLayer.withFeatureTable(
      shapefileFeatureTable,
    );
    await shapefileFeatureLayer.load();

    // 各属性値用のシンボルを作成します。
    final redMarkerSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: Colors.red,
      size: 10,
    );
    final blueMarkerSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: Colors.blue,
      size: 10,
    );
    final yellowMarkerSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: Colors.yellow,
      size: 10,
    );
    final defaultMarkerSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: Colors.black,
      size: 10,
    );

    // name フィールドの属性値に応じて色分け表示（a は赤色、b は青色、c は黄色）するための、UniqueValueRenderer を作成します。
    final aValue = UniqueValue(
      description: 'name is a',
      label: 'a',
      symbol: redMarkerSymbol,
      values: ['a'],
    );

    final bValue = UniqueValue(
      description: 'name is b',
      label: 'b',
      symbol: blueMarkerSymbol,
      values: ['b'],
    );

    final cValue = UniqueValue(
      description: 'name is c',
      label: 'c',
      symbol: yellowMarkerSymbol,
      values: ['c'],
    );

    final uniqueValueRenderer = UniqueValueRenderer(
      fieldNames: ['name'],
      uniqueValues: [aValue, bValue, cValue],
      defaultLabel: 'Other',
      defaultSymbol: defaultMarkerSymbol,
    );

    // 個別値分類レンダラーをシェープファイルのレイヤーに適用して、マップに追加します。
    shapefileFeatureLayer.renderer = uniqueValueRenderer;

    _mapViewController.arcGISMap!.operationalLayers.add(shapefileFeatureLayer);
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
            Expanded(
              // ウィジェット ツリーにマップビューを追加し、コントローラーを設定します。
              child: ArcGISMapView(
                controllerProvider: () => _mapViewController,
                onMapViewReady: _onMapViewReady,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
