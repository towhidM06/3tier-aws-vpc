import os, socket
import pymysql
from flask import Flask, jsonify, request

app = Flask(__name__)


def get_conn():
    return pymysql.connect(
        host=os.environ["DB_HOST"], user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"], database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor, autocommit=True, connect_timeout=5)


def init_db():
    with get_conn() as c, c.cursor() as cur:
        cur.execute("""CREATE TABLE IF NOT EXISTS todos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)""")


init_db()


@app.get("/api/health")
def health():
    return jsonify(status="ok", served_by=socket.gethostname())


@app.get("/api/todos")
def list_todos():
    with get_conn() as c, c.cursor() as cur:
        cur.execute("SELECT id, title FROM todos ORDER BY id DESC")
        return jsonify(todos=cur.fetchall(), served_by=socket.gethostname())


@app.post("/api/todos")
def add_todo():
    title = (request.get_json(silent=True) or {}).get("title", "").strip()
    if not title:
        return jsonify(error="title required"), 400
    with get_conn() as c, c.cursor() as cur:
        cur.execute("INSERT INTO todos (title) VALUES (%s)", (title,))
    return jsonify(ok=True), 201


@app.delete("/api/todos/<int:todo_id>")
def delete_todo(todo_id):
    with get_conn() as c, c.cursor() as cur:
        cur.execute("DELETE FROM todos WHERE id=%s", (todo_id,))
    return jsonify(ok=True)
