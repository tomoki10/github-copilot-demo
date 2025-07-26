#!/usr/bin/env python3
"""
Python環境テストスクリプト
MySQL接続とライブラリのテスト
"""

import sys
import mysql.connector

def test_python_environment():
    """Python環境をテストする"""
    print("🐍 Python環境テストを開始します...")
    print(f"Python version: {sys.version}")
    
    try:
        # mysql.connectorのインポートテスト
        print("✅ mysql-connector-python imported successfully")
        
        # MySQL接続テスト
        connection = mysql.connector.connect(
            host='localhost',
            port=3306,
            user='demo_user',
            password='demo_password',
            database='demo_db'
        )
        print("✅ MySQL connection successful")
        
        # テーブル一覧取得
        cursor = connection.cursor()
        cursor.execute('SHOW TABLES')
        tables = cursor.fetchall()
        table_names = [table[0] for table in tables]
        print(f"✅ Found {len(tables)} tables: {table_names}")
        
        # サンプルクエリ実行
        cursor.execute('SELECT COUNT(*) FROM users')
        user_count = cursor.fetchone()[0]
        print(f"✅ Users table has {user_count} records")
        
        cursor.close()
        connection.close()
        
        print("🎉 All tests passed!")
        return True
        
    except mysql.connector.Error as e:
        print(f"❌ MySQL connection error: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    success = test_python_environment()
    sys.exit(0 if success else 1)
