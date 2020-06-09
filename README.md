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
You can try our application at [here](https://soberup.herokuapp.com/).

At first you need to login as **alcoholic** or **sober-up inspector**. Then you can perform the following actions.

**Alcoholic** has access to his personal profile as well as overall sober-up statistics (functional for performing SQL requests from the task).
Alcoholic can also invite his friends for a drink who are not enclosed in sober-up and feel well (are conscious).
If they drink too much (more than their limit) - one can loose consciousness for as long as 3 days.

Each alcoholic can also earn some **awards** for being

* most friendly soul, 
* drinking master, 
* drinking amateur, 
* quick runner,
* inspector's favourite or least favourite.

They are displayed within personal profile and personal card at home page for every alcoholic.

**Inspectors** have access to functional to enclose fainted alcoholics in the sober-up, release them or move the beds.
They also can view all the sober-up statistics.

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
