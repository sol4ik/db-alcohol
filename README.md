# db-alcohol
Final assignment for Data Base course by **team no.13**: Danylo Sluzhynskyi, Solomia Kantsir, Solomiia Leno and Yana Kurlyak.

## Task
The task is to develop a data base and interface for implementation of the **sober-up** system:

* subjects:
  * **alcoholics** and **inspectors**
* objects:
  * **bed** in sober-up
  * alcohol **drink**
* possible actions:
  * alcoholic and his friends gather into a **group** and **drink together**
  * if alcoholic drinks more he can, he **faints**
  * while alcoholic lost his consiousness, insepctor can **enclose** him in the sober-up
  * after some time, an inspector can **release** the alcoholic from the sober-up bed
  * alcoholic can also **escape** the sober-up bed after he gains consiousness back
  * if needed, an inspector can **change the bed** for alcoholic

In order to optimaze the performance of data base usage commands, we also need to implement **indices** and **triggers** for the tables.

The task also includes list of **SQL queries** that have be valid for the data base to be implemented.


## ER diagram
In order to present our data base we created the Entity Relational diagram of it.


![Entity Relational diagram of our solution](https://github.com/sol4ik/db-alcohol/blob/master/diagram.png)

Although in the ER-diagram the primary keys are of the form `(alcoholic_id, inspector_id, date)` we recommend to use **surogate key** in real-life implementation

## SQL code
In **sql** directory of the project you can find two files with `.sql` extension. Here's a short overview of the scripts. 

**alcohol.sql**

* database creation
* tables creation and constraints
* triggers
* indices creation
* example data insertion

**requests.sql**

* `select` queries listed in the task

## Web application
The last part of our task was to implement **web-interface for database management**.

We implemented a web-application using Python **Flask** and **psycopg2** package to manage access to database.

### Usage


### For development 
In order to start the application, you need to clone this repository and then run the following commands in the terminal.
    
    cd db-alcohol
    
    virtualenv venv
    source venv/bin/activate
    
    pip install -r requirements.txt
    
    cd modules
    python setup_db.py
    cd ../
    
    export FLASK_APP=modules/app.py
    flask run

Now you're welcome to work with our project!
