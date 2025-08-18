#!/bin/bash

echo "パスワードマネージャーへようこそ！"
read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select

if [[ "$select" == "Add Password" ]]; then

 read -p "サービス名を入力してください：" add_service
 read -p "ユーザー名を入力してください：" add_user
 read -p "パスワードを入力してください：" add_password

 echo "$add_service:$add_user:$add_password" >> password.txt

 echo "パスワードの追加は成功しました。"
 echo "Thank you!"

elif [[ "$select" == "Get Password" ]]; then

 read -p "サービス名を入力してください：" get_service

 if grep -q "^$get_service" password.txt; then

  IFS=":" read -r -a array <<< $(grep "^$get_service" password.txt)

  echo "サービス名：" ${array[0]}
  echo "ユーザー名：" ${array[1]}
  echo "パスワード：" ${array[2]}

 else
  echo "そのサービスは登録されていません。"

 fi


fi


