use store;

select * from pancard_analysis;

-- Q1. Identify and handle missing values 
select * from pancard_analysis where pancard is null;
-- Q2. Removes all duplicates
select pancard, count(1) from
pancard_analysis 
group by pancard
having count(1) >1;

-- Handle leading / trailing spaces
select * from pancard_analysis where pancard <> trim(pancard);

-- Correct Letter Case 
select * from pancard_analysis where pancard <> upper(pancard);

-- Cleaned the PanCard Number
select distinct upper(trim(pancard))as Pan_card from 
pancard_analysis 
where pancard is null
and trim(pancard) <> ' ';

-- Function to check if the adjacent characters are the same -- 01C00F09679F==>01C00F

replace  fn_check_adjacent(p_str text)
return boolean
language mysql
as $$

update or replace function fn_check_adjacent(p_str text)
return boolean
language mysql
as $$
begin 
	for i in 1 ..(length(p_str)-1)
    loop
		if substring(p_str, i, 1)=substring(p_str, i+1,1)
        then 
			return true
		end if
	end loop
    return false
end
$$;

SELECT pancard,
       REGEXP_SUBSTR(pancard, '(.)\\1') AS repeated_chars
FROM pancard_analysis
WHERE pancard REGEXP '(.)\\1';


SELECT pancard
FROM pancard_analysis
WHERE EXISTS (
    SELECT 1
    FROM (
        SELECT ASCII(SUBSTRING(pancard, n, 1)) AS c1,
               ASCII(SUBSTRING(pancard, n+1, 1)) AS c2
        FROM  pancard_analysis
        WHERE n < LENGTH(pancard)
    ) t
    WHERE c2 = c1 + 1
);

select ascii('0');

-- Regular expression to validate the pattern or structure of Pan Number-- AAAA00998A
select * from pancard_analysis
where panCard REGEXP ~ '^[A-Z]{5}[0-9]{4}[A-Z]';

-- Invalid or Valid Pan_card Number
select pancard,
				case 
					when pancard REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]'
                    And substring(pancard,4,1) REGEXP '[PBVGTRDFLGHY]'
                    Then 'Valid Pan'
                    else 'Invalid Pan'
                    end as Pan_Status
				from pancard_analysis;

-- Summary Report
select Name,
			count(Pancard) as Total_Pancard
		from pancard_analysis
        group by name
        order by Total_Pancard desc;
        
select count(distinct pancard) as Total_pancard,
			count(*) as Total_interaction
            from pancard_analysis;

