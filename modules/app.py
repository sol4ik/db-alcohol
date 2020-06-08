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


def get_alcoholic_stats():
    """
    Returns dict of lists of alcoholics of certain categories:
    inspector's favourite,
    inspector's disfavourite,
    drinking master,
    quickest legs,
    most friendly.
    :return: dict
    """
    alcoholics = dict()
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute(f"""select * from alcoholic;""")
    alcoholics['alcoholics'] = cur.fetchall()
    conn.commit()
    cur.close()
    conn.close()

    # TODO: run queries to get corresponding alcoholics for each type
    alcoholics['friendly'] = alcoholics['alcoholics']
    alcoholics['quick'] = alcoholics['alcoholics']
    alcoholics['master'] = alcoholics['alcoholics']
    alcoholics['favourite'] = alcoholics['alcoholics']
    alcoholics['disfavourite'] = alcoholics['alcoholics']
    alcoholics['amateur'] = alcoholics['alcoholics']

    return alcoholics

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

    try:
        context['user_data'] = json.loads(request.args['user_data'])
    except KeyError:
        context['user_data'] = {
            'user_id': request.args['user_id'],
            'user_type': request.args['user_type']
        }

    alcoholics = get_alcoholic_stats()

    context['alcoholics'] = alcoholics['alcoholics']
    context['friendly'] = alcoholics['alcoholics']
    context['quick'] = alcoholics['alcoholics']
    context['master'] = alcoholics['alcoholics']
    context['favourite'] = alcoholics['alcoholics']
    context['disfavourite'] = alcoholics['alcoholics']
    context['amateur'] = alcoholics['amateur']

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

    context = dict()
    context['user'] = response[0]
    context['alcoholics'] = get_alcoholic_stats()

    if request.method == "POST":
        data = dict(request.form)
        errors = list()
        if data['action'] == "escape":
            cur.execute(f"""select enclosed from alcoholic where alcoholic_id ={ data['user_id'] };""")
            response = cur.fetchall()
            conn.commit()
            if not response[0][0]:
                errors.append("you cannot escape sober-up - you're not there! enjoy your freedom <3")
            else:
                cur.execute(f"""select current_date - migration_date from migrations where alcoholic_id = { data['user_id'] } 
                                and bed_to is not NULL order by migration_date desc limit 1;""")
                response = cur.fetchall()
                if response[0][0] < 2:
                    error.append("you cannot escape sober-up - you are still drunk!")
                else:
                    cur.execute(f"""update alcoholic set enclosed = False where alcoholic_id = { data['user_id'] };""")
                    conn.commit()

                    cur.execute(f"""select bed_id from alcoholic_bed where alcoholic_id={ data['user_id'] } and date_to is NULL;""")
                    bed_id = cur.fetchall()[0][0]

                    cur.execute(f"""insert into escape(alcoholic_id, escape_date, bed_id) values ({ data['user_id'] }, current_date, { bed_id });""")
                    conn.commit()
        else:  # action == "gain consciousness"
            cur.execute(f"""select conscious from alcoholic where alcoholic_id ={data['user_id']};""")
            response = cur.fetchall()
            conn.commit()
            if response[0][0]:
                errors.append("you cannot gain consciousness - you're all right!")
            else:
                cur.execute(
                    f"""select current_date - date_from from faints where alcoholic_id = { data['user_id']} 
                                            and date_to is NULL order by date_from desc limit 1;""")
                response = cur.fetchall()
                if response and response[0] < 3:
                    error.append("you cannot gain consciousness - you're still ill!")
                else:
                    cur.execute(f"""update alcoholic set conscious = True where alcoholic_id = {data['user_id'] };""")
                    conn.commit()

                    cur.execute(f"""update faints set date_to = current_date where alcoholic_id={ data['user_id'] } and date_to is NULL;""")
                    conn.commit()
        cur.close()
        conn.close()

        context['errors'] = errors

    return render_template('my_profile.html', context=context)


if __name__ == '__main__':
    app.run(debug=True)
