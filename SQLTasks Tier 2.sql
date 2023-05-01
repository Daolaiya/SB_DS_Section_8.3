/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */

/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * FROM Facilities WHERE membercost <> 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT * FROM Facilities WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance FROM Facilities
WHERE membercost <> 0 AND membercost < 0.2 * monthlymaintenance;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM Facilities WHERE facid IN (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance < 100 THEN 'cheap'
ELSE 'expensive'
END AS 'cheap_or_expensive'
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members) AND Members.memid <> 0;

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
SELECT Facilities.name 'Facility Name', CONCAT(Members.firstname, ' ', Members.surname) 'Full Name', 
CASE 
WHEN (Members.memid <> 0 AND Facilities.membercost * Bookings.slots > 30) THEN Facilities.membercost * Bookings.slots 
WHEN (Members.memid = 0 AND Facilities.guestcost * Bookings.slots > 30) THEN Facilities.guestcost * Bookings.slots 
END AS 'Cost'

FROM Facilities 
JOIN Bookings 
ON Facilities.facid = Bookings.facid 
JOIN Members 
ON Bookings.memid = Members.memid 

WHERE 
Bookings.starttime LIKE "2012-09-14%"
AND
    (
        (Members.memid <> 0 AND Facilities.membercost * Bookings.slots > 30)
        OR
        (Members.memid = 0 AND Facilities.guestcost * Bookings.slots > 30)
    )
ORDER BY 3 DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */ 
SELECT * FROM

(SELECT Facilities.name 'Facility Name', CONCAT(Members.firstname, ' ', Members.surname) 'Full Name', 
/* Members.memid,Facilities.membercost * Bookings.slots, Facilities.guestcost * Bookings.slots, */
CASE 
WHEN (Members.memid <> 0 AND Facilities.membercost * Bookings.slots > 30) THEN Facilities.membercost * Bookings.slots 
WHEN (Members.memid = 0 AND Facilities.guestcost * Bookings.slots > 30) THEN Facilities.guestcost * Bookings.slots 
END AS 'Cost'

FROM Facilities 
JOIN Bookings 
ON Facilities.facid = Bookings.facid 
JOIN Members 
ON Bookings.memid = Members.memid 

WHERE 
Bookings.starttime LIKE "2012-09-14%"
AND (Facilities.membercost * Bookings.slots > 30 OR Facilities.guestcost * Bookings.slots > 30)

ORDER BY 3 DESC) AS temp_table

WHERE temp_table.Cost IS NOT NULL;

/* PART 2: SQLite
Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
- Badminton Court -> $604.5
- Pool Table -> $265.0
- Snooker Table -> $115.0
- Table Tennis -> $90.0

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
- Anna Mackenzie was recommended by Darren Smith
- Anne Baker was recommended by Ponder Stibbons
- Charles Owen was recommended by Darren Smith
- David Jones was recommended by Janice Joplette
- David Pinker was recommended by Jemima Farrell
- Douglas Jones was recommended by David Jones
- Erica Crumpet was recommended by Tracy Smith
- Florence Bader was recommended by Ponder Stibbons
- Gerald Butters was recommended by Darren Smith
- Henrietta Rumney was recommended by Matthew Genting
- Henry Worthington-Smyth was recommended by Tracy Smith
- Jack Smith was recommended by Darren Smith
- Janice Joplette was recommended by Darren Smith
- Joan Coplin was recommended by Timothy Baker
- John Hunt was recommended by Millicent Purview
- Matthew Genting was recommended by Gerald Butters
- Millicent Purview was recommended by Tracy Smith
- Nancy Dare was recommended by Janice Joplette
- Ponder Stibbons was recommended by Burton Tracy
- Ramnaresh Sarwin was recommended by Florence Bader
- Tim Boothe was recommended by Tim Rownam
- Timothy Baker was recommended by Jemima Farrell

/* Q12: Find the facilities with their usage by member, but not guests */
facility_name   full_name                usage   
Badminton Court Smith Darren             132
                Smith Tracy               32
                Mackenzie Anna            30
                Butters Gerald            20
                Stibbons Ponder           16
                Boothe Tim                12
                Smith Jack                12
                Baker Anne                10
                Dare Nancy                10
                Bader Florence             9
                Jones David                8
                Pinker David               7
                Sarwin Ramnaresh           7
                Farrell Jemima             7
                Baker Timothy              7
                Owen Charles               6
                Rownam Tim                 4
                Worthington-Smyth Henry    4
                Purview Millicent          2
                Jones Douglas              2
                Hunt John                  2
                Crumpet Erica              2
                Tracy Burton               2
                Tupperware Hyacinth        1
Massage Room 1  Rownam Tim                80
                Boothe Tim                36
                Butters Gerald            32
                Tracy Burton              31
                Farrell Jemima            29
                Smith Darren              28
                Smith Jack                27
                Genting Matthew           25
                Baker Timothy             24
                Jones David               19
                Dare Nancy                19
                Stibbons Ponder           19
                Joplette Janice           12
                Owen Charles              11
                Sarwin Ramnaresh           8
                Smith Tracy                6
                Pinker David               3
                Hunt John                  3
                Baker Anne                 3
                Crumpet Erica              2
                Tupperware Hyacinth        1
                Worthington-Smyth Henry    1
                Coplin Joan                1
                Mackenzie Anna             1
