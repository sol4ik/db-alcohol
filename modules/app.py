from flask import Flask, render_template, request
import psycopg2

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
        cur.execute(
            f"""select * from { request.form['user_type'] } where { request.form['user_type'] }_id = {request.form['user_id'] };"""
        )
        response = cur.fetchall()
        conn.commit()
        if response:
            context = dict()
            context['user_data'] = request.form

            cur.execute(f"""select * from alcoholic;""")
            all_alcoholics = cur.fetchall()
            conn.commit()
            cur.close()
            conn.close()

            context['alcoholics'] = all_alcoholics
            return render_template('home.html', context=context)
        else:
            error = "no such user found!"
        cur.close()
        conn.close()
    return render_template('login.html', error=error)


if __name__ == '__main__':
    app.run(debug=True)
