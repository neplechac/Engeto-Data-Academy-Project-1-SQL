-- PAYROLL VIEW
CREATE OR REPLACE VIEW v_cz_avg_payroll AS (
	SELECT cpib.name,
		cp.payroll_year,
		AVG(cp.value) AS value
	FROM czechia_payroll AS cp
	JOIN czechia_payroll_industry_branch AS cpib
		ON cp.industry_branch_code = cpib.code
	WHERE cp.value_type_code = 5958 
		AND calculation_code = 200
	GROUP BY cpib.name, cp.payroll_year
	ORDER BY cpib.name, cp.payroll_year
);


-- PRICES VIEW
CREATE OR REPLACE VIEW v_cz_avg_prices AS (
	SELECT cpc.name,
		YEAR(cp.date_from) AS `year`,
		ROUND(AVG(cp.value), 2) AS value,
		cpc.price_value,
		cpc.price_unit
	FROM czechia_price AS cp
	JOIN czechia_price_category AS cpc
		ON cp.category_code = cpc.code
	WHERE region_code IS NULL
	GROUP BY name, YEAR(cp.date_from)
);


-- GDP VIEW
CREATE OR REPLACE VIEW v_cz_gdp AS (
	SELECT `year`, 
		GDP
	FROM economies
	WHERE country = 'Czech Republic' 
		AND `year` >= (
			WITH start_year AS (
				SELECT `year` 
				FROM v_cz_avg_prices 
				UNION
				SELECT payroll_year 
				FROM v_cz_avg_payroll
				)
			SELECT min(`year`) 
			FROM start_year
		)
);


-- PRIMARY TABLE
CREATE OR REPLACE TABLE t_ondrej_plechac_project_SQL_primary_final (
	name varchar(255),
	`year` int(4),
	value double,
	code int(3),
	price_value double,
	unit varchar(2)
);

INSERT INTO t_ondrej_plechac_project_SQL_primary_final (
	SELECT vpay.name, 
		vpay.payroll_year,
		vpay.value,
		100,
		NULL,
		"Kč"
	FROM v_cz_avg_payroll AS vpay 
);

INSERT INTO t_ondrej_plechac_project_SQL_primary_final (
	SELECT vpri.name, 
		vpri.`year`, 
		vpri.value, 
		200, 
		vpri.price_value,
		vpri.price_unit 
	FROM v_cz_avg_prices AS vpri
);

INSERT INTO t_ondrej_plechac_project_SQL_primary_final (
	SELECT "GDP",
		vgdp.`year`,
		vgdp.GDP,
		300,
		NULL,
		NULL
	FROM v_cz_gdp AS vgdp
);


-- SECONDARY TABLE
CREATE OR REPLACE TABLE t_ondrej_plechac_project_SQL_secondary_final AS (
	SELECT e.country,
		e.`year`,
		e.GDP,
		e.gini,
		e.population
	FROM economies AS e
	JOIN countries AS c 
		ON e.country  = c.country
	WHERE c.continent  = 'Europe'
		AND e.`year` >= (
			WITH start_year AS (
				SELECT `year` 
				FROM v_cz_avg_prices 
				UNION
				SELECT payroll_year 
				FROM v_cz_avg_payroll
				)
			SELECT min(`year`) 
			FROM start_year
		)
	ORDER BY e.country, e.`year`
);


-- AVERAGE SALARY VIEW (all industries combined)
CREATE OR REPLACE VIEW v_salary AS (
	SELECT `year`, 
		ROUND(AVG(value), 2) AS salary
	FROM t_ondrej_plechac_project_SQL_primary_final
	WHERE code = 100
	GROUP BY `year`
);


-- AVERAGE PRICE VIEW (all categories combined)
CREATE OR REPLACE VIEW v_price AS (
	SELECT `year`, 
		ROUND(AVG(value), 2) AS price
	FROM t_ondrej_plechac_project_SQL_primary_final
	WHERE code = 200
	GROUP BY `year`
);


-- QUESTION 1
-- 2000 vs 2021
SELECT s1.name, 
	s1.`year`, 
	s1.value, 
	s2.`year` AS actual, 
	s2.value
FROM t_ondrej_plechac_project_SQL_primary_final AS s1
JOIN t_ondrej_plechac_project_SQL_primary_final AS s2
	ON s1.name = s2.name 
	AND s2.`year` = 2021
