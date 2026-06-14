/* This is a script I originally created in early 2026 while learning SQL as practice.
 * I'm using PostgreSQL with DBeaver and the DVD Rental sample database, looking into
 * underperforming inventory. This was the first SQL project I just sat down with the data
 * and tried to see what I could find without a pre-set list of instructions to follow.
 */

-- film details
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating 
from film f
;

-- adding number of rentals
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating
	,count(distinct r.rental_id) as Times_rented
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
group by f.film_id 
	,f.title
	,f.rental_rate
	,f.rating
order by times_rented  desc
;

-- adding genre
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating
	,c.name as Genre
	,count(distinct r.rental_id) as Times_rented
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id 
group by f.film_id 
	,f.title
	,f.rental_rate
	,f.rating
	,c.name
order by c.name
	,times_rented desc
;

--checking for null category
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating 
	,coalesce(c.name, 'Uncategorized') as Genre
	,count(distinct r.rental_id) as Times_rented
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
--where fc.category_id is null  commented out after confirming there are no nulls here
group by f.film_id 
	,f.title
	,f.rental_rate
	,f.rating
	,c.name
order by c.name 
	,times_rented 
;

-- Ranking movies by Genre to see the lowest performers (Rank 1 = least rentals)
-- side note, i prefer rank over dense rank as when i see a film is rank 8, i know 7 films have a lower rank number
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating
	,coalesce(c.name, 'Uncategorized') as Genre
	,count(distinct r.rental_id) as Times_rented
	,rank() over (partition by c.name order by count(distinct r.rental_id))
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
group by f.film_id 
	,f.title
	,f.rental_rate
	,f.rating
	,c.name
order by c.name 
	,times_rented
;


-- listing the 10 worst performers per Genre, rank = 1 is the worst.
with cte as (
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating
	,c.name as Genre
	,count(distinct i.inventory_id) as number_copies
	,count(distinct r.rental_id) as Times_rented
	,rank() over (partition by c.name order by count(distinct r.rental_id)) as film_rank
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
group by f.film_id 
	,f.title
	,f.rental_rate
	,f.rating
	,c.name
)
select film_id
	,film_name
	,rental_rate
	,rating
	,genre
	,number_copies
	,times_rented
	,film_rank
from cte
where film_rank <= 10
order by genre
	,film_rank
;


-- anomoly detected - we have 42 films in the list that we don't own a physical copy of.
with cte as (
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating
	,c.name as Genre
	,count(distinct i.inventory_id) as number_copies
	,count(distinct r.rental_id) as Times_rented
	,rank() over (partition by c.name order by count(distinct r.rental_id))
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
group by f.film_id 
	,f.title
	,f.rental_rate
	,f.rating
	,c.name
order by c.name 
	,times_rented
)
select 'NO COPIES AVAILABLE' as Anomaly
	,*
from cte
where number_copies = 0
;


-- **** corrected listing the N worst performers per Genre that are in inventory
with cte as (
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating
	,c.name as Genre
	,count(distinct i.inventory_id) as number_copies
	,count(r.rental_id) as Times_rented
	,rank() over (partition by c.name order by count(r.rental_id)) as film_rank
from film f
inner join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
group by f.film_id 
	,f.title
	,f.rental_rate
	,f.rating
	,c.name
)
select film_id
	,film_name
	,rental_rate
	,rating
	,genre
	,number_copies
	,times_rented
	,film_rank
from cte
where film_rank <= 5
;


-- Working on idle time by each individual inventory_id

select f.film_id 
	,i.inventory_id 
	,f.title as Film_Name
	,r.rental_id 
	,f.rental_rate
	,f.rating
	,cast(r.rental_date as date) as Rented_On
	,cast(r.return_date as date) as Returned_on
	,c.name as Genre
	,cast(r.rental_date as date) - cast(lag(r.return_date) over (partition by i.inventory_id order by r.rental_id) as date) as Days_Shelved
from film f
inner join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
order by genre
;


-- found 168 movies that have been on the shelf at least 6 months 187 + days.  After these movies the next drops to 45 days or less
with cte as (
select f.film_id 
	,f.title as Film_Name
	,f.rental_rate
	,f.rating
	,c.name as Genre
	,cast(r.rental_date as date) - cast(lag(r.return_date) over (partition by i.inventory_id order by r.rental_id) as date) as Days_Shelved
from film f
inner join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id 
)
select film_id 
	,Film_Name
	,rental_rate
	,rating
	,genre
	,max(days_shelved) as Max_Shelf_Time
from cte
group by cte.film_id 
	,cte.Film_Name
	,cte.rental_rate
	,cte.rating
	,cte.genre
having max(days_shelved) >= 45
order by genre
	,max_shelf_time desc nulls first
;

