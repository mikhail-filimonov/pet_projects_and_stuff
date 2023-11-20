----------------------------------------
--1. Вывести список сотрудников, получающих заработную плату большую чем у непосредственного руководителя
----------------------------------------

SELECT e."ID" AS "EmployeeId"
FROM employee AS e
JOIN employee AS b ON e."CHIEF_ID" = b."ID"
				  AND e."SALARY" > b."SALARY" 

----------------------------------------
--2. Вывести список сотрудников, получающих максимальную заработную плату в своем отделе
----------------------------------------
WITH
cte AS (SELECT e."DEPARTMENT_ID"
	    MAX(e."SALARY") AS "MaxSalary"
		FROM employee AS e
		GROUP BY e."DEPARTMENT_ID")

SELECT e."ID" AS "EmployeeId"
FROM employee AS e
JOIN cte ON e."DEPARTMENT_ID" = cte."DEPARTMENT_ID"
		AND e."SALARY" = cte."MaxSalary" 

----------------------------------------
--3. Вывести список ID отделов, количество сотрудников в которых не превышает 3 человек
----------------------------------------

SELECT e."DEPARTMENT_ID"
	   COUNT(e."ID") AS "EmployeeCount"
FROM employee AS e
GROUP BY e."DEPARTMENT_ID"
HAVING COUNT(e."ID") <= 3

----------------------------------------
--4. Список опоздавших
----------------------------------------
WITH
cte AS( -- ищем разницу во времени для каждого сотрудника
		SELECT a."ФИО"
		EXTRACT(hour FROM a."Часовой пояс") AS "Разница" 
		FROM a),

cte_2 AS( -- определяем время начала работы и запуска ПО в соответствии с часовым поясом
		 SELECT b."ФИО",
		 cast('08:00' AS time) + interval '1 hour' * cte."Разница" AS "Начало рабочего дня",
		 b."дата/время UTC" + interval '1 hour' * cte."Разница" AS "Время запуска ПО"
		 FROM b
		 JOIN a ON a."ФИО" = b."ФИО"
		  AND b."код события" = 1 -- запуск ПО)

SELECT "ФИО",
	   "Время запуска ПО", -- по местному времени
	   EXTRACT(hour FROM ("Время запуска ПО" - "Начало рабочего дня")) AS "Часов опоздания"
FROM cte_2
WHERE EXTRACT(hour FROM ("Время запуска ПО" - "Начало рабочего дня")) > 0