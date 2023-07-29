/* QUESTIONS */
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * FROM Facilities WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) FROM Facilities WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance FROM Facilities
WHERE membercost > 0 AND membercost < 0.2 * monthlymaintenance;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM Facilities WHERE facid IN (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance < 100 THEN 'cheap' ELSE 'expensive' END AS 'cheap_or_expensive'
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members WHERE Members.memid <> 0);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT Facilities.name 'Facility Name', CONCAT(Members.firstname,' ',Members.surname) 'Full Name'
FROM Members JOIN Bookings
ON Members.memid = Bookings.memid
JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Bookings.facid IN (0,1) AND Members.memid <> 0
ORDER BY 2 ASC;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT m.memid, surname || ' ' || firstname AS full_name, starttime, name, slots,
CASE WHEN m.memid = 0 THEN guestcost ELSE membercost END AS cost,
CASE WHEN m.memid = 0 THEN 'guest' ELSE 'member' END AS guest_or_member,
CASE WHEN m.memid = 0 THEN guestcost*slots ELSE membercost*slots END AS fee
FROM Bookings b JOIN Members m ON b.memid = m.memid
JOIN Facilities f ON b.facid = f.facid
WHERE (starttime LIKE '%2012-09-14%') AND (CASE WHEN m.memid = 0 THEN guestcost*slots ELSE membercost*slots END > 30)
ORDER BY fee DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */ 
SELECT memid, surname || ' ' || firstname AS full_name, starttime, name, slots,
CASE WHEN memid = 0 THEN guestcost ELSE membercost END AS cost,
CASE WHEN memid = 0 THEN 'guest' ELSE 'member' END AS guest_or_member,
CASE WHEN memid = 0 THEN guestcost*slots ELSE membercost*slots END AS fee

FROM
(SELECT bookid,m.memid,starttime,slots,surname,firstname, address, zipcode, telephone,recommendedby,
joindate,f.facid,name,membercost,guestcost,initialoutlay,monthlymaintenance
FROM Bookings b JOIN Members m ON b.memid = m.memid JOIN Facilities f ON b.facid = f.facid
WHERE (starttime LIKE '%2012-09-14%') AND (CASE WHEN m.memid = 0 THEN guestcost*slots ELSE membercost*slots END > 30))

ORDER BY fee DESC;

/* PART 2: SQLite
Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.

QUESTIONS:
Q10: Produce a list of facilities with a total revenue less than 1000.*/
SELECT * FROM

(SELECT Facilities.name facility, SUM((memid<>0)*membercost + (memid=0)*guestcost) AS cost
FROM Bookings JOIN Facilities ON Bookings.facid = Facilities.facid GROUP BY facility)

WHERE cost > 1000 ORDER BY cost DESC

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT m1.memid,m1.firstname,m1.surname,m2.memid,m2.firstname,m2.surname
FROM Members m1 JOIN Members m2 ON m1.recommendedby = m2.memid
WHERE m1.recommendedby <> '' ORDER BY m1.firstname, m1.surname

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT b.facid, f.name facility_name, m.memid,(m.surname||' '||m.firstname) full_name,
COUNT(1) usage
FROM Members m JOIN Bookings b on m.memid = b.memid
JOIN Facilities f ON b.facid = f.facid WHERE m.memid <> 0
GROUP BY b.facid, m.memid
ORDER BY facility_name,full_name

/* Q13: Find the facilities usage by month, but not guests */
SELECT f.name facility_name, strftime('%m',b.starttime) month, COUNT(1) usage
FROM Facilities f JOIN Bookings b ON f.facid = b.facid
WHERE b.memid <> 0
GROUP BY facility_name,month
ORDER BY facility_name,month
