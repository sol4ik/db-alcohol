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


def is_int(str):
    """
    Check if string is a number
    :param str: string to check
    :return: bool value
    """
    try:
        a = int(str)
    except ValueError:
        return False
    return True
