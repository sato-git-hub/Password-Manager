### ***⚠️developブランチには、STEP3までの機能と+aで追加機能を加えました。⚠️***

#### 追加機能、こだわったポイント
 - パスワードマネージャー起動時のパスワード認証機能を追加
 - gpg agentの設定を変更し、パスワードのキャッシュを無効化したことで、起動時には毎回パスワード認証が行われる
 - パスワードマネージャーの起動時に行う暗号、復号化以外は、すべて自動化
 - 暗号、復号化された際に画面に表示されるgpgのログを非表示化
 - `Add Password`と入力されたのが初めてではない場合、以前に`Add Password`で入力された情報を引き継ぐ
 - パスワード設定中は入力文字を非表示化

## ***1. パスワードマネージャーの起動*** 
#### ・ コマンドに`./password_manager.sh`と入力し、パスワードマネージャーを起動

#### ・ 初めて起動する時
```
if [[ ! -f key.txt.gpg ]]; then
```
 - パスワードマネージャーのパスワードを設定する
```
read -sp "パスワードマネージャーのパスワードを設定してください:" add_key
```
 - 設定したパスワードを使って空文字を暗号化
```
if echo "" | gpg --batch --yes --passphrase "$add_key" -c -o key.txt.gpg 2>/dev/null; then
```
 - パスワード設定後はパスワードマネージャーが終了する
```
exit 0
```

#### ・ 2回目以降の起動時
 - パスワードマネージャーのパスワードを入力する
  - 入力されたパスワードは`変数$key`に格納される 
```
read -sp "パスワードマネージャーのパスワードを入力してください:" key
```
 - `変数$key`を使って、パスワードを設定したときに暗号化した空文字を復号化する
```
if gpg --batch --yes --passphrase "$key" -d key.txt.gpg > /dev/null 2>&1; then
```
 - 復号化が成功した場合 パスワード認証が完了

 - 復号化ができなかった場合、パスワードマネージャーを終了する
 
## ***2. `次の選択肢から入力してください(Add Password/Get Password/Exit)`というメニューが表示されて、Exit が入力されるまではプログラムは終了せず、メニューが繰り返し表示される***

## ***3. `Add Password`が入力された時***

#### ・ パスワードマネージャーに登録するサービス名、ユーザー名、パスワードの入力が求められる

#### ・ `Add Password`と入力されたのが、2回目以降の場合(password.txt.gpgが存在してた場合)
```
if [[ -f password.txt.gpg ]]; then
```
 - `変数$key`を使ってpassword.txt.gpgファイルを復号化し、password.txtファイルに保存
```
gpg --batch --yes --passphrase "$key" -d password.txt.gpg > password.txt 2>/dev/null
```
#### ・ 入力されたサービス名、ユーザー名、パスワードは、`サービス名:ユーザー名:パスワード`という形式でpassword.txtファイルに追記されて保存

#### ・ `変数$key`を使ってpassword.txtファイルを暗号化
```
gpg --batch --yes --passphrase "$key" -c password.txt 2>/dev/null
```
#### ・ password.txtを削除
```
rm -rf password.txt
```

## ***4. Get Password が入力された時***

#### ・ サービス名の入力が求められる

####　・`変数$key`を使ってpassword.txt.gpgファイルを復号化し、password.txtファイルに保存
`
gpg --batch --yes --passphrase "$key" -d password.txt.gpg > password.txt 2>/dev/null
`
#### ・　入力されたサービス名が行頭にある行が、`password.txt`ファイル内にあった場合

 - 該当した行のテキストを`:`で分割し、サービス名、ユーザー名、パスワードを画面に表示
   
#### ・　入力されたサービス名が行頭にある行が、`password.txt`ファイル内にない場合
 - サービスが登録されていないというメッセージが表示される

#### ・ password.txtを削除

## ***5. Exitが入力された時***

#### ・ ループ処理から抜ける


## ***6. 選択肢に該当のない入力をされた時***

 #### ・ もう一度入力し直すように、メッセージが表示される












































































