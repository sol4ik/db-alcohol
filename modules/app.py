from flask import Flask, render_template

app = Flask(__name__, static_folder='./templates/static')


@app.route('/')
def login_page():
    return render_template('login.html')

if __name__ == '__main__':
    app.run(debug=True)
