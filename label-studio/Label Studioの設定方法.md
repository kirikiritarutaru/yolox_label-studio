# Label Studioの設定方法

## ローカルにおいたデータを使ったプロジェクトの設定手順

-   公式のLabel Studio の docker イメージをpull
    -   `$ docker pull heartexlabs/label-studio:latest`
-   アノテーションしたいデータをまとめたフォルダ（ここでは images とする）の一つ上のディレクトリに移動
    -   下記のような形で、プロジェクトごとにフォルダ分けされているとLabel Studio内で扱うときに楽
        -   `images/project1`
        -   `images/project2`
-   docker コンテナでLabel Studioを稼働
    -   ローカルにおいているデータを使う場合は、環境変数をセット
        -   `$ docker run -it -p 8080:8080 --env LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED=true --env LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT=/label-studio -v ${pwd}/images:/label-studio/data/images heartexlabs/label-studio:latest`
    -   dockerコンテナ内の`/label-studio/data`以下にデータを全部入れるので、ROOTディレクトリは`/label-studio`に設定
-   `http://localhost:8080/`にアクセス
-   Label Studio内でプロジェクトを作成しセッティング
    -   Labeling Interface の設定
        -   Labeling Setupから"Object Detection with Bounding Boxes"を選択
    -   ローカルにおいているデータとの連携（結構めんどくさい）
        -   Settings → Cloud Storage → Source Cloud Storage → Add Source Storageをクリック
        -   Storage Type で Local files を選択
        -   Absolute local path で**dockerコンテナ内のディレクトリ** `/label-studio/data/images`を選択
        -   Treat every bucket object as a source file にチェック
        -   Check Connection → Add Storage
        -   Source Cloud Storage下にでた Sync Storageをクリック
            -   時間かかるかも
-   画像が取り込まれているのを確認したら、アノテーションを頑張る

## YOLOXでアノテーションしたラベルをつかって学習

-   Label StudioからCOCO形式でアノテーションしたラベルをエクスポート
-   [TODO] YOLOXを使って学習するところを追記予定

## 学習済みモデルで予測した結果をインポート

-   予測結果の準備

    -   COCO形式で予測結果を出力
        -   `result.json`とする
        -   "images", "categories", "predictions"があるCOCO形式のjsonファイルね

-   COCO形式→Label-Studioで取り扱う形式への変換

    -   label-studio-converterのインストール

    -   変換（ファイル名は適宜変えるべし）

        -   `label-studio-converter import coco -i result.json -o output.json --out-type predictions`
        -   `output.json`と`output.label_config.xml`が作成される

    -   *[注意]* label-studio-converterで出力されるjsonファイルでは、`--image-root-url`を設定しても反映されない

        -   下記の形になるようにjsonの中のファイルパスの修正

            -   TODO: `fix_img_path.py`を追加

        -   ```json
             "data": {
                "image": "/data/local-files/?d=data/images/penguin.jpg"
              }
            ```

            

-   Label Studioでの取り込み

    -   プロジェクトを作成

    -   Labelling Setupから"Object Detection with Bounding Boxes"を選択

    -   Codeを押して、label-studio-converterで出力されたxmlファイルの中身をコピペしSave

    -   **[注意] Add Source Storageでローカルファイルと連携するときに Sync Storageを押さない**

        -   Sync Storageを押すと、アノテーションも予測結果もないTaskとして勝手に登録されてしまう
        -   jsonファイルをアップロードして予測結果を連携するので、Sync Storageは必要ない！！
        -   https://labelstud.io/guide/storage#Tasks-with-local-storage-file-referencesをよく読んで
    
    -   Import を選択し、ファイルパスを修正したjsonファイルをインポート
    
    -   画像とともにpredictionsが表示されたら終了
    
        

