### ***⚠️developブランチには、STEP3までの機能と+aで追加機能を加えました。⚠️***


　　
## ***1. パスワードマネージャーの起動*** 
#### コマンドに`./password_manager.sh`と入力

#### 初めて起動する時
```
if [[ ! -f key.txt.gpg ]]; then
```
 - パスワードマネージャーのパスワードを設定する
 - パスワード設定中は入力文字を非表示化
```
read -sp "パスワードマネージャーのパスワードを設定してください:" add_key
```
 - 設定したパスワードを使って空文字を自動暗号化
 - 暗号化された際に画面に表示されるgpgのログを非表示
```
if echo "" | gpg --batch --yes --passphrase "$add_key" -c -o key.txt.gpg 2>/dev/null; then
```
 - パスワード設定後はパスワードマネージャーが終了する
```
exit 0
```
 - 
#### 2回目以降の起動時
 - パスワードマネージャーのパスワードを入力する
 - パスワード入力中は入力文字を非表示化
```
read -sp "パスワードマネージャーのパスワードを入力してください:" key
```
 - 入力したパスワードを使って、パスワードを設定したときに暗号化した空文字を復号化する
```
if gpg --batch --yes --passphrase "$key" -d key.txt.gpg > /dev/null 2>&1; then
```
  - 復号化が成功した場合 2.に進む
```
echo "パスワード認証が完了しました"
```
　- 復号化ができなかった場合
  -パスワードマネージャーを終了する
  
``` 
echo "パスワード認証失敗"
exit 1
```
## ***2. `次の選択肢から入力してください(Add Password/Get Password/Exit)`というメニューが表示されて、Exit が入力されるまではプログラムは終了せず、メニューが繰り返し表示される***

## ***3. `Add Password`が入力された時***

#### 初めて`Add Password`が入力された時(password.txt.gpgが存在してた場合)
```
if [[ -f password.txt.gpg ]]; then
```
 - password.txt.gpgファイルを復号化し、password.txtファイルに保存
```
gpg --batch --yes --passphrase "$key" -d password.txt.gpg > password.txt 2>/dev/null
```
#### 入力された情報を暗号化
```
echo "$add_service:$add_user:$add_password" >> password.txt
```

#### サービス名、ユーザー名、パスワードの入力が求められる
 ```
  read -p "サービス名を入力してください：" add_service
  read -p "ユーザー名を入力してください：" add_user
  read -p "パスワードを入力してください：" add_password
```

#### 入力された情報は`サービス名:ユーザー名:パスワード`という形式で`password.txt`ファイルの最後の行に追記されて保存
```
  echo "$add_service:$add_user:$add_password" >> password.txt
```

## ***4. Get Password が入力された時***
```
 elif [[ "$select" == "Get Password" ]]; then
```

#### サービス名の入力が求められる
```
read -p "サービス名を入力してください：" get_service
```

#### 入力されたサービス名が行頭にある行が、`password.txt`ファイル内にあった場合
  
```
if grep -q "^$get_service" password.txt; then
```
 - 該当した行のテキストを`:`で分割し変数`$array`に格納
```
IFS=":" read -r -a array <<< $(grep "^$get_service" password.txt)
```
 - サービス名、ユーザー名、パスワードを表示
```
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

## ***5. Exitが入力された時***
```
elif [[ "$select" == "Exit" ]]; then
```
#### ループ処理から抜ける
```
  exit 0
```

## ***6. 選択肢に該当のない入力をされた時***

 #### もう一度入力し直すように、メッセージが表示される
```
else
  echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
```

































































