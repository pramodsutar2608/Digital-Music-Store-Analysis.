create table album2
(
album_id number(10) primary key,
title varchar2(50),
artist_id number(10)
);

alter table album2
modify(title varchar2(100));

select * from album2;

rename album2 to album;

create table artist
(artist_id number(10),
name varchar2(50));

alter table artist
modify (name varchar2(100));

create table customer
(customer_id number(10) primary key,
first_name varchar2 (100),
last_name varchar2 (100),
company varchar2 (100),
address varchar2 (100),
city varchar2(100),
state varchar2 (100),
country varchar2(100),
postal_code varchar2(100),
phone number(20),
fax varchar2(50),
email varchar2(100),
support_rep_id number(10));

alter table customer
modify (phone varchar2(100));

select * from employee;

select * from genre;

select * from invoice;

select * from invoice_line;

select * from media_type;

select * from playlist;

select * from playlist_track;

select * from track;

commit;

==================================================================================
                        	Question Set 1 - Easy 

 ----------------------------------------------------------------------------------
 Q1: Who is the senior most employee based on job title? ;
 
 select title,last_name,first_name from employee
 where 
 levels=(select max(levels) from employee);
 
SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
FETCH FIRST 1 ROWS ONLY;

select * from employee;

--------------------------------------------------------------------------------
Q2: Which countries have the most Invoices? ;

select * from invoice;

select billing_country,count(*) as total_invoices
from invoice
group by billing_country
order by count(*) desc;

---------------------------------------------------------------------------------
Q3: What are top 3 values of total invoice? 

select * from invoice;

select total from invoice
order by total desc;

SELECT invoice_id,customer_id,total
FROM invoice
ORDER BY total desc
FETCH FIRST 3 ROWS ONLY;

select * from (select invoice_id,customer_id,
            invoice_date,billing_address,
            row_number()Over(order by invoice_id) r from invoice
            )
            where R in (1,2,3);


---------------------------------------------------------------------------------

Q4: Which city has the best customers? We would like to throw a promotional 
    Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals 

    
select * from invoice;

select billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by sum(total) desc;

select billing_city, sum(total) as invoice_total -- Error
from invoice
group by billing_city
order by sum(total) desc
fetch first 1 row only;

--------------------------------------------------------------------------------

Q5: Who is the best customer? The customer who has spent the most money 
will be declared the best customer. 
Write a query that returns the person who has spent the most money.

select * from customer;
select * from invoice;

select a.customer_id,a.first_name,a.last_name,      -- error
        sum(b.total) from customer a join invoice b
        on a.customer_id=b.customer_id
        group by b.customer_id
        order by sum(b.total) desc;
        
SELECT a.customer_id, a.first_name, a.last_name, SUM(b.total) as total_sum
FROM customer a
JOIN invoice b ON a.customer_id = b.customer_id
GROUP BY a.customer_id, a.first_name, a.last_name
ORDER BY total_sum DESC
fetch first 1 row only;



================================================================================

                        Question Set 2 - Moderate 

--------------------------------------------------------------------------------

Q1: Write query to return the email, first name, last name, & Genre of 
all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A.;

select * from customer;
select * from genre;
select * from track;

select distinct a.email,a.first_name,a.last_name,
        e.name from customer a join invoice b
        on a.customer_id=b.customer_id
        join invoice_line c
        on b.invoice_id=c.invoice_id
        join track d
        on c.track_id=d.track_id
        join genre e
        on d.genre_id=e.genre_id
        where e.name like 'Rock'
        order by a.email;
 
 -------------------------------------------------------------------------------
 
Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 
10 rock bands. 

select * from artist;
select * from album;
select * from track;
select * from genre;

 SELECT artist.artist_id,Artist.Name, COUNT(Genre.Name)
FROM Genre, Track, Album, Artist
WHERE Genre.Genre_Id=Track.Genre_Id
AND Track.Album_Id=Album.Album_Id AND Album.Artist_Id=Artist.Artist_Id
AND Genre.Name='Rock'
GROUP BY artist.artist_id,Artist.Name
ORDER BY COUNT(Genre.Name) DESC
fetch first 10 rows only;

 
--------------------------------------------------------------------------------
Q3: Return all the track names that have a song length longer than the 
average song length. 
Return the Name and Milliseconds for each track. Order by the song length 
with the longest songs listed first. 

select * from track;

select name,milliseconds from track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc ;

================================================================================

                    Question Set 3 - Advance 

--------------------------------------------------------------------------------

Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent ;

select a.first_name,f.name as Artist,sum(c.unit_price*c.quantity)as total_amount
from customer a, invoice b, invoice_line c,track d,album e,artist f
where a.customer_id=b.customer_id and b.invoice_id=c.invoice_id
      and c.track_id=d.track_id and d.album_id=e.album_id and
      e.artist_id=f.artist_id
      group by a.first_name,f.name
      order by total_amount desc;

--------------------------------------------------------------------------------

Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount 
of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres. 

select * from invoice;
select * from invoice_line;
select * from track;
select * from genre;

select a.billing_country,d.name,sum(b.track_id*b.unit_price)
from invoice a,invoice_line b,track c,genre d
where a.invoice_id=b.invoice_id and b.track_id=c.track_id
and c.genre_id=d.genre_id
group by a.billing_country,d.name
order by sum(b.track_id*b.unit_price) desc;


--------------------------------------------------------------------------------

Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. 

WITH Customers_with_country AS (
    SELECT
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, first_name, last_name, billing_country
)
SELECT *
FROM Customers_with_country
WHERE RowNo <= 1;



==========================================================================================
 