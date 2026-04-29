CREATE TABLE IF NOT EXISTS customer(
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(32) NOT NULL,
	last_name VARCHAR(32) NOT NULL,
	email varchar(64) unique NOT NULL,
	password text NOT NULL CHECK (length(password) >= 6),
	registration_date date,
	birth_date date,
	is_deleted boolean
	);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_type') THEN
        CREATE TYPE subscription_type AS ENUM ('сімейна', 'студентська', 'стандартна');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_type') THEN
        CREATE TYPE payment_type AS ENUM ('готівка', 'переказ', 'за реквізитами', 'промокод');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'restriction') THEN
        CREATE TYPE restriction AS ENUM ('0+', '12+', '16+', '18+', '21+');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS subscription(
	subscription_id SERIAL PRIMARY KEY,
	start_date date,
	end_date date,
	type subscription_type not null,
	price real,
	customer_id INTEGER REFERENCES customer(customer_id)
);

CREATE TABLE IF NOT EXISTS payment(
	payment_id SERIAL PRIMARY KEY,
	amount real CHECK (amount >= 0),
	payment_type payment_type,
	payment_date date,
	status boolean,
	customer_id INTEGER REFERENCES customer(customer_id),
	subscription_id INTEGER REFERENCES subscription(subscription_id)
);

CREATE TABLE IF NOT EXISTS studio( 
    studio_id SERIAL PRIMARY KEY,
    name varchar(400) NOT NULL UNIQUE,
    country varchar(300) NOT NULL,
    founded_date date
);

CREATE TABLE IF NOT EXISTS film( 
    film_id SERIAL PRIMARY KEY,
    title text,
    release_year INT,
    duration smallint CHECK (duration > 0), 
    age_restriction restriction, 
    studio_id INTEGER REFERENCES studio(studio_id)
);

CREATE TABLE IF NOT EXISTS genre(
    genre_id SERIAL PRIMARY KEY,
    name varchar(64),
    description text
);

CREATE TABLE IF NOT EXISTS film_genre( 
    film_id INTEGER REFERENCES film(film_id),
    genre_id INTEGER REFERENCES genre(genre_id),
	PRIMARY KEY (film_id, genre_id)

);

CREATE TABLE IF NOT EXISTS actor(
    actor_id SERIAL PRIMARY KEY,
    first_name varchar(64) NOT NULL,
    last_name varchar(64) NOT NULL,
    country varchar(64) NOT NULL,
    birth_date date
);

CREATE TABLE IF NOT EXISTS director(
	director_id SERIAL PRIMARY KEY,
    first_name varchar(64) NOT NULL,
    last_name varchar(64) NOT NULL,
    country varchar(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS film_actor( 
    film_id INTEGER REFERENCES film(film_id),
    actor_id INTEGER REFERENCES actor(actor_id),
	PRIMARY KEY (film_id, actor_id)
);

CREATE TABLE IF NOT EXISTS film_director( 
    film_id INTEGER REFERENCES film(film_id),
    director_id INTEGER REFERENCES director(director_id),
	PRIMARY KEY (film_id, director_id)
);


INSERT INTO customer (first_name, last_name, email, password, registration_date, birth_date, is_deleted) VALUES
('John', 'Doe', 'john.doe@gmail.com', 'hashed_pass_1', '2024-01-10', '1990-05-15', FALSE),
('Jane', 'Smith', 'jane.smith@yahoo.com', 'hashed_pass_2', '2024-01-15', '1995-08-22', FALSE),
('Alice', 'Johnson', 'alice.j@outlook.com', 'hashed_pass_3', '2024-02-01', '1988-11-03', FALSE),
('Michael', 'Brown', 'm.brown@gmail.com', 'hashed_pass_4', '2024-02-10', '2000-01-12', FALSE),
('Emily', 'Davis', 'emily.d@test.com', 'hashed_pass_5', '2024-03-05', '1992-07-30', TRUE);

INSERT INTO studio (name, country, founded_date) VALUES
('Warner Bros. Pictures', 'USA', '1923-04-04'),
('Universal Pictures', 'USA', '1912-06-08'),
('Paramount Pictures', 'USA', '1912-05-08'),
('Walt Disney Pictures', 'USA', '1923-10-16'),
('Columbia Pictures', 'USA', '1924-01-10');

INSERT INTO subscription (start_date, end_date, type, price, customer_id) VALUES
('2024-01-01', '2024-12-31', 'сімейна', 14.99, 1),
('2024-02-15', '2024-03-15', 'стандартна', 9.99, 2),
('2024-03-01', '2024-06-01', 'студентська', 4.99, 3);

INSERT INTO director (first_name, last_name, country) VALUES
('Greta', 'Gerwig', 'USA'),
('Kathryn', 'Bigelow', 'USA'),
('Chloé', 'Zhao', 'China'),
('Sofia', 'Coppola', 'USA'),
('Ava', 'DuVernay', 'USA');

INSERT INTO film (title, release_year, duration, age_restriction, studio_id) VALUES
('Dune', 2021, 155, '12+', 1),
('Spider-Man: No Way Home', 2021, 148, '12+', 1),
('The Queen''s Gambit', 2020, 395, '16+', 1),
('Black Swan', 2010, 108, '18+', 1),
('Harry Potter and the Sorcerer''s Stone', 2001, 152, '0+', 1);

INSERT INTO actor (first_name, last_name, country, birth_date) VALUES
('Zendaya', 'Stoermer', 'USA', '1996-09-01'),
('Tom', 'Holland', 'UK', '1996-06-01'),
('Anya', 'Taylor-Joy', 'USA', '1996-04-16'),
('Natalie', 'Portman', 'Israel', '1981-06-09'),
('Emma', 'Watson', 'France', '1990-04-15');


INSERT INTO payment (amount, payment_type, payment_date, status, customer_id, subscription_id) VALUES
(14.99, 'переказ', '2024-01-01', TRUE, 1, 1),
(9.99, 'готівка', '2024-02-15', TRUE, 2, 2),
(4.99, 'промокод', '2024-03-01', TRUE, 3, 3),
(14.99, 'за реквізитами', '2024-02-10', TRUE, 4, 1),
(0.00, 'промокод', '2024-03-05', FALSE, 5, 2);


INSERT INTO genre (name, description) VALUES
('Drama', 'Focuses on realistic characters and emotional themes dealing with human relationships.'),
('Sci-Fi', 'Explores futuristic concepts, advanced technology, space travel, and parallel universes.'),
('Action', 'Features fast-paced sequences, physical feats, and often involves high-stakes conflicts.'),
('Horror', 'Designed to frighten and invoke hidden fears, often involving supernatural or macabre themes.'),
('Comedy', 'Aims to entertain and provoke laughter through humor, irony, or witty dialogue.');