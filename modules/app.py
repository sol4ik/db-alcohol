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
    context = dict()
    context['errors'] = list()

    if request.method == "POST":
        data = request.form
        errors = list()

        conn = connect_to_db()
        cur = conn.cursor()

        if data['user_type'] == "alcoholic":
            cur.execute(f"""select enclosed from alcoholic where alcoholic_id={data['user_id']};""")
            response = cur.fetchall()
            if response[0][0]:
                errors.append("you cannot drink with other alcoholics because you are enclosed in sober-up!")
            conn.commit()

            cur.execute(f"""select conscious from alcoholic where alcoholic_id={data['user_id']};""")
            response = cur.fetchall()
            if not response[0][0]:
                errors.append("you cannot dp anything as you've just fainted!")
            conn.commit()

            cur.execute(f"""select enclosed from alcoholic where alcoholic_id={ data['chosen_alcoholic_id'] };""")
            response = cur.fetchall()
            if response[0][0]:
                errors.append("you cannot drink with alcoholic who is enclosed in sober-up!")
            conn.commit()

            cur.execute(f"""select conscious from alcoholic where alcoholic_id={ data['chosen_alcoholic_id']};""")
            response = cur.fetchall()
            if not response[0][0]:
                errors.append("you cannot drink with alcoholic who just fainted!")
            conn.commit()
        else:
            pass
        cur.close()
        conn.close()
        if len(errors) == 0:
            return redirect(url_for('.action', query_data=json.dumps(data)))

        context['errors'] = errors

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


@app.route('/action', methods=["GET", "POST"])
def action():
    return render_template('action.html', context=json.loads(request.args['context']))


@app.route('/my_profile',methods=["GET", "POST"])
def my_profile():
    user_id = request.args['user_id']

    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute(f"""select * from alcoholic where alcoholic_id = {user_id};""")
    response = cur.fetchall()
    conn.commit()
    cur.close()
    conn.close()

    context = dict()
    context['user_data'] = response[0]
    return render_template('my_profile.html', context=context)


if __name__ == '__main__':
    app.run(debug=True)
