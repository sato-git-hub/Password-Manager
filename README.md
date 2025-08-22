### ***⚠️ mainブランチには、パスワードマネージャーSTEP2までの機能を載せました。***
### ***developブランチには、STEP3までの機能と+aで追加機能を加えました。***
### ***developブランチの方もご覧いただければ幸いです。⚠️***


　　

## 1. シェルスクリプトを実行すると、メニューが表示される 
#### Exit が入力されるまではプログラムは終了せず、「次の選択肢から入力してください(Add Password/Get Password/Exit)：」が繰り返される 
`
while true; do
 read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select
`
## ***2. Add Password が入力された時***
`
 if [[ "$select" == "Add Password" ]]; then
`
#### サービス名、ユーザー名、パスワードの入力が求められる
 `
  read -p "サービス名を入力してください：" add_service
  read -p "ユーザー名を入力してください：" add_user
  read -p "パスワードを入力してください：" add_password
`

#### 入力された情報は`サービス名:ユーザー名:パスワード`という形式で`password.txt`ファイルの最後の行に追記されて保存
`
  echo "$add_service:$add_user:$add_password" >> password.txt
`

## ***3. Get Password が入力された時***
`
 elif [[ "$select" == "Get Password" ]]; then
`

#### サービス名の入力が求められる
` 
read -p "サービス名を入力してください：" get_service
`

#### 入力されたサービス名が行頭にある行が、保存されたファイル内にあれば
#### 該当した行のテキストを`:`で分割し変数`$array`に格納
#### サービス名、ユーザー名、パスワードを表示
`
if grep -q "^$get_service" password.txt; then
`
`
   IFS=":" read -r -a array <<< $(grep "^$get_service" password.txt)
`
`
   echo "サービス名：" ${array[0]}
   echo "ユーザー名：" ${array[1]}
   echo "パスワード：" ${array[2]}
`

#### 入力されたサービス名が行頭にある行が、保存されたファイル内にない場合
`
else
   echo "そのサービスは登録されていません。"
`

## ***4. Exitが入力された時***
`elif [[ "$select" == "Exit" ]]; then
`
#### ループ処理から抜ける
`
  exit 0
`

## ***5. 選択肢に該当のない入力をされた時***
`
else
  echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
`





























