/*

DDL (data definition language): Controls the structure (schema) of the data
in a database (tables + columns)

e.g. CREATE DATABASE, DROP DATABSE
e.g. ALTER TABLE <table> RENAME TO ...;
e.g. DROP TABLE <table>;
e.g. ALTER TABLE <table> ADD CONSTRAINTS <name> <constraint_clause>;
e.g. ALTER TABLE <table> ADD COLUMN <name>;
e.g. ALTER TABLE <table> ALTER COLUMN <name> RENAME TO <new_name>;

etc.ABORT

DML (data manipulation language): Language used to control retrieval and
modification of data stored in the table (rows + values inside rows)

e.g. INSERT, SELECT, UPDATE, DELETE (CRUD)

DML

DDL (defining data as a table)

DDL (defining the limits of our data via constraints)

DML (modification of data via insertion)

DML (modification of data by updating)

It uses neither. This is not a SQL statement; rather, it is a meta-command
provided by `psql`, a CLI for interacting with the PostgreSQL RDBMS.ABORT
The command itself simply describes the schema of a table named 'things' in the
current database.

DML (modification of data by deleting)

DDL (modification of the database itself)
- This could be interpreted as DML though, because it will actually modify
the data by deleting it. As with DROP TABLE or DROP COLUMN. But formally, 
DROP statements are part of the DDL.

DDL (SEQUENCE has something to do w/ schema)
- Note: Sequence creation might be considered part of DML because
sequences themselves do store some data

*/