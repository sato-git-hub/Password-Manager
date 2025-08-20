#!/bin/bash

 echo "パスワードマネージャーへようこそ！"

while true; do
 read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select

 if [[ "$select" == "Add Password" ]]; then

     read -p "サービス名を入力してください：" add_service
     read -p "ユーザー名を入力してください：" add_user
     read -p "パスワードを入力してください：" add_password

  #password.txt.gpgが存在してたら
  if [[ -f password.txt.gpg ]]; then

      echo "a" | gpg --batch --yes --passphrase-fd 0 -d password.txt.gpg > password.txt

  fi

  echo "$add_service:$add_user:$add_password" >> password.txt

  #password.txt.gpgに一行追加することができない

  echo "a" | gpg --batch --yes --passphrase-fd 0 -c password.txt

  rm -rf password.txt

  echo "パスワードの追加は成功しました。"
  echo "Thank you!"

 elif [[ "$select" == "Get Password" ]]; then

  read -p "サービス名を入力してください：" get_service

  echo "a" | gpg --batch --yes --passphrase-fd 0 -d password.txt.gpg > password.txt

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
