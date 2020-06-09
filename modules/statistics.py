from flask import request, render_template, Blueprint
import psycopg2
from psycopg2.extras import NamedTupleCursor

statistics = Blueprint('statistics', __name__, static_folder='./templates/static')


# @app.teardown_appcontext
# def close_conn(e):
#     print('CLOSING CONN')
#     db = g.pop('db', None)
#     if db is not None:
#         app.config['postgreSQL_pool'].putconn(db)


class Requests:
    @staticmethod
    def request1(conn, cur, data):
        cur.execute(f"""SELECT i.inspector_id, i.name FROM migrations
                        inner join inspector i on migrations.inspector_id = i.inspector_id
                        inner join alcoholic a2 on migrations.alcoholic_id = a2.alcoholic_id
                        WHERE bed_to IS NOT NULL
                        AND bed_from IS NULL
                        AND migration_date > '{data['date_from']}'
                        AND migration_date < '{data['date_to']}'
                        GROUP BY i.inspector_id, a2.name ,i.name
                        HAVING COUNT(migrations.inspector_id) >= {data["qty"]}
                        AND a2.name = '{data["name"]}';""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request2(conn, cur, data):
        cur.execute(f"""select bed_id, date_from, date_to
                                    from alcoholic_bed
                                    inner join alcoholic a on alcoholic_bed.alcoholic_id = a.alcoholic_id
                                    where ((date_from < '{data['date_from']}' and date_to > '{data['date_from']}')
                                    or (date_from > '{data['date_from']}' and date_from < '{data['date_to']}'))
                                    and name = '{data['name']}';""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request3(conn, cur, data):
        cur.execute(f"""SELECT a.name FROM migrations
                        inner join inspector i2 on migrations.inspector_id = i2.inspector_id
                        inner join alcoholic a on migrations.alcoholic_id = a.alcoholic_id
                        WHERE bed_to IS NOT NULL
                        AND bed_from IS NULL
                        AND migration_date > '{data['date_from']}'
                        AND migration_date < '{data['date_to']}'
                        GROUP BY a.name, i2.name
                        HAVING COUNT(a.alcoholic_id) >= {data['qty']}
                        AND i2.name = '{data['i_name']}';""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request4(conn, cur, data):
        cur.execute(f"""select bed_id, escape_date
                        from escape
                        inner join alcoholic a on escape.alcoholic_id = a.alcoholic_id
                        where name = '{data["name"]}'
                        and escape_date > '{data["date_from"]}'
                        and escape_date < '{data["date_to"]}';""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request5(conn, cur, data):
        cur.execute(f"""SELECT i.name
                        FROM migrations 
                        INNER JOIN alcoholic a on migrations.alcoholic_id = a.alcoholic_id
                        INNER JOIN inspector i on migrations.inspector_id = i.inspector_id
                        WHERE (bed_from IS NULL OR bed_to IS NULL)
                          AND a.name = '{data['name']}'
                        GROUP BY migrations.alcoholic_id, i.name
                        HAVING COUNT(*) - COUNT(bed_to) > COUNT(bed_to)""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request6(conn, cur, data):
        cur.execute(f"""select i.inspector_id, name
                        from migrations
                        inner join inspector i on migrations.inspector_id = i.inspector_id
                        where migration_date > '{data['date_from']}'
                        and migration_date < '{data['date_to']}'
                        and bed_from is null
                        group by name, i.inspector_id
                        having Count(Distinct alcoholic_id) > {data['qty']};""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request7(conn, cur, data):
        cur.execute(f"""SELECT a.alcoholic_id,a.name FROM migrations
                        inner join alcoholic a on migrations.alcoholic_id = a.alcoholic_id
                        WHERE bed_to IS NOT NULL
                        AND bed_from IS NULL
                        AND migration_date > '{data['date_from']}'
                        AND migration_date < '{data['date_to']}'
                        GROUP BY a.alcoholic_id
                        HAVING COUNT(migration_id) >= {data['qty']};""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request8(conn, cur, data):
        cur.execute(
            f"""select migration_date                                                              as event_date,
                (case
                    when bed_from is null then 'Closure event'
                    when bed_from is not null and bed_to is not null then 'Migration event'
                    when bed_from is not null and bed_to is null then 'Release event' end) as event_name
                from migrations
                inner join inspector i on migrations.inspector_id = i.inspector_id
                inner join alcoholic a on migrations.alcoholic_id = a.alcoholic_id
                where migration_date > '{data['date_from']}'
                and migration_date < '{data['date_to']}'
                and i.name = '{data["i_name"]}'
                and a.name ='{data["name"]}';""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request9(conn, cur, data):
        cur.execute(f"""SELECT a.name, group_alcohol.name, COUNT(DISTINCT alcohol_id)
                        FROM group_alcoholic
                        INNER JOIN group_alcohol USING (group_id)
                        INNER JOIN alcoholic a on group_alcoholic.alcoholic_id = a.alcoholic_id
                        WHERE group_alcohol.count_alcoholics >= {data['qty']}
                        AND a.name = '{data['name']}'
                        GROUP BY group_alcoholic.alcoholic_id, group_alcohol.alcohol_id;""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request10(conn, cur, data):
        cur.execute(
            f"""select to_char(escape_date, 'MM') as "Months", count(bed_id)
                from escape
                group by to_char(escape_date, 'MM')
                order by "Months";""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request11(conn, cur, data):
        cur.execute(
            f"""SELECT bed_to AS bed_id FROM migrations m
                INNER JOIN faints USING (alcoholic_id)
                INNER JOIN inspector i2 on m.inspector_id = i2.inspector_id
                WHERE m.bed_to IS NOT NULL
                  AND m.bed_from IS NULL
                  AND i2.name = '{data['i_name']}'
                  AND migration_date > '{data['date_from']}'
                  AND migration_date < '{data['date_to']}'
                GROUP BY m.bed_to
                ORDER BY COUNT(DISTINCT faint_id) DESC;""")
        conn.commit()
        return cur.fetchall()

    @staticmethod
    def request12(conn, cur, data):
        cur.execute(
            f"""select alcohol.name, count_alcoholics
                from alcohol
                inner join group_alcohol ga on alcohol.alcohol_id = ga.alcohol_id
                inner join (select * from group_alcoholic
                inner join alcoholic a on group_alcoholic.alcoholic_id = a.alcoholic_id
                where name = '{data['name']}') g on ga.group_id = g.group_id
                where (date_from < '{data["date_from"]}' and date_to > '{data["date_from"]}')
                or (date_From > '{data["date_from"]}' and '{data["date_to"]}' > date_from)
                group by alcohol.name, count_alcoholics
                order by count_alcoholics desc;""")
        conn.commit()
        return cur.fetchall()


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


@statistics.route('/requests', methods=['GET', 'POST'])
def requests():
    r = Requests()
    conn = connect_to_db()
    cur = conn.cursor(cursor_factory=NamedTupleCursor)
    if request.method == 'POST':
        data = dict(request.form)
        if all(v for v in data.values()):
            response = getattr(r, request.form['btn'])(conn, cur, data)
            # print(dict(response[0]))
            cur.close()
            conn.close()
            if not response:
                return "<h3>404, Немає результату за цим запитом</h3>"
            return render_template('response_table.html', result=response)
    return render_template('requests.html')


@statistics.route('/alcoholic', methods=['GET'])
def get_all_alcoholic():
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute(f"""select * from alcoholic;""")
    response = cur.fetchall()
    conn.commit()
    cur.close()
    return render_template('response_table.html', result=response)


@statistics.route('/inspector', methods=['GET'])
def get_all_inspector():
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute(f"""select * from inspector;""")
    response = cur.fetchall()
    conn.commit()
    cur.close()
    conn.close()
    return render_template('response_table.html', result=response)
