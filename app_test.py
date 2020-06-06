from flask import Flask, request, render_template
import psycopg2

app = Flask(__name__, static_url_path='')


# Connect to the db
def connect_to_db():
    conn = psycopg2.connect(host="localhost",
                            port=5432,
                            dbname="alcohol",
                            user="postgres",
                            password="postgres")
    return conn


@app.route('/', methods=['GET', 'POST'])
def index():
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
        return render_template('finish.html', result=response)
    else:
        return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True)
