drop database IF EXISTS brainwashing_users;
create database brainwashing_users;
\c brainwashing_users;

CREATE TABLE users_ar(
  id   SERIAL PRIMARY KEY,
  name varchar(40),
  gender varchar(40),
  age integer
);


CREATE TABLE users_arel(
  id   SERIAL PRIMARY KEY,
  name varchar(40),
  gender varchar(40),
  age integer
);

CREATE TABLE users_sql(
  id   SERIAL PRIMARY KEY,
  name varchar(40),
  gender varchar(40),
  age integer
);

CREATE TABLE users_sequel(
  id   SERIAL PRIMARY KEY,
  name varchar(40),
  gender varchar(40),
  age integer
);

CREATE TABLE users_rom(
  id   SERIAL PRIMARY KEY,
  name varchar(40),
  gender varchar(40),
  age integer
);
