from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import json

from help_functions import is_int

from statistics import statistics

app = Flask(__name__, static_folder='./templates/static')
app.register_blueprint(statistics)


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

    alcoholics['friendly'] = alcoholics['alcoholics']
    alcoholics['quick'] = alcoholics['alcoholics']
    alcoholics['master'] = alcoholics['alcoholics']

    # inspector's favourite
    alcoholics['favourite'] = alcoholics['alcoholics']
    alcoholics['disfavourite'] = alcoholics['alcoholics']
    alcoholics['amateur'] = alcoholics['alcoholics']

    cur.close()
    conn.close()

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
            cur.execute(f"""select enclosed, conscious from alcoholic where alcoholic_id={data['user_id']};""")
            response = cur.fetchall()
            if response[0][0]:
                errors.append("you cannot drink with other alcoholics because you are enclosed in sober-up!")
            if not response[0][1]:
                errors.append("you cannot do anything as you've just fainted!")
            conn.commit()

            cur.execute(f"""select enclosed, conscious from alcoholic where alcoholic_id={ data['chosen_alcoholic_id'] };""")
            response = cur.fetchall()
            if response[0][0]:
                errors.append("you cannot drink with alcoholic who is enclosed in sober-up!")
            if not response[0][1]:
                errors.append("you cannot drink with alcoholic who just fainted!")
            conn.commit()
        else:
            if data['action'] == "enclose":
                cur.execute(f"""select enclosed, conscious from alcoholic where alcoholic_id={data['chosen_alcoholic_id']};""")
                response = cur.fetchall()
                if response[0][0]:
                    errors.append("you cannot enclose someone who is already enclosed!")
                if response[0][1]:
                    errors.append("you cannot enclose someone who has not drank too much!")

                cur.execute(f"""select count(*) from bed where taken = False;""")
                response = cur.fetchall()
                if response[0][0] == 0:
                    errors.append("no more free beds left in the sober-up!")

                conn.commit()
            elif data['action'] == "release":
                cur.execute(f"""select enclosed, conscious from alcoholic where alcoholic_id={data['chosen_alcoholic_id']};""")
                response = cur.fetchall()
                if not response[0][0]:
                    errors.append("you cannot release someone who is not enclosed in sober-up!")
                if not response[0][1]:
                    errors.append("you cannot release someone who is still ill!")

                cur.execute(f"""select current_date - migration_date from migrations
                                where alcoholic_id={ data['chosen_alcoholic_id'] }
                                and bed_from is NULL order by migration_date desc limit 1;""")
                response = cur.fetchall()
                if response and response[0][0] < 5:
                    errors.append("you cannot release someone who haven't been to sober-up for at least 5 days!")
                conn.commit()
            else:  # action == "move"
                cur.execute(f"""select count(*) from bed where taken = False;""")
                response = cur.fetchall()
                if response[0][0] == 0:
                    errors.append("no more free beds left in the sober-up!")
                conn.commit()

        cur.close()
        conn.close()
        if len(errors) == 0:
            return redirect(url_for('.action', context=json.dumps(data)))

        context['errors'] = errors

    try:
        context['user_data'] = json.loads(request.args['user_data'])
    except KeyError:
        context['user_data'] = {
            'user_id': request.args['user_id'],
            'user_type': request.args['user_type']
        }

    if request.method == "GET":
        try:
            action_context = json.loads(request.args['messages'])
            context['msgs'] = action_context['msgs']
            context['errors'].extend(action_context['errs'])
        except KeyError:
            context['msgs'] = list()

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
    context = json.loads(request.args['context'])

    conn = connect_to_db()
    cur = conn.cursor()

    if request.method == "POST":
        action_data = request.form
        msgs = list()
        errors = list()

        if action_data['action'] == "invite":
            cur.execute(f"""select alcohol_id from alcohol where name = '{ action_data['drink'] }';""")
            alcohol_id = cur.fetchall()[0][0]

            cur.execute(f"""insert into group_alcohol(alcohol_id, count_alcoholics, amount_drunk, date_from, date_to) values 
                            ({ alcohol_id }, 2, { action_data['amount'] }, current_date, current_date + 2);""")

            cur.execute(f"""select max(group_id) from group_alcohol;""")
            group_id = cur.fetchall()[0][0]

            cur.execute(f"""insert into group_alcoholic(group_id, alcoholic_id) values 
                            ({group_id}, {action_data['user_id']}), ({group_id}, {action_data['user_id']});""")

            # check for faints
            cur.execute(f"""select max_drink from alcoholic where alcoholic_id = { action_data['user_id']};""")
            user_max = cur.fetchall()[0][0]

            cur.execute(f"""select max_drink from alcoholic where alcoholic_id = { action_data['chosen_alcoholic_id']};""")
            friend_max = cur.fetchall()[0][0]

            if user_max < float(action_data['amount']) / 2:
                cur.execute(f"""update alcoholic set conscious = False where alcoholic_id = { action_data['user_id'] };""")

                cur.execute(f"""insert into faints(alcoholic_id, date_from, date_to) values
                                ({ action_data['user_id']}, current_date, NULL);""")

                msgs.append("oops, looks like you've drank too much!")
            if friend_max < float(action_data['amount']) / 2:
                cur.execute(f"""update alcoholic set conscious = False where alcoholic_id = {action_data['chosen_alcoholic_id']};""")

                cur.execute(f"""insert into faints(alcoholic_id, date_from , date_to) values
                                ({action_data['chosen_alcoholic_id']}, current_date, NULL);""")
                msgs.append("oops, your friend just fainted!")

            msgs.append("seems like you has a lot of fun!")

        elif action_data['action'] == "enclose":
            cur.execute(f"""update alcoholic set enclosed = True where alcoholic_id = { action_data['chosen_alcoholic_id'] };""")

            cur.execute(f"""update bed set taken = True where bed_id = { action_data['bed'] };""")

            cur.execute(f"""insert into migrations(bed_from, bed_to, alcoholic_id, inspector_id, migration_date) values
                            (NULL, { action_data['bed'] }, { action_data['chosen_alcoholic_id'] }, { action_data['user_id'] }, current_date);""")

            cur.execute(f"""insert into alcoholic_bed(bed_id, alcoholic_id, date_from, date_to) values
                            ({ action_data['bed'] }, { action_data['chosen_alcoholic_id'] }, current_date, NULL);""")

            msgs.append("good job! you successfully enclosed an alcoholic in the sober-up!")
        elif action_data['action'] == "release":
            cur.execute(f"""update alcoholic set enclosed = False where alcoholic_id = {action_data['chosen_alcoholic_id']};""")

            cur.execute(f"""select bed_to from migrations where
                            alcoholic_id = { action_data['chosen_alcoholic_id'] } order by migration_date desc limit 1;""")
            cur_bed = cur.fetchall()[0][0]

            if cur_bed is None:
                errors.append("some data on this alcoholic's history are inconsistent!")
            else:
                cur.execute(f"""update bed set taken = True where bed_id = { action_data['bed'] };""")
                cur.execute(f"""update bed set taken = False where bed_id = { cur_bed };""")

                cur.execute(f"""insert into migrations(bed_from, bed_to, alcoholic_id, inspector_id, migration_date) values
                                ({ cur_bed }, NULL, {action_data['chosen_alcoholic_id']}, {action_data['user_id']}, current_date);""")

                cur.execute(f"""update alcoholic_bed set date_to = current_date where
                                alcoholic_id = { action_data['chosen_alcoholic_id']} and date_to is NULL;""")

                msgs.append("you successfully released an alcoholic from the sober-up!")
        else:
            cur.execute(f"""select bed_to from migrations where
                            alcoholic_id = { action_data['chosen_alcoholic_id'] } order by migration_date desc limit 1;""")
            cur_bed = cur.fetchall()[0][0]

            if cur_bed is None:
                errors.append("some data on this alcoholic's history are inconsistent!")
            else:
                cur.execute(f"""update bed set taken = True where bed_id = { action_data['bed'] };""")
                cur.execute(f"""update bed set taken = False where bed_id = { cur_bed };""")

                cur.execute(f"""insert into migrations(bed_from, bed_to, alcoholic_id, inspector_id, migration_date) values
                                ({ cur_bed }, NULL, {action_data['chosen_alcoholic_id']}, {action_data['user_id']}, current_date);""")

                cur.execute(f"""update alcoholic_bed set date_to = current_date where
                                            alcoholic_id = {action_data['chosen_alcoholic_id']} and date_to is NULL;""")
                cur.execute(f"""insert into alcoholic_bed(bed_id, alcoholic_id, date_from, date_to) values
                                            ({action_data['bed']}, {action_data['chosen_alcoholic_id']}, current_date, NULL);""")

                msgs.append("good job! it was a successful (still unneeded) beds migration! :)")

        conn.commit()
        cur.close()
        conn.close()

        user_data = {
            'user_type': action_data['user_type'],
            'user_id': action_data['user_id']
        }
        messages = {
            'msgs': msgs,
            'errs': errors
        }

        return redirect(url_for('.home', user_data=json.dumps(user_data), messages=json.dumps(messages)))

    cur.execute(f"""select name from alcoholic where alcoholic_id ={context['chosen_alcoholic_id']};""")
    context['chosen_alcoholic_name'] = cur.fetchall()[0][0]
    conn.commit()
    if context['action'] == "invite":
        cur.execute(f"""select name from alcohol;""")
        context['drinks'] = cur.fetchall()
    if context['action'] in ["enclose", "move"]:
        cur.execute(f"""select bed_id from bed where taken = False;""")
        context['beds'] = cur.fetchall()

    conn.commit()
    cur.close()
    conn.close()

    return render_template('action.html', context=context)


