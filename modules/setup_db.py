import psycopg2


def connect_to_db():
    """
    Connect to Postgres database alcoholic.
    :return: psycopg2 connection object
    """
    conn = psycopg2.connect(host="142.93.163.88",
                            port=6006,
                            dbname="db13",
                            user="team13",
                            password="passw13ord")
    return conn


def create_and_fill():
    """
    Read .sql file and create needed tables and fill in the data.
    :return: None
    """
    conn = connect_to_db()

    with conn.cursor() as cur:
        cur.execute(open("../sql/alcohol.sql", 'r').read())

    conn.commit()
    conn.close()


def test():
    """
    Little test for db creation and data filling.
    :return:
    """
    conn = connect_to_db()

    with conn.cursor() as cur:
        cur.execute("select * from alcoholic where conscious = True;")
        print(cur.fetchall())
        # cur.execute("insert into alcoholic_bed(alcoholic_id, bed_id, date_from, date_to) values
        #              (1, 1, current_date, null)")

    conn.commit()
    conn.close()


if __name__ == "__main__":
    create_and_fill()
    test()
