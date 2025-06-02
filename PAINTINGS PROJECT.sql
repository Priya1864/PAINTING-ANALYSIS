select*from artist;
select*from canvas_size;
select*from image_link;
select*from museum;
select*from museum_hours;
select*from product_size;
select*from subject;
select*from work;

---identify the museums which are open on both sunday and monday .display musem name,city
select name,city ,day from museum m
join museum_hours mh
on mh.museum_id=m.museum_id
where day in('Sunday','Monday')
order by 3 ;

select  museum_id FROM museum_hours mh
where day in('Sunday','Monday')
group by 1;

--#METHOD 1
SELECT m.name, m.city
FROM museum m
JOIN museum_hours mh ON m.museum_id = mh.museum_id
WHERE mh.day IN ('Sunday', 'Monday')
GROUP BY m.museum_id, m.name, m.city
HAVING COUNT(DISTINCT mh.day) = 2
ORDER BY m.name;


--#METHOD 2
select m.name,city,day from museum_hours mh join museum m
on m.museum_id=mh.museum_id
where day='Sunday'
and exists (select 1 from museum_hours mh1
                  where mh1.museum_id=mh.museum_id
			  and mh1.day= 'Monday')

--Find museums that are open on both Sunday and Monday.
SELECT museum_id
FROM museum_hours
WHERE day IN ('Sunday', 'Monday')
GROUP BY museum_id;

--#METHOD 3
SELECT *
FROM museum_hours
WHERE day = 'Sunday'
AND museum_id IN (
    SELECT museum_id
    FROM museum_hours
    WHERE day IN ('Sunday', 'Monday')
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 2
);

--#method 4
SELECT s.*
FROM museum_hours s
JOIN museum_hours m
  ON s.museum_id = m.museum_id
WHERE s.day = 'Sunday' AND m.day = 'Monday';




----which museum is open for the longest during a day .display museum name,state and hours 
--open and which day?
--#METHOD 1
SELECT 
    m.name,
    m.state,
    mh.day,
    (EXTRACT(HOUR FROM close_time) * 60 + EXTRACT(MINUTE FROM close_time))
  - (EXTRACT(HOUR FROM open_time) * 60 + EXTRACT(MINUTE FROM open_time)) AS minutes_open
FROM (
  SELECT 
    museum_id,
    day,
    -- convert text like '08:00 PM' to time using to_timestamp()
    to_timestamp(open, 'HH12:MI AM')::time AS open_time,
    to_timestamp(close, 'HH12:MI PM')::time AS close_time
  FROM museum_hours
) mh
JOIN museum m ON m.museum_id = mh.museum_id
ORDER BY minutes_open DESC
LIMIT 1;


---#METHOD 2
select name,day, state, to_timestamp(open ,'HH:MI AM') AS OPEN_TIME,
TO_TIMESTAMP(CLOSE,'HH:MI PM') AS CLOSE_TIME ,
(TO_TIMESTAMP(CLOSE,'HH:MI PM') - to_timestamp(open ,'HH:MI AM') )AS DURATION 
,RANK() OVER(ORDER BY (TO_TIMESTAMP(CLOSE,'HH:MI PM') - to_timestamp(open ,'HH:MI AM')) DESC) AS RNK
from museum_hours mh
join museum m
on m.museum_id=mh.museum_id
limit 1;

----display the country and the city with most no of museums.output 2 seperate columns
--to mention the city and country.
---if thre are multiple value ,seprate them with comma
with cte as (select country,count(*) as noofmuseums,rank() over(order by count(*) desc) ran from museum 
group by 1
order by 2 desc),
cte1 as(select city,count(*) as noofmuseums ,rank() over(order by count(*) desc) as rn from museum 
group by 1
order by 2 desc)
select  string_agg(distinct country,', ') as country,
string_agg(city, ' ,') as city 
from cte
cross join cte1 
where ran=1 and rn=1;




 ---1. Fetch all the paintings which are not displayed on any museums?