@app.route('/my_profile', methods=["GET", "POST"])
def my_profile():
    user_id = request.args['user_id']

    conn = connect_to_db()
    cur = conn.cursor()
    context = dict()

    if request.method == "POST":
        data = dict(request.form)
        errors = list()
        msgs = list()
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
                    errors.append("you cannot escape sober-up - you are still drunk!")
                else:
                    cur.execute(f"""update alcoholic set enclosed = False where alcoholic_id = { data['user_id'] };""")
                    conn.commit()

                    cur.execute(f"""select bed_id from alcoholic_bed where alcoholic_id={ data['user_id'] } and date_to is NULL;""")
                    bed_id = cur.fetchall()[0][0]

                    cur.execute(f"""insert into escape(alcoholic_id, escape_date, bed_id) values ({ data['user_id'] }, current_date, { bed_id });""")
                    conn.commit()

                    msgs.append("you successfully escaped!")
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
                if response and response[0][0] < 3:
                    errors.append("you cannot gain consciousness - you're still ill!")
                else:
                    cur.execute(f"""update alcoholic set conscious = True where alcoholic_id = {data['user_id'] };""")
                    conn.commit()

                    cur.execute(f"""update faints set date_to = current_date where alcoholic_id={ data['user_id'] } and date_to is NULL;""")
                    conn.commit()

                    msgs.append("you're conscious again!")

        context['errors'] = errors
        context['msgs'] = msgs

    cur.execute(f"""select * from alcoholic where alcoholic_id={ user_id }""")
    conn.commit()
    context['user'] = cur.fetchall()[0]  # updated info on user

    context['alcoholics'] = get_alcoholic_stats()

    cur.close()
    conn.close()

    return render_template('my_profile.html', context=context)


if __name__ == '__main__':
    app.run(debug=True)
