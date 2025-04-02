import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'dart:math';

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
      title: 'Device Location',
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
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Device Location'),
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

  bool _isLocationStarted = true;

  void _onMapViewReady() async {
    // ベースマップのラベルを日本語表記にするためのパラメーターを設定します。
    final bsp = BasemapStyleParameters();
    bsp.specificLanguage = "ja";

    // 道路地図のベースマップ スタイルを使用してマップを作成します。
    final basemap =
        Basemap.withStyle(BasemapStyle.arcGISStreets, parameters: bsp);
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

    // システムの位置情報サービスの現在位置をマップ上に表示するように設定します。
    _mapViewController.locationDisplay.dataSource = SystemLocationDataSource();
    // AutoPanMode モード（Off/Recenter/Navigation/Compass）の値を設定します。
    _mapViewController.locationDisplay.autoPanMode =
        LocationDisplayAutoPanMode.recenter;

    // 位置情報の取得を開始します（これにより、ユーザーに許可を求めるプロンプトが表示されます）。
    try {
      await _mapViewController.locationDisplay.dataSource.start();
    } on ArcGISException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text(e.message)),
        );
      }
    }
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
            locationSettings(context),
          ],
        ),
      ),
    );
  }

  Widget locationSettings(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.0,
        20.0,
        20.0,
        max(
          20.0,
          View.of(context).viewPadding.bottom /
              View.of(context).devicePixelRatio,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '表示設定',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
            ],
          ),
          Row(
            children: [
              const Text('ロケーションの表示'),
              const Spacer(),
              // 位置情報の取得を開始および停止するためのスイッチです。
              Switch(
                value: _isLocationStarted,
                onChanged: (value) {
                  setState(() {
                    if (_mapViewController.locationDisplay.dataSource.status ==
                        LocationDataSourceStatus.started) {
                      _mapViewController.locationDisplay.stop();
                      _isLocationStarted = false;
                    } else {
                      _mapViewController.locationDisplay.start();
                      _isLocationStarted = true;
                    }
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text('Auto-Pan モード'),
              const Spacer(),
              // AutoPanMode を選択するためのドロップダウン ボタンです。
              DropdownButton(
                value: _mapViewController.locationDisplay.autoPanMode,
                onChanged: (value) {
                  setState(() {
                    _mapViewController.locationDisplay.autoPanMode = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: LocationDisplayAutoPanMode.off,
                    child: Text('Off'), // 現在位置のシンボルをマップ上に表示するのみ
                  ),
                  DropdownMenuItem(
                    value: LocationDisplayAutoPanMode.recenter,
                    child: Text('Recenter'), // 現在位置が中心になるようにマップをズーム
                  ),
                  DropdownMenuItem(
                    value: LocationDisplayAutoPanMode.navigation,
                    child: Text(
                        'Navigation'), // 現在位置を常にマップの下部に表示して、端末の進行方向によってマップを回転
                  ),
                  DropdownMenuItem(
                    value: LocationDisplayAutoPanMode.compassNavigation,
                    child: Text(
                        'Compass'), // 現在位置を常にマップの中心に表示して、端末の向いている方向によってマップを回転
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
