Select * From duration;
Select * From loc;
Select * From payment;
Select * From trips;
Select * From trips_details;

--1. Total number of successful trips?

Select Count(*) As no_of_successful_trips From trips;

Select Count(*) As no_of_successful_trips From trips_details Where end_ride = 1;

Select Sum(end_ride) As no_of_successful_trips From trips_details;

--2. Total number of trips?

Select Count(Distinct tripid) As no_of_trips From trips_details;

--3. Total number of drivers?

Select Count(Distinct driverid) From trips;

--4. Total earnings?

Select Sum(fare) As total_earning From trips;

--5. Total searches?

Select Sum(searches) As no_of_searches From trips_details;

--6. Total searches which got estimates?

Select Sum(searches_got_estimate) As searches_got_estimates From trips_details;

--7. Total searches for quotes?

Select Sum(searches_for_quotes) As searches_for_quotes From trips_details;

--8. Total searches got quotes?

Select Sum(searches_got_quotes) As searches_for_quotes From trips_details;

--9. Total driver cancelled?

Select Sum(a.driver_cancelled) As total_driver_cancelled From
(Select Case When driver_not_cancelled = 1 Then 0 Else 1 End As driver_cancelled From trips_details) As a;

Select Count(*) - Sum(driver_not_cancelled) As total_driver_cancelled
From trips_details;

--10. Total OTP entered?

Select Sum(otp_entered) As total_otp_entered From trips_details

--11. Total end rides?

Select Sum(end_ride) As total_end_rides From trips_details;

--12. What is the average distance per trip?

Select Round(AVG(distance),2) As average_distance From trips;

--13. What is the average fare per trip?

Select Round(AVG(fare),2) As average_fare From trips;

--14. Total distance travelled?

Select Sum(distance) As total_distance From trips;

--15. Which is the most used payment method?

Select p.id As id, p.method As method, Count(t.faremethod) As count_faremethod
From trips As t
Join payment As p 
on t.faremethod = p.id
Group By p.id , p.method , t.faremethod 
Order By Count(t.faremethod) DESC
Limit 1;

--16. List of method according to the sum of amount for payment?

Select p.id As id , p.method As method , Sum(t.fare) As fare
From trips As t
Join payment As p 
on t.faremethod = p.id
Group By p.id , p.method
Order By Sum(t.fare) DESC;

--17. The highest payment was made through which method?

Select p.id As id , p.method As method , t.tripid As tripid , t.fare As fare 
From trips As t
Join payment As p
On t.faremethod = p.id
Order by fare DESC
Limit 1;

--18. Which two locations had the most trips?

Select b.* From
(
Select a.* , dense_rank() Over(Order By a.count_of_trips DESC) As rnk From
(
Select loc_from, loc_to, Count(Distinct tripid) As count_of_trips
From trips
Group By loc_from , loc_to 
Order By Count(Distinct tripid) DESC
) As a
) As b
Where b.rnk = 1;

--19. Top 5 earning drivers?

Select driverid , Sum(fare) As total_fare 
From trips
Group By driverid
Order By Sum(fare) DESC
Limit 5;

--20. Which durations had most trips?

Select duration , Count(*) As cnt
From trips
Group By duration
Order By Count(*) DESC
Limit 1;

--21. Which driver customer pair had the most order?

Select b.* From
(
Select a.* , Dense_rank() Over(Order By a.cnt DESC) As rnk From
(
Select driverid , custid , Count(*) As cnt
From trips
Group By driverid , custid
Order By Count(*) DESC
) As a
) As b
Where rnk = 1;

--22. Searches to estimate rate?

Select Sum(searches_got_estimate)*100/Sum(searches) As searches_to_estimate_rate
From trips_details;

--23. Estimate to searches for quotes rate?

Select Sum(searches_for_quotes)*100/Sum(searches_got_estimate) As estimate_to_searches_for_quotes_rate
From trips_details;

--24. Quote acceptance rate?

--25. Quote to booking rate?

--26. booking cancellation rate?

--27. conversion rate?

--28. Which area got highest trip in which duration?

Select b.* From
(
Select a.* , dense_rank() Over(Partition By duration Order By cnt DESC) As rnk From
(
Select duration , loc_from , Count(distinct tripid) As cnt From trips
Group By duration , loc_from
Order By cnt DESC
) As a
) As b
Where rnk = 1;

--29. Which area got the highest fare?

Select loc_from , Sum(fare) As total_fare
From trips
Group By loc_from
Order By Sum(fare) DESC
Limit 1;

--30. Which area got the highest cancellation?

-- Driver Cancellation

Select b.* From
(
Select a.* , Rank() Over(Order By a.no_driver_cancellation DESC) As rnk From
(
Select loc_from ,(Count(*) - Sum(driver_not_cancelled)) As no_driver_cancellation
From trips_details
Group By loc_from
Order By no_driver_cancellation DESC
) As a
) As b
Where rnk = 1;

-- Customer Cancellation

Select b.* From
(
Select a.* , Rank() Over(Order By a.no_customer_cancellation DESC) As rnk From
(
Select loc_from ,(Count(*) - Sum(customer_not_cancelled)) As no_customer_cancellation
From trips_details
Group By loc_from
Order By no_customer_cancellation DESC
) As a
) As b
Where rnk = 1;