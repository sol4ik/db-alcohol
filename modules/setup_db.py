import psycopg2


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


def create_and_fill():
    """
    Run .sql file to create tables needed and fill in the data.
    :return: None
    """
    conn = connect_to_db()

    with conn.cursor() as cur:
        cur.execute(open("../sql/alcohol.sql", 'r').read())

    conn.commit()
    conn.close()


def test():
    """
    Little test for database creation and data filling.
    :return: None
    """
    conn = connect_to_db()

    with conn.cursor() as cur:
        cur.execute("select * from alcoholic where conscious = True;")
        print(cur.fetchall())

    conn.commit()
    conn.close()


if __name__ == "__main__":
    create_and_fill()
    test()
