-- Carolina Muizzi

USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
-- alphabetically ordered by first name.

SELECT first_name, last_name 
   FROM actor 
   ORDER BY first_name;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT CONCAT(first_name, ' ', last_name) 
    AS 'Actor Name' 
    FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name 
	FROM actor 
    WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT actor_id, first_name, last_name 
	FROM actor 
    WHERE last_name 
    LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:

SELECT actor_id, first_name, last_name 
	FROM actor 
    WHERE last_name 
    LIKE '%LI%' 
    ORDER BY last_name, first_name;

-- Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country 
FROM country 
WHERE country_id IN
(
  SELECT country_id
  FROM country
  WHERE country IN ('Afghanistan', 'Bangladesh', 'China')
);

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

-- `BLOB` : bigger than VARCHAR

ALTER TABLE actor
ADD COLUMN description BLOB(50);


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(first_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS last_name_count
FROM actor
GROUP BY last_name
HAVING count(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SELECT first_name, last_name
FROM actor
WHERE 
    first_name = 'GROUCHO';

-- change frist name when both condition agree `GROUCHO WILLIAMS` because as we can see, there are 3 persons with the name GROUCHO.
UPDATE actor
SET first_name = 'HARPO' 
WHERE 
	last_name = 'WILLIAMS'
	AND 
    first_name = 'GROUCHO';
    
-- verify the change.
SELECT first_name, last_name
FROM actor
WHERE 
	last_name = 'WILLIAMS'
	AND 
    first_name = 'HARPO'; 
    
    
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor
SET first_name = 'GROUCHO' 
WHERE 
    first_name = 'HARPO'
    AND 
    last_name = 'WILLIAMS';
    
-- verify the change.
SELECT first_name, last_name
FROM actor
WHERE first_name = 'GROUCHO'; 

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
describe sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:

SELECT first_name, last_name, address
FROM staff AS S
JOIN address AS A
ON S.address_id = A.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT payment.staff_id, staff.first_name, staff.last_name, payment.amount, payment.payment_date
FROM staff INNER JOIN payment ON
staff.staff_id = payment.staff_id AND payment_date LIKE '2005-08%'; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT f.title AS 'Film Title', 
COUNT(a.actor_id) AS `Number of Actors`
FROM film_actor AS A
INNER JOIN film AS F 
ON A.film_id= F.film_id
GROUP BY F.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT title, (
SELECT COUNT(*) FROM inventory AS I
WHERE F.film_id = I.film_id
) AS 'Number of Copies'
FROM film AS F
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

SELECT C.first_name, C.last_name, sum(P.amount) AS `Total Paid`
FROM customer AS C
JOIN payment AS P
ON C.customer_id= P.customer_id
GROUP BY C.last_name ORDER BY C.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles 
-- of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM film WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN 
(
SELECT title 
FROM film 
WHERE language_id = 1
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
Select actor_id
FROM film_actor
WHERE film_id IN 
(
SELECT film_id
FROM film
WHERE title = 'Alone Trip'
));

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT CUST.first_name, CUST.last_name, CUST.email 
FROM customer AS CUST
JOIN address AS AD 
ON (CUST.address_id = AD.address_id)
JOIN city AS CT
ON (CT.city_id = AD.city_id)
JOIN country AS CO
ON (CO.country_id = CT.country_id)
WHERE CO.country= 'Canada'; 

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

SELECT title, description FROM film 
WHERE film_id IN
(SELECT film_id FROM film_category
WHERE category_id IN
(SELECT category_id FROM category
WHERE name = "Family"
));

-- 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(rental_id) AS 'Times Film rented'
FROM rental AS R
JOIN inventory AS I
ON (R.inventory_id = I.inventory_id)
JOIN film AS F
ON (I.film_id = F.film_id)
GROUP BY F.title
ORDER BY `Times Film rented` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT S.store_id, SUM(amount) AS 'Revenue'
FROM payment AS P
JOIN rental AS R
ON (P.rental_id = R.rental_id)
JOIN inventory AS I
ON (I.inventory_id = R.inventory_id)
JOIN store AS S
ON (S.store_id = I.store_id)
GROUP BY S.store_id; 

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT S.store_id, CT.city, CO.country 
FROM store AS S
JOIN address AS A 
ON (S.address_id = A.address_id)
JOIN city AS CT
ON (CT.city_id = A.city_id)
JOIN country AS CO
ON (CO.country_id = CT.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT CA.name, SUM(P.amount) AS 'Gross_Revenue ($)' 
FROM 
	category as CA
    LEFT JOIN film_category AS FC ON CA.category_id = FC.category_id
    LEFT JOIN inventory AS I ON FC.film_id = I.film_id
    LEFT JOIN rental AS R ON I.inventory_id = R.inventory_id
    LEFT JOIN payment as P ON R.rental_id = P.rental_id
GROUP BY CA.name ORDER BY SUM(P.amount) DESC LIMIT 5;

-- *8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW top_five_genres AS 
(SELECT CA.name, SUM(P.amount) AS 'Gross_Revenue ($)' 
FROM 
	category as CA
    LEFT JOIN film_category AS FC ON CA.category_id = FC.category_id
    LEFT JOIN inventory AS I ON FC.film_id = I.film_id
    LEFT JOIN rental AS R ON I.inventory_id = R.inventory_id
    LEFT JOIN payment AS P ON R.rental_id = P.rental_id
GROUP BY CA.name
ORDER BY SUM(P.amount) DESC LIMIT 5
);

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres; 