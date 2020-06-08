from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import json

from help_functions import is_int

app = Flask(__name__, static_folder='./templates/static')


def connect_to_db():
    """
    Connect to Postgres database alcoholic.
    :return: psycopg2 connection object
    """
    conn = psycopg2.connect(host="localhost",
                            port=5432,
                            dbname="alcohol",
                            user="postgres",
                            password="postgres")
    return conn


@app.route('/', methods=["GET", "POST"])
def login_page():
    error = ""
    if request.method == "POST":
        data = request.form
        conn = connect_to_db()
        cur = conn.cursor()
        if is_int(request.form['user_id']):
            cur.execute(
                f"""select * from { request.form['user_type'] } where { request.form['user_type'] }_id = {request.form['user_id'] };"""
            )
            response = cur.fetchall()
            conn.commit()
            cur.close()
            conn.close()
            if response:
                return redirect(url_for('.home', user_data=json.dumps(request.form)))
            else:
                error = "no such user found!"
        else:
            error = "invalid id type! please, enter integer value"
    return render_template('login.html', error=error)


@app.route('/home', methods=["GET", "POST"])
def home():
    if request.method == "GET":
        context = dict()
        context['user_data'] = json.loads(request.args['user_data'])

        conn = connect_to_db()
        cur = conn.cursor()
        cur.execute(f"""select * from alcoholic;""")
        context['alcoholics'] = cur.fetchall()
        conn.commit()
        cur.close()
        conn.close()

        # TODO: run queries to get corresponding alcoholics for each type
        context['friendly'] = context['alcoholics']
        context['quick'] = context['alcoholics']
        context['master'] = context['alcoholics']
        context['favourite'] = context['alcoholics']
        context['disfavourite'] = context['alcoholics']

        return render_template('home.html', context=context)


if __name__ == '__main__':
    app.run(debug=True)