select *from work where museum_id is null;
--- 2. Are there museums without any paintings? 
select * from museum m
	where not exists (select 1 from work w
					 where w.museum_id=m.museum_id);

 --3. How many paintings have an asking price of more than their regular price?
select * from product_size
where sale_price > regular_price;

SELECT * FROM product_size
WHERE work_id = '160244' AND size_id = '24';


UPDATE product_size
SET sale_price = 200
WHERE work_id = '160244' AND size_id = '24';


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'product_size';


 
 ---4. Identify the paintings whose asking price is less than 50% of its regular price
 select * 
	from product_size
	where sale_price < (regular_price*0.5);


--- 5. Which canva size costs the most?
select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over(order by sale_price desc) as rnk 
		  from product_size) ps
	join canvas_size cs on cs.size_id::text=ps.size_id
	where ps.rnk=1;			

	select*from canvas_size;


 ---6. Delete duplicate records from work, product_size, subject and image_link tables

delete from work 
	where ctid not in (select min(ctid)
						from work
						group by work_id );
						

SELECT work_id, size_id, COUNT(*) 
FROM product_size
GROUP BY work_id, size_id
HAVING COUNT(*) > 1;
WITH ranked_rows AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY work_id, size_id
           ORDER BY ctid
         ) AS rn
  FROM product_size
)
DELETE FROM product_size
WHERE ctid IN (
  SELECT ctid
  FROM ranked_rows
  WHERE rn > 1
);

delete from product_size 
	where ctid not in (select min(ctid)
						from product_size
						group by work_id, size_id );

						
SELECT work_id, subject, COUNT(*) AS records
FROM subject
GROUP BY work_id, subject
HAVING COUNT(*) > 1;


WITH ranked_subjects AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY work_id, subject
           ORDER BY ctid
         ) AS rn
  FROM subject
)
SELECT *
FROM ranked_subjects
WHERE rn > 1;

WITH ranked_subjects AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY work_id, subject
           ORDER BY ctid
         ) AS rn
  FROM subject
)
DELETE FROM subject
WHERE ctid IN (
  SELECT ctid
  FROM ranked_subjects
  WHERE rn > 1
);



	delete from subject 
	where ctid not in (select min(ctid)
						from subject
						group by work_id, subject );
--#first checking 
SELECT work_id, COUNT(*) AS records
FROM image_link
GROUP BY work_id
HAVING COUNT(*) > 1;

---using rownumber for deleting duplicates
WITH ranked_images AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY work_id
           ORDER BY ctid
         ) AS rn
  FROM image_link
)
DELETE FROM image_link
WHERE ctid IN (
  SELECT ctid
  FROM ranked_images
  WHERE rn > 1
);
--if primary key not present then we use this one
delete from image_link 
	where ctid not in (select min(ctid)
						from image_link
						group by work_id );



--- 7. Identify the museums with invalid city information in the given dataset
select * from museum 
	where city ~ '^[0-9]';

SELECT * FROM museum
WHERE SUBSTRING(city FROM 1 FOR 1) BETWEEN '0' AND '9';

SELECT * FROM museum
WHERE city LIKE '0%' OR city LIKE '1%' OR city LIKE '2%' OR city LIKE '3%'
   OR city LIKE '4%' OR city LIKE '5%' OR city LIKE '6%' OR city LIKE '7%'
   OR city LIKE '8%' OR city LIKE '9%';



 --8. Museum_Hours table has 1 invalid entry. Identify it and remove it.
 select*from museum_hours;
 SELECT museum_id, day, COUNT(*) AS cnt
FROM museum_hours
GROUP BY museum_id, day
HAVING COUNT(*) > 1;

WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY museum_id, day ORDER BY ctid) AS rn
  FROM museum_hours
)
SELECT *
FROM ranked
WHERE rn > 1;
delete from museum_hours where museum_id=80;