Massage Room 2  Dare Nancy                 5
                Jones David                4
                Sarwin Ramnaresh           3
                Baker Anne                 2
                Bader Florence             2
                Owen Charles               2
                Joplette Janice            2
                Coplin Joan                2
                Rownam Tim                 2
                Butters Gerald             1
                Genting Matthew            1
                Smith Jack                 1
Pool Table      Rownam Tim               241
                Baker Timothy             85
                Mackenzie Anna            70
                Smith Tracy               61
                Worthington-Smyth Henry   33
                Tracy Burton              30
                Smith Darren              28
                Joplette Janice           27
                Farrell David             25
                Boothe Tim                25
                Bader Florence            23
                Dare Nancy                19
                Genting Matthew           18
                Sarwin Ramnaresh          13
                Stibbons Ponder           12
                Baker Anne                12
                Coplin Joan               11
                Pinker David               9
                Jones David                8
                Tupperware Hyacinth        8
                Smith Jack                 7
                Butters Gerald             6
                Purview Millicent          5
                Rumney Henrietta           3
                Jones Douglas              2
                Owen Charles               1
                Farrell Jemima             1
Snooker Table   Joplette Janice           68
                Smith Tracy               45
                Boothe Tim                43
                Butters Gerald            34
                Bader Florence            33
                Dare Nancy                23
                Owen Charles              22
                Farrell Jemima            21
                Tracy Burton              20
                Stibbons Ponder           20
                Sarwin Ramnaresh          18
                Pinker David              16
                Rumney Henrietta          14
                Smith Darren              12
                Coplin Joan               10
                Mackenzie Anna             7
                Smith Jack                 5
                Tupperware Hyacinth        5
                Jones David                2
                Farrell David              1
                Purview Millicent          1
                Genting Matthew            1
Squash Court    Baker Anne                49
                Tracy Burton              35
                Smith Darren              14
                Joplette Janice           14
                Boothe Tim                12
                Smith Jack                 9
                Butters Gerald             9
                Jones David                8
                Farrell Jemima             8
                Owen Charles               7
                Smith Tracy                6
                Baker Timothy              5
                Pinker David               3
                Sarwin Ramnaresh           2
                Rumney Henrietta           2
                Mackenzie Anna             2
                Stibbons Ponder            2
                Bader Florence             2
                Tupperware Hyacinth        1
                Farrell David              1
                Purview Millicent          1
                Jones Douglas              1
                Hunt John                  1
                Coplin Joan                1
Table Tennis    Rownam Tim                69
                Bader Florence            42
                Smith Tracy               28
                Smith Darren              28
                Genting Matthew           26
                Tracy Burton              24
                Owen Charles              24
                Baker Timothy             24
                Coplin Joan               21
                Pinker David              17
                Mackenzie Anna            16
                Farrell Jemima            12
                Jones David               11
                Joplette Janice            9
                Purview Millicent          6
                Smith Jack                 5
                Dare Nancy                 5
                Boothe Tim                 4
                Worthington-Smyth Henry    3
                Stibbons Ponder            3
                Sarwin Ramnaresh           3
                Crumpet Erica              2
                Hunt John                  1
                Baker Anne                 1
                Butters Gerald             1
Tennis Court 1  Butters Gerald            57
                Tracy Burton              31
                Smith Tracy               30
                Dare Nancy                25
                Jones David               25
                Smith Jack                22
                Joplette Janice           19
                Owen Charles              17
                Pinker David              16
                Baker Timothy             14
                Jones Douglas              9
                Coplin Joan                7
                Farrell David              6
                Rownam Tim                 6
                Baker Anne                 6
                Sarwin Ramnaresh           5
                Boothe Tim                 4
                Hunt John                  4
                Crumpet Erica              1
                Farrell Jemima             1
                Genting Matthew            1
                Bader Florence             1
                Stibbons Ponder            1
Tennis Court 2  Boothe Tim                52
                Owen Charles              41
                Baker Anne                35
                Stibbons Ponder           31
                Jones David               30
                Smith Darren              19
                Dare Nancy                11
                Sarwin Ramnaresh          11
                Bader Florence             8
                Joplette Janice            8
                Baker Timothy              7
                Rownam Tim                 6
                Hunt John                  4
                Butters Gerald             3
                Tracy Burton               3
                Smith Tracy                2
                Rumney Henrietta           1
                Smith Jack                 1
                Farrell Jemima             1
                Farrell David              1
                Purview Millicent          1

/* Q13: Find the facilities usage by month, but not guests */
facility_name   month    count   
Badminton Court 9        161
                8        132
                7         51
Massage Room 1  9        191
                8        153
                7         77
Massage Room 2  9         14
                8          9
                7          4
Pool Table      9        408
                8        272
                7        103
Snooker Table   9        199
                8        154
                7         68
Squash Court    9         87
                8         85
                7         23
Table Tennis    9        194
                8        143
                7         48
Tennis Court 1  9        132
                8        111
                7         65
Tennis Court 2  9        126
                8        109
                7         41
