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

    conn.close()


def test():
    conn = connect_to_db()
    cur = conn.cursor()

    cur.execute("select * from alcoholic where enclosed = False;")
    print(cur.fetchall())

    conn.commit()
    cur.close()
    conn.close()


if __name__ == "__main__":
    create_and_fill()
    test()
