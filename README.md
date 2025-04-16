# arcgis-samples-flutter

## 概要
[ArcGIS Maps SDK for Flutter](https://www.esrij.com/products/arcgis-maps-sdk-for-flutter/) のサンプル集です。
  
## サンプル
* [マップ表示とマーカー表示](flutter_map_application)
* [デバイスの位置情報サービスと連動したマップ表示](device_location)
* [住所検索](geocoding)
* [シェープファイルの表示](add_shapefile)
* [オフラインマップの表示](offline_map)

## インストール
次のコマンドを実行して arcgis_maps_core をダウンロードしてインストールします。

```
dart run arcgis_maps install
```

Windows を使用している場合は、この手順にシンボリックリンクを作成する権限が必要です。管理者権限でログインしたコマンドプロンプトでこの手順を実行するか、「設定」>「プライバシーとセキュリティ」>「開発者向け」に移動して「開発者モード」をオンにしてください。
## 使用方法
各サンプルの main.dart ファイルの main 関数にある ArcGISEnvironment.apiKey に自身の API キー を入力してください。
API キーの作成 には [開発者アカウントの作成](https://esrijapan.github.io/arcgis-dev-resources/guide/get-dev-account/) が必要です。API キーの作成 には [API キーの取得](https://esrijapan.github.io/arcgis-dev-resources/guide/get-api-key/) をご確認ください。
本リポジトリで提供しているサンプルコードを実行するには、[ベースマップ] -> [ベースマップ スタイル サービス] と [ジオコーディング] -> [ジオコード (未保存)] の権限が必要です

## 動作確認した環境
本サンプルの動作確認は、下記の環境で実施しています。 
* ArcGIS Maps SDK for Flutter 200.6  
* Flutter 3.27.3
* Dart 3.6.1
* Android Studio Hedgehog 2023.1.1 

## リソース
* [ArcGIS Maps SDK for Flutter (ESRIジャパン)](https://www.esrij.com/products/arcgis-maps-sdk-for-flutter/)
* [ArcGIS Maps SDK for Flutter (米国Esri社)](https://developers.arcgis.com/flutter/)
* [ArcGIS Developers 開発リソース集](https://esrijapan.github.io/arcgis-dev-resources/)

## ライセンス
Copyright 2025 Esri Japan Corporation.

Apache License Version 2.0（「本ライセンス」）に基づいてライセンスされます。あなたがこのファイルを使用するためには、本ライセンスに従わなければなりません。
本ライセンスのコピーは下記の場所から入手できます。

> http://www.apache.org/licenses/LICENSE-2.0

適用される法律または書面での同意によって命じられない限り、本ライセンスに基づいて頒布されるソフトウェアは、明示黙示を問わず、いかなる保証も条件もなしに「現状のまま」頒布されます。本ライセンスでの権利と制限を規定した文言については、本ライセンスを参照してください。

ライセンスのコピーは本リポジトリの[ライセンス ファイル](./LICENSE)で利用可能です。
