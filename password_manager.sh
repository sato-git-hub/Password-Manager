#!/bin/bash

echo "パスワードマネージャーへようこそ！"
read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select

if [[ "$select" == "Add Password" ]]; then

 read -p "サービス名を入力してください：" add_service
 read -p "ユーザー名を入力してください：" add_user
 read -p "パスワードを入力してください：" add_password

 echo "パスワードの追加は成功しました。"
 echo "Thank you!"

fi
