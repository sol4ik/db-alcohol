from flask import Flask, request, render_template
import psycopg2
import os

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


@app.route('/request2', methods=['GET', 'POST'])
def request2():
    conn = connect_to_db()
    cur = conn.cursor()
    if request.method == 'POST':
        data = dict(request.form)
        cur.execute(f"""select bed_id, date_from, date_to
                        from alcoholic_bed
                        where ((date_from < '{data['date_from']}' and date_to > '{data['date_from']}')
                        or (date_from > '{data['date_from']}' and date_from < '{data['date_to']}'))
                        and alcoholic_id = {data['alcoholic_id']};""")
        response = cur.fetchall()
        conn.commit()
        cur.close()
        conn.close()
        for i in response:
            print(i)
        return render_template('requst2_finish.html', result=response)
    else:
        return render_template('request2.html')


@app.route('/alcoholic', methods=['GET'])
def get_all_alcoholic():
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute(f"""select * from alcoholic;""")
    response = cur.fetchall()
    conn.commit()
    cur.close()
    conn.close()
    return render_template('alcoholic.html', result=response)


@app.route('/inspector', methods=['GET'])
def get_all_inspector():
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute(f"""select * from inspector;""")
    response = cur.fetchall()
    conn.commit()
    cur.close()
    conn.close()
    return render_template('inspector.html', result=response)


@app.route('/', methods=['GET'])
def index():
    # conn = connect_to_db()
    # cur = conn.cursor()
    # cur.execute(f"""select * from inspector;""")
    # response = cur.fetchall()
    # conn.commit()
    # cur.close()
    # conn.close()
    return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True)