WHERE s1.code = 100 
	AND s1.value < s2.value
	AND s1.`year` = 2000
ORDER BY name;

-- annual (year-on-year decrease only)
SELECT s1.name, 
	s1.`year`, 
	s1.value, 
	s2.`year` AS year_prev, 
	s2.value
FROM t_ondrej_plechac_project_SQL_primary_final AS s1
JOIN t_ondrej_plechac_project_SQL_primary_final AS s2
	ON s1.name = s2.name 
	AND s1.`year` = s2.`year` + 1
WHERE s1.code = 100 
	AND s1.value < s2.value
ORDER BY `year`, name;


-- QUESTION 2
SELECT s.`year`,
	s.salary,
	p1.name,
	p1.value,
	FLOOR(s.salary / p1.value) AS milk_amount,
	CONCAT(p1.price_value, " ", p1.unit) AS milk_unit, 
	p2.name,
	p2.value,
	FLOOR(s.salary / p2.value) AS bread_amount,
	CONCAT(p2.price_value, " ", p2.unit) AS bread_unit 
FROM v_salary AS s
JOIN t_ondrej_plechac_project_SQL_primary_final AS p1
	ON s.`year` = p1.`year`
	AND p1.name = 'Mléko polotučné pasterované'
JOIN t_ondrej_plechac_project_SQL_primary_final AS p2
	ON s.`year` = p2.`year`
	AND p2.name = 'Chléb konzumní kmínový'
ORDER BY s.`year`;


-- QUESTION 3
-- 2006 vs 2018
SELECT p1.name, 
	p1.`year`,
	p1.value,
	p2.`year`,
	p2.value,
	ROUND((p2.value - p1.value) / p1.value * 100, 2) AS `diff%`
FROM t_ondrej_plechac_project_SQL_primary_final AS p1
JOIN t_ondrej_plechac_project_SQL_primary_final AS p2
	ON p1.name = p2.name
	AND p2.`year` = 2018
WHERE p1.`year` = 2006 
	AND p1.code = 200
ORDER BY `diff%`;

-- annual
SELECT p1.name, 
	p1.`year`, 
	p1.value,	
	p2.`year` AS year_prev, 
	p2.value,
	ROUND((p1.value - p2.value) / p2.value * 100, 2) AS `diff%`
FROM t_ondrej_plechac_project_SQL_primary_final AS p1
JOIN t_ondrej_plechac_project_SQL_primary_final AS p2
	ON p1.name = p2.name 
	AND p1.`year` = p2.`year` + 1
WHERE p1.code = 200 
ORDER BY `diff%`;


-- QUESTION 4
SELECT s1.`year`,
	s1.salary,
	s2.salary AS salary_prev,
	p1.price,
	p2.price AS price_prev,
	ROUND((s1.salary - s2.salary) / s2.salary * 100, 2) AS `salary_diff%`,
	ROUND((p1.price - p2.price) / p2.price * 100, 2) AS `price_diff%`,
	ROUND((s1.salary - s2.salary) / s2.salary * 100, 2) - ROUND((p1.price - p2.price) / p2.price * 100, 2) AS comp
FROM v_salary AS s1
JOIN v_salary AS s2
	ON s1.`year` = s2.`year` + 1
JOIN v_price AS p1
	ON s1.`year` = p1.`year`
JOIN v_price AS p2
	ON p1.`year` = p2.`year` + 1;
		

-- QUESTION 5
SELECT s1.`year`,
	ROUND((g1.value - g2.value) / g2.value * 100, 2) AS `gdp_diff%`,
	ROUND((s1.salary - s2.salary) / s2.salary * 100, 2) AS `salary_diff%`,
	ROUND((p1.price - p2.price) / p2.price * 100, 2) AS `price_diff%`
FROM v_salary AS s1
JOIN v_salary AS s2
	ON s1.`year` = s2.`year` + 1
JOIN v_price AS p1
	ON s1.`year` = p1.`year`
JOIN v_price AS p2
	ON p1.`year` = p2.`year` + 1
JOIN t_ondrej_plechac_project_SQL_primary_final AS g1
	ON s1.`year` = g1.`year`
	AND g1.code = 300
JOIN t_ondrej_plechac_project_SQL_primary_final AS g2
	ON g1.`year` = g2.`year` + 1
	AND g2.code = 300
ORDER BY s1.`year`;
		
