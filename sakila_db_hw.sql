#list of all the actors who have Display the first and last names of all actors from the table `actor`.
USE sakila;
SELECT first_name, last_name FROM actor;
#Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
USE sakila;
SELECT concat (first_name,  " ", last_name) as Actor_name FROM actor;
#find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';
#find all actors whose last name contain the letters `GEN`:
SELECT last_name FROM actor WHERE last_name LIKE '%GEN%';
#Find all actors whose last names contain the letters `LI`. Order the rows by last name and first name:
SELECT last_name, first_name FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name
#Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
#Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor ADD COLUMN middle_name VARCHAR(45);
#You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor MODIFY middle_name BLOB;
#Now delete the `middle_name` column.
ALTER TABLE actor DROP COLUMN middle_name;
SELECT*FROM actor;
#List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) as "Count of Last Names" FROM actor GROUP BY last_name;
#List last names of actors and the no. of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as "Count of Last Names" FROM actor GROUP BY last_name HAVING COUNT(last_name) >=2;
#actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. 
#Write a query to fix the record.
UPDATE actor SET first_name = 'Harpo' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
#`GROUCHO` was the correct name. In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
#BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`
#(Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name =
CASE 
WHEN first_name = 'HARPO' 
THEN 'GROUCHO'
ELSE 'MUCHO GROUCHO'
END
WHERE actor_id = 172;
#You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;
#Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address FROM staff s INNER JOIN address a ON s.address_id = a.address_id;
#Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT first_name, last_name, SUM(amount) FROM staff s INNER JOIN payment p ON s.staff_id = p.staff_id GROUP BY p.staff_id ORDER BY last_name ASC;
#List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join. 
SELECT title, COUNT(actor_id) FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id GROUP BY title;
#How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, COUNT(inventory_id) FROM film f INNER JOIN inventory i  ON f.film_id = i.film_id WHERE title = "Hunchback Impossible";
#Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(amount)
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;
# films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
USE Sakila;

SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");
#Use subqueries to display all actors who appear in the film `Alone Trip`.
USE Sakila;

SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));
#Run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
USE Sakila;

SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';
#Sales lagging among young families. Target all family movies for a promotion. Identify all movies categorized as family films.
USE Sakila;

SELECT title, category
FROM film_list
WHERE category = 'Family';
#Display the most frequently rented movies in descending order.
SELECT i.film_id, f.title, COUNT(r.inventory_id)
FROM inventory i
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN film_text f 
ON i.film_id = f.film_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;
#Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment p 
ON p.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);
#Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city, country
FROM store s
INNER JOIN customer cu
ON s.store_id = cu.store_id
INNER JOIN staff st
ON s.store_id = st.store_id
INNER JOIN address a
ON cu.address_id = a.address_id
INNER JOIN city ci
ON a.city_id = ci.city_id
INNER JOIN country coun
ON ci.country_id = coun.country_id;
WHERE country = 'CANADA' AND country = 'AUSTRAILA';
#List the top five genres in gross revenue in descending order. 
#(**Hint**: tables you need: category, film_category, inventory, payment, and rental.)
USE Sakila;

SELECT name, SUM(p.amount) AS gross_revenue FROM category c 
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN inventory i ON i.film_id = fc.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
INNER JOIN payment p ON r.customer_id = p.customer_id
GROUP BY name 
ORDER BY gross_revenue DESC
LIMIT 5;
#In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
CREATE VIEW top_genres AS 
SELECT c.name AS "Top Five Genres", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;
#* 8b. How would you display the view that you created in 8a?
SELECT * FROM top_genres;
#You no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_genres;