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

#### 使い方
1. シェルに`./password_manager.sh`と入力し、パスワードマネージャーを起動
2. 初回起動時: パスワードマネージャーのパスワードを設定を行う。設定完了後は、パスワードマネージャーが終了する　
3. 2回目以降: パスワードを入力しパスワード認証を行う
4. `(Add Password/Get Password/Exit)`というメニューの中から１つ選んで入力
   - Add Password: パスワードマネージャーにサービス名、ユーザー名、パスワード（以下情報という）を新規登録
   - Get Password: パスワードマネージャーに登録されている情報を閲覧
   - Exit: パスワードマネージャーを終了


#### コードの内容説明

## パスワードの設定

- `key.txt.gpg`ファイルが存在しない場合、パスワードを設定（変数`$add_key`）
```
if [[ ! -f key.txt.gpg ]]; then

    read -sp "パスワードマネージャーのパスワードを設定してください:" add_key
```
- `$add_key`を使って空文字("")を暗号化（保存先: password.txt.gpg）
```
if echo "" | gpg --batch --yes --passphrase "$add_key" -c -o key.txt.gpg 2>/dev/null; then
```
- 成功した場合は設定完了メッセージの表示とパスワードマネージャーの終了
```
echo "パスワードの設定が完了しました"
exit 0
```
- 失敗した場合は設定失敗メッセージの表示とパスワードマネージャーをエラー終了する
```
else
    echo "パスワードの設定失敗"
    exit 1
```
## パスワード認証

- `key.txt.gpg`ファイルが存在した場合、設定したパスワードを入力（変数`$key`）
```
else
    read -sp "パスワードマネージャーのパスワードを入力してください:" key
```
- `$key`を使って、パスワードを設定したときに暗号化した空文字を復号化
```
if gpg --batch --yes --passphrase "$key" -d key.txt.gpg > /dev/null 2>&1; then
```
- 成功した場合、認証完了メッセージの表示
```
echo "パスワード認証が完了しました"
```
- 失敗した場合、認証失敗メッセージの表示とパスワードマネージャーをエラー終了する
```
else
    echo "パスワード認証失敗"
    exit 1
```
## パスワードマネージャーのメニュー選択

- メニューの中から１つ選んで入力する。（変数`$select`）
- 選択肢の`Exit` が入力されるまではパスワードマネージャーは終了せず、メニューが繰り返し表示される

```
while true; do
 read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select
```
## `Add Password`が入力された場合

- `$select`が`Add Password`と一致した場合
```
if [[ "$select" == "Add Password" ]]; then
```
- パスワードマネージャーに登録する情報を入力
```
read -p "サービス名を入力してください：" add_service
read -p "ユーザー名を入力してください：" add_user
read -p "パスワードを入力してください：" add_password

```
- `password.txt.gpg`ファイルが存在している場合
- `変数$key`を使って`password.txt.gpg`ファイルを復号化（保存先: password.txt）
```
if [[ -f password.txt.gpg ]]; then

    gpg --batch --yes --passphrase "$key" -d password.txt.gpg > password.txt 2>/dev/null
```
- `サービス名:ユーザー名:パスワード`という形式で追記される（保存先: password.txt）
```
echo "$add_service:$add_user:$add_password" >> password.txt
```
- `変数$key`を使って`password.txt`ファイルを暗号化（保存先: password.txt.gpg）
```
gpg --batch --yes --passphrase "$key" -c password.txt 2>/dev/null
```
- `password.txt`を削除
```
rm -rf password.txt
```
## `Get Password`が入力された場合

- `$select`が`Get Password`と一致した場合
```
if [[ "$select" == “Get Password" ]]; then
```
- 閲覧したい情報のサービス名の入力（変数`$get_service`）
```
read -p "サービス名を入力してください：" get_service
```
- `変数$key`を使って`password.txt.gpg`ファイルを復号化（保存先: password.txt）
```
gpg --batch --yes --passphrase "$key" -d password.txt.gpg > password.txt 2>/dev/null
```
- 入力されたサービス名が行頭にある行が、`password.txt`ファイル内にあった場合
- 該当した行のテキストを`:`で分割し、サービス名、ユーザー名、パスワードを画面に表示
```
if grep -q "^$get_service" password.txt; then

    IFS=":" read -r -a array <<< $(grep "^$get_service" password.txt)
    echo "サービス名：" ${array[0]}
    echo "ユーザー名：" ${array[1]}
    echo "パスワード：" ${array[2]}

```
- 入力されたサービス名が行頭にある行が、`password.txt`ファイル内にない場合
- サービスが登録されていないというメッセージが表示される
```
else
    echo "そのサービスは登録されていません。"
```
- `password.txt`を削除
```
rm -rf password.txt
```
## `Exit`が入力された場合

- `$select`が`Exit`と一致した場合
- パスワードマネージャーを終了する(ループ処理から抜ける)
```
elif [[ "$select" == "Exit" ]]; then

    echo "Thank you!"
    exit 0
```

## 選択肢に該当のない入力をされた場合

- 選択肢にあてはまなければ
- 選択肢の再入力を求めるメッセージを表示
```
else

    echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
```


































































































































































































