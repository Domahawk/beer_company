# Beer Distribution Database

All SQL scripts are located in the `./sql` directory and can be executed on any PostgreSQL database independently of Docker. 
They do not require this project to be set up.
All the necessary data to run `SELECT` queries are contained in the `02_insert_data.sql` file.

SQL scripts:
 - `00_create_database.sql` -> create database statement if needed
 - `01_create_tables.sql` -> create all the necessary tables
 - `02_insert_data.sql` -> insert all the data
 - `03_select_queries.sql` -> select queries required by the assignment

---

## Why Docker is used

Docker is used to:
- provide a consistent, isolated, and reproducible database environment
- provide a way to run the PHP script without the need to install PHP on host machine.

PHP script fetches the data from PunkAPI, generates SQL inserts
for fetched data and outputs the `INSERT` statements so they can be reused.

---

## How to Run the Project
To run the project, Docker needs to be installed.

[Install Docker Engine](https://docs.docker.com/engine/install/)

The Docker will build and run two services, Postgres 16 database service and PHP 8.3 service.

### 1. Start Docker services

```bash
docker compose up -d
```

This will:

* Start Postgres 16 database and PHP 8.3 services 
* Create database volume
* Expose database port

---

### 2. Connect to PostgreSQL

Connect to the database using any SQL client (DBeaver, DataGrip, etc.):

```
Host: localhost
Port: 5432
User: app
Password: secret
```

---

### Run the scripts
Run the scripts `00_create_database.sql` (if needed, docker service creates the database beer_company on starting the container) and,
`01_create_tables.sql`.

Now you are ready to insert data.

You can continue running the `02_insert_data.sql` script without ever touching the PHP container, since that 
script contains all necessary data.

### Run the PHP script (optional)
This is just the demo to show how it works. It is not necessary to run the `./scripts/seed.php` script to insert product data.
All the data needed is already in `02_insert_data.sql`.

Running the `./scripts/seed.php` will insert data from PunkAPI into product and product_pack tables, 
and will also generate the `INSERT` statements into `./scripts/generated_inserts.sql` file.

#### How to run the `./scripts/seed.php`

Connect to the PHP service from the terminal
```bash
docker compose exec -it php bash
```
Run the PHP script
```bash
php ./scripts/seed.php
```

### How to Stop the Docker services

```bash
docker compose down
```
