import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:path_provider/path_provider.dart';
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
      title: 'Offline Map',
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
      home: const MyHomePage(title: 'Offline Map'),
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

  // オンライン時に表示するマップ オブジェクト格納用
  ArcGISMap? _onlineMap;
  // ベクター タイルを表示するためのレイヤー オブジェクト
  ArcGISVectorTiledLayer? _vectorTiledLayer;
  // ベクター タイルをダウンロードする際に使用するジョブ
  ExportVectorTilesJob? _exportVectorTilesJob;
  // ローディングバー (LinearProgressIndicator) の表示フラグ
  bool _loading = false;

  void _onMapViewReady() {
    // ポータルのアイテム ID からベクター タイル レイヤーを作成します。
    final portal = Portal(
      Uri.parse('https://www.arcgis.com'),
    );
    final portalItem = PortalItem.withPortalAndItemId(
        portal: portal, itemId: "aa3f471a985641e094549ef472adec18");
    _vectorTiledLayer = ArcGISVectorTiledLayer.withItem(portalItem);

    // ベクター タイル レイヤーをベースマップのレイヤーにしてマップを作成します。
    final basemap = Basemap.withBaseLayer(_vectorTiledLayer);
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

    // オンラインマップへの切替用に、現在のマップ状態を保存します。
    _onlineMap = map;
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
              child: Stack(
                children: [
                  ArcGISMapView(
                    controllerProvider: () => _mapViewController,
                    onMapViewReady: _onMapViewReady,
                  ),
                  Visibility(
                    visible: _loading,
                    child: SizedBox.expand(
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: Center(
                          child: LinearProgressIndicator(minHeight: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // オンラインマップとオフラインマップの表示を切り替えるボタンを追加します。
              children: [
                ElevatedButton(
                  onPressed: takeOnline,
                  child: const Text('オンライン表示'),
                ),
                SizedBox(width: 5.0),
                ElevatedButton(
                  onPressed: takeOffline,
                  child: const Text('オフラインマップ作成'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void takeOnline() {
    _mapViewController.arcGISMap = _onlineMap;
  }

  // 「オフラインマップ作成」ボタンを選択したときの処理
  void takeOffline() async {
    if (_mapViewController.arcGISMap != _onlineMap) return;

    // インジケーターを表示します。
    setState(() => _loading = true);

    // ダウンロードしたベクター タイルを保存するためのディレクトリを準備します。
    final directory = await getApplicationDocumentsDirectory();
    final resourceDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}offline',
    );
    if (resourceDirectory.existsSync()) {
      resourceDirectory.deleteSync(recursive: true);
    }
    resourceDirectory.createSync(recursive: true);
    final resourceDirectoryPath = resourceDirectory.path;
    final vtpkFile = File(
      '$resourceDirectoryPath${Platform.pathSeparator}basemap.vtpk',
    );

    // ベクター タイル レイヤーの URL をパラメーターに設定してタスクを作成・ロードします。
    final vectorTilesExportTask = ExportVectorTilesTask.withUri(
      _vectorTiledLayer!.uri!,
    );
    await vectorTilesExportTask.load();

    // 現在のマップの表示範囲を取得します (この範囲のベクタータイルをダウンロードします)。
    final downloadArea = _mapViewController.visibleArea!.extent;
    // タスク実行時に使用するパラメータを作成します。
    final exportVectorTilesParameters =
        await vectorTilesExportTask.createDefaultExportVectorTilesParameters(
      areaOfInterest: downloadArea,
      maxScale: _mapViewController.scale,
    );

    // パラメータとダウンロード先を設定してタスクのジョブ (ExportVectorTilesJob) を作成します。
    _exportVectorTilesJob =
        vectorTilesExportTask.exportVectorTilesWithItemResourceCache(
      parameters: exportVectorTilesParameters,
      vectorTileCacheUri: vtpkFile.uri,
      itemResourceCacheUri: Uri.directory(resourceDirectoryPath),
    );

    try {
      // ジョブを開始して、ジョブの結果を取得します。
      final result = await _exportVectorTilesJob?.run();

      // ジョブが成功したら、ダウンロードしたベクター タイルとベクター タイルのスタイルを取得します。
      final vectorTilesCache = result?.vectorTileCache;
      final itemResourceCache = result?.itemResourceCache;
      if (vectorTilesCache == null || itemResourceCache == null) {
        showErrorDialog('ベクター タイル キャッシュ または アイテム リソース キャッシュが無効です');
        return;
      }

      // ダウンロードしたベクター タイルからベクター タイル レイヤーを作成します。
      final localVectorTileLayer = ArcGISVectorTiledLayer.withVectorTileCache(
        vectorTilesCache,
        itemResourceCache: itemResourceCache,
      );
      // ベクター タイル レイヤーを追加したベースマップから、オフライン用のマップを作成します。
      _mapViewController.arcGISMap = ArcGISMap.withBasemap(
        Basemap.withBaseLayer(localVectorTileLayer),
      );
    } on ArcGISException catch (e) {
      showErrorDialog(e.message);
    } finally {
      _exportVectorTilesJob = null;
    }

    // インジケーターを非表示にします。
    setState(() {
      _loading = false;
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Info', style: Theme.of(context).textTheme.titleMedium),
        content: Text('ベクター タイルのダウンロードに失敗しました:\n$message'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
