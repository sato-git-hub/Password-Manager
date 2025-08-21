#!/bin/bash

echo "パスワードマネージャーへようこそ！"

#初めてパスワードマネージャーを開いたとき

if [[ ! -f key.txt.gpg ]]; then

    read -sp "パスワードマネージャーのパスワードを設定してください:" add_key
    echo "$add_key" > key.txt
    gpg --batch --yes --passphrase "$add_key" -c key.txt 2>/dev/null
    rm -rf key.txt
    echo "パスワードの設定が完了しました"
    exit 0

# $add_keyリセット

else
    read -sp "パスワードマネージャーのパスワードを入力してください:" key

    #-d 復号内容が画面に表示
    if gpg --batch --yes --passphrase "$key" -d key.txt.gpg > /dev/null 2>&1; then
        echo
        echo "パスワード認証が完了しました"

    else
        echo
        echo "パスワード認証失敗"
        exit 1
    fi
fi

while true; do
 read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select

 if [[ "$select" == "Add Password" ]]; then

     read -p "サービス名を入力してください：" add_service
     read -p "ユーザー名を入力してください：" add_user
     read -p "パスワードを入力してください：" add_password

  #password.txt.gpgが存在してたら
  if [[ -f password.txt.gpg ]]; then
      echo "$key" | gpg --batch --yes --passphrase-fd 0 -d password.txt.gpg > password.txt 2>/dev/null

  fi

  echo "$add_service:$add_user:$add_password" >> password.txt

  #password.txt.gpgに一行追加することができない

  echo "$key" | gpg --batch --yes --passphrase-fd 0 -c password.txt 2>/dev/null

  rm -rf password.txt

  echo "パスワードの追加は成功しました。"
  echo "Thank you!"

 elif [[ "$select" == "Get Password" ]]; then

  read -p "サービス名を入力してください：" get_service

  echo "$key" | gpg --batch --yes --passphrase-fd 0 -d password.txt.gpg > password.txt 2>/dev/null

  if grep -q "^$get_service" password.txt; then

   IFS=":" read -r -a array <<< $(grep "^$get_service" password.txt)

   echo "サービス名：" ${array[0]}
   echo "ユーザー名：" ${array[1]}
   echo "パスワード：" ${array[2]}

  else
   echo "そのサービスは登録されていません。"
  fi

  rm -rf password.txt

 elif [[ "$select" == "Exit" ]]; then

  echo "Thank you!"
  exit 0

 else

  echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"

 fi
done
