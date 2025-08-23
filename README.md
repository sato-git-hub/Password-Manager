### ⚠️developブランチには、STEP3までの機能と+aで追加機能を加えました。⚠️

#### 開発環境
 - **OS**：Linux
 - **ディストリビューション**：Ubuntu
 - **シェル**：Bash
 - **暗号化ツール**：GPG（GNU Privacy Guard）

#### 追加機能、こだわったポイント
 - パスワードマネージャー起動時のパスワード設定機能（サインアップ）、パスワード認証機能（ログイン）を追加
 - gpg agentの設定を変更し、パスワードのキャッシュを無効化したことで、起動時には毎回パスワード認証が行われる
 - パスワードマネージャーの起動時に行う暗号、復号化以外は、gpgコマンドの`--batch` オプションを使って、暗号化、復号化の自動化
 - 暗号化、復号化された際に画面に表示されるgpgのログを非表示化
 - `Add Password`と2回目以降に入力した場合も、以前に登録した情報は消去されず保持される
 - パスワード認証中は入力文字を非表示化

## 1. パスワードマネージャーの起動
### ・ シェルに`./password_manager.sh`と入力し、パスワードマネージャーを起動

### ・ 初めて起動する時は、パスワードマネージャーのパスワードを設定する

- `key.txt.gpg`ファイルが存在しない場合
```
if [[ ! -f key.txt.gpg ]]; then
```
- 任意のパスワードの設定が求められ、設定したパスワードは変数`$add_key`に格納される
```
read -sp "パスワードマネージャーのパスワードを設定してください:" add_key
```
- 設定したパスワード`$add_key`を使って空文字("")を暗号化し、key.txt.gpgファイルに保存する
```
if echo "" | gpg --batch --yes --passphrase "$add_key" -c -o key.txt.gpg 2>/dev/null; then
```
- 暗号化とkey.txt.gpgファイルへの保存が成功した場合、パスワードマネージャーが終了する
```
echo "パスワードの設定が完了しました"
exit 0
```
- 暗号化とkey.txt.gpgファイルへの保存が失敗した場合、パスワードマネージャーをエラー終了する
```
else
    echo "パスワードの設定失敗"
    exit 1
```

### ・ 2回目以降の起動時はパスワードマネージャーのパスワードを入力しパスワード認証を行う

- `key.txt.gpg`ファイルが存在した場合
```
else
```
- 設定したパスワードの入力が求められ、入力したパスワードは変数`$key`に格納される
```
read -sp "パスワードマネージャーのパスワードを入力してください:" key
```
- `変数$key`を使って、パスワードを設定したときに暗号化した空文字を復号化する
```
if gpg --batch --yes --passphrase "$key" -d key.txt.gpg > /dev/null 2>&1; then
```
- 復号化が成功した場合、パスワード認証が完了したメッセージが表示される
```
echo "パスワード認証が完了しました"
```
- 復号化ができなかった場合、パスワードマネージャーが終了する
```
else
    echo "パスワード認証失敗"
    exit 1
```
## 2. パスワードマネージャーのメニューの中から選択する

### `次の選択肢から入力してください(Add Password/Get Password/Exit)`というメニューの中から１つ選んで入力する。
- 入力された選択肢は変数`$select`に格納される
- 選択肢の`Exit` が入力されるまではパスワードマネージャーは終了せず、メニューが繰り返し表示される

```
while true; do
 read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select
```
### `Add Password`が入力された場合

#### 変数`$select`が`Add Password`と一致した場合
```
if [[ "$select" == "Add Password" ]]; then
```
- パスワードマネージャーに登録するサービス名、ユーザー名、パスワード（以下情報という）の入力が求められる
```
read -p "サービス名を入力してください：" add_service
read -p "ユーザー名を入力してください：" add_user
read -p "パスワードを入力してください：" add_password

```
- password.txt.gpgファイルが存在している場合（`Add Password`と入力されたのが2回目以降の場合）
- `変数$key`を使ってpassword.txt.gpgファイルを復号化し、password.txtファイルに保存
```
if [[ -f password.txt.gpg ]]; then

    gpg --batch --yes --passphrase "$key" -d password.txt.gpg > password.txt 2>/dev/null
```
- 入力された情報は、`サービス名:ユーザー名:パスワード`という形式でpassword.txtファイルに追記されて保存
```
echo "$add_service:$add_user:$add_password" >> password.txt
```
- `変数$key`を使ってpassword.txtファイルを暗号化
```
gpg --batch --yes --passphrase "$key" -c password.txt 2>/dev/null
```
- password.txtを削除
```
rm -rf password.txt
```

### Get Password が入力された場合

#### 変数`$select`が`Get Password`と一致した場合
```
if [[ "$select" == “Get Password" ]]; then
```
#### 閲覧したい情報のサービス名の入力が求められる。
#### 入力されたサービス名は変数`$get_service`に格納される。
```
read -p "サービス名を入力してください：" get_service
```
#### `変数$key`を使ってpassword.txt.gpgファイルを復号化し、password.txtファイルに保存
```
gpg --batch --yes --passphrase "$key" -d password.txt.gpg > password.txt 2>/dev/null
```
#### 入力されたサービス名が行頭にある行が、`password.txt`ファイル内にあった場合
- 該当した行のテキストを`:`で分割し、サービス名、ユーザー名、パスワードを画面に表示
```
if grep -q "^$get_service" password.txt; then

    IFS=":" read -r -a array <<< $(grep "^$get_service" password.txt)
    echo "サービス名：" ${array[0]}
    echo "ユーザー名：" ${array[1]}
    echo "パスワード：" ${array[2]}

```
#### 入力されたサービス名が行頭にある行が、`password.txt`ファイル内にない場合
- サービスが登録されていないというメッセージが表示される
```
else
    echo "そのサービスは登録されていません。"
```

#### password.txtを削除
```
rm -rf password.txt
```
### Exitが入力された場合
#### 変数`$select`が`Exit`と一致した場合
```
elif [[ "$select" == "Exit" ]]; then
```
- ループ処理から抜ける、パスワードマネージャーを終了する
```
echo "Thank you!"
exit 0
```

### 選択肢に該当のない入力をされた場合

#### 選択肢にあてはまなければ
```
else
```
- もう一度入力し直すように、メッセージが表示される
```
echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
```
































































































































































































