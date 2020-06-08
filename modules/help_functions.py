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