-- 9. Fetch the top 10 most famous painting subject
select*from subject;

select * 
	from (
		select s.subject,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10;


-- 11. How many museums are open every single day?

select count(1)
	from (select museum_id, count(1)
		  from museum_hours
		  group by museum_id
		  having count(1) = 7) x;


 ---12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select m.name as museum, m.city,m.country,x.no_of_painintgs
	from (	select m.museum_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			group by m.museum_id) x
	join museum m on m.museum_id=x.museum_id
	where x.rnk<=5;


 
-- 13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
select a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;


 --14. Display the 3 least popular canva sizes
 select label,ranking,no_of_paintings
	from (
		select cs.size_id,cs.label,count(1) as no_of_paintings
		, dense_rank() over(order by count(1) ) as ranking
		from work w
		join product_size ps on ps.work_id=w.work_id
		join canvas_size cs on cs.size_id::text = ps.size_id
		group by cs.size_id,cs.label) x
	where x.ranking<=3;


 --16. Which museum has the most no of most popular painting style?
 with pop_style as 
			(select style
			,rank() over(order by count(1) desc) as rnk
			from work
			group by style),
		cte as
			(select w.museum_id,m.name as museum_name,ps.style, count(1) as no_of_paintings
			,rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			join pop_style ps on ps.style = w.style
			where w.museum_id is not null
			and ps.rnk=1
			group by w.museum_id, m.name,ps.style)
	select museum_name,style,no_of_paintings
	from cte 
	where rnk=1;

-- 17. Identify the artists whose paintings are displayed in multiple countries
with cte as
		(select distinct a.full_name as artist
		--, w.name as painting, m.name as museum
		, m.country
		from work w
		join artist a on a.artist_id=w.artist_id
		join museum m on m.museum_id=w.museum_id)
	select artist,count(1) as no_of_countries
	from cte
	group by artist
	having count(1)>1
	order by 2 desc;



-- 19. Identify the artist and the museum where the most expensive and least expensive 
--painting is placed. Display the artist name, sale_price, painting name, museum 
--name, museum city and canvas label
with cte as 
		(select *
		, rank() over(order by sale_price desc) as rnk
		, rank() over(order by sale_price ) as rnk_asc
		from product_size )
	select w.name as painting
	, cte.sale_price
	, a.full_name as artist
	, m.name as museum, m.city
	, cz.label as canvas
	from cte
	join work w on w.work_id=cte.work_id
	join museum m on m.museum_id=w.museum_id
	join artist a on a.artist_id=w.artist_id
	join canvas_size cz on cz.size_id = cte.size_id::NUMERIC
	where rnk=1 or rnk_asc=1;

 --20. Which country has the 5th highest no of paintings?
with cte as 
		(select m.country, count(1) as no_of_Paintings
		, rank() over(order by count(1) desc) as rnk
		from work w
		join museum m on m.museum_id=w.museum_id
		group by m.country)
	select country, no_of_Paintings
	from cte 
	where rnk=5;


 
 --21. Which are the 3 most popular and 3 least popular painting styles?
with cte as 
		(select style, count(1) as cnt
		, rank() over(order by count(1) desc) rnk
		, count(1) over() as no_of_records
		from work
		where style is not null
		group by style)
	select style
	, case when rnk <=3 then 'Most Popular' else 'Least Popular' end as remarks 
	from cte
	where rnk <=3
	or rnk > no_of_records - 3;


 
 ---22. Which artist has the most no of Portraits paintings outside USA?. Display artist 
---name, no of paintings and the artist nationality.
select full_name as artist_name, nationality, no_of_paintings
	from (
		select a.full_name, a.nationality
		,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as rnk
		from work w
		join artist a on a.artist_id=w.artist_id
		join subject s on s.work_id=w.work_id
		join museum m on m.museum_id=w.museum_id
		where s.subject='Portraits'
		and m.country != 'USA'
		group by a.full_name, a.nationality) x
	where rnk=1;	



 



