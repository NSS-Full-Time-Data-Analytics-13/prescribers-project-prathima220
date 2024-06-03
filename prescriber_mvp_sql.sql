*/1.a.Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.*/
    
SELECT prescriber.npi AS prescriber,SUM(total_claim_count) AS total_number_of_claims
FROM prescriber
JOIN prescription USING(npi)
GROUP BY prescriber
ORDER BY total_number_of_claims DESC
LIMIT 1;

ANSWER:
			prescriber						total_number_of_claims
			1881634483							99707
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/1b.Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,specialty_description, 
	and the total number of claims.*/
	
SELECT prescriber.npi,prescriber.nppes_provider_first_name,prescriber.nppes_provider_last_org_name,SUM(total_claim_count) AS total_number_of_claims
FROM prescriber 
JOIN prescription USING(npi)
GROUP BY prescriber.npi,prescriber.nppes_provider_first_name,prescriber.nppes_provider_last_org_name
ORDER BY total_number_of_claims DESC;


ANSWER:total 20592 rows 
____________________________2Q___________________________________________________________________________________--------------------------------------------------------
	
*/2)a. Which specialty had the most total number of claims (totaled over all drugs)*/

SELECT SUM(total_claim_count) AS totaled_over_all_drugs,specialty_description
FROM prescriber
JOIN prescription USING(npi)
JOIN drug USING(drug_name)	   
GROUP BY specialty_description
ORDER BY totaled_over_all_drugs DESC
LIMIT 1;

ANSWER:  totaled_over_all_drugs				specialty_description-
				10398706						  Family Practice
							

------------------------------------------------------------------------------------------------------------------------------------------------------------------------


*/2b. Which specialty had the most total number of claims for opioids*/

SELECT SUM(total_claim_count) AS totaled_no_of_claims,drug.opioid_drug_flag,prescriber.specialty_description
FROM drug
JOIN prescription USING(drug_name)
JOIN prescriber USING(npi)
WHERE opioid_drug_flag='Y'
GROUP BY opioid_drug_flag,prescriber.specialty_description
ORDER BY totaled_no_of_claims DESC
LIMIT 5;


ANSWER:900845    Y     Nurse Practitioner
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table*/

SELECT COUNT(*) AS no_associated_prescriptions,P1.specialty_description
FROM prescriber P1
LEFT JOIN prescription P2 ON P1.npi= P2.npi
WHERE P2.npi IS NULL
GROUP BY P1.specialty_description
ORDER BY no_associated_prescriptions DESC;	


ANSWER:
	no_associated_prescriptions   Nurse Practitioner-speciality_description
	      1048        							   Rows-92
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/METHOD_2c:*/
	
SELECT COUNT(*) AS no_associated_prescriptions,P1.specialty_description
FROM prescriber P1
WHERE NOT EXISTS (SELECT P2.npi FROM prescription P2 WHERE P1.npi = P2.npi)
GROUP BY P1.specialty_description
ORDER BY no_associated_prescriptions DESC;

ANSWER:
	no_associated_prescriptions   Nurse Practitioner-speciality_description
	      1048        							   Rows-92
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/2d.**Difficult Bonus:**For each specialty, report the percentage of total claims by that specialty which are for opioids
	Which specialties have a high percentage of opioids*/


SELECT P.specialty_description,COUNT(total_claim_count)/SUM(total_claim_count)*100 AS percentage_of_tot_claims
FROM prescription AS P1
FULL JOIN prescriber P USING(npi)
JOIN drug AS D USING(drug_name)
WHERE opioid_drug_flag='Y'
GROUP BY P.specialty_description
ORDER BY percentage_of_tot_claims DESC
LIMIT 5;	



ANSWER:
specialty_description    		percentage_of_tot_claims
General Acute Care Hospital	     9.09090909090909090900
Critical Care (Intensivists)	 9.09090909090909090900
Allergy/ Immunology	             8.33333333333333333300
Optometry               	     6.55737704918032786900
Case Manager/Care Coordinator    5.55555555555555555600



	

-----------------------------------------------------------3Q----------------------------------------------------------------------------------
	
*/3)a.Which drug (generic_name) had the highest total drug cost*/
	
SELECT D.generic_name,MAX(P.total_drug_cost) AS highest_total_drug_cost
FROM prescription AS P 
JOIN drug AS D USING(drug_name)
GROUP BY D.generic_name
ORDER BY highest_total_drug_cost DESC
LIMIT 1;


ANSWER:
generic_name	highest_total_drug_cost
	
PIRFENIDONE	     2829174.3

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
*/3b.Which drug (generic_name) has the hightest total cost per day*/

SELECT D.generic_name,(P.total_drug_cost/24) AS total_cost_per_day
FROM prescription AS P 
JOIN drug AS D USING(drug_name)
GROUP BY D.generic_name, total_cost_per_day
ORDER BY total_cost_per_day DESC 
LIMIT 1;


ANSWER:
generic_name	highest_total_drug_cost
PIRFENIDONE	    117882.262500000000


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**/

SELECT D.generic_name,ROUND((P.total_drug_cost/24),2) AS total_cost_per_day
FROM prescription AS P 
JOIN drug AS D USING(drug_name)
GROUP BY D.generic_name,total_cost_per_day
LIMIT 1;


ANSWER:
		   		generic_name					total_cost_per_day
   			0.9 % SODIUM CHLORIDE					1.15
-----------------------------------4Q------------------------------------------------------------------------------------------------------------------

*/4a.For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for 
drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', 
and says 'neither' for all other drugs.
**Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
     ELSE 'Neither' END AS drug_type
FROM drug
LIMIT 5;
			   

ANSWER:
	drug_name						drug_type
"1ST TIER UNIFINE PENTIPS"	        "Neither"
"1ST TIER UNIFINE PENTIPS PLUS"	"Neither"
"ABACAVIR"                          "Neither"
"ABACAVIR-LAMIVUDINE"				"Neither"
"ABACAVIR-LAMIVUDINE-ZIDOVUDINE"	"Neither"		   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
*/4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics.*/
	Hint: Format the total costs as MONEY for easier comparision.
	
SELECT SUM(total_drug_cost) ::money AS total_cost,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
     ELSE 'Neither' END AS drug_type
FROM drug
JOIN prescription USING(drug_name)
WHERE opioid_drug_flag ='Y' OR antibiotic_drug_flag = 'Y'
GROUP BY drug_type,opioid_drug_flag,antibiotic_drug_flag 


ANSWER:
	total_cost			drug_type
"$38,435,121.26"     "antibiotic"
"$105,080,626.37"	    "opioid"

-------------------------------------------------------------------5Q-----------------------------------------------------------------------------------
	
*/5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.*/

SELECT COUNT(*) AS cbsa_tn_count,cbsa,cbsaname,fipscounty
FROM CBSA
where cbsaname ILIKE '%TN%'
GROUP BY cbsa,cbsaname,fipscounty
ORDER BY cbsa_tn_count


	ANSWER :Got 58 ROWS
----------------------Q5____________________________________________________________________________________________________________________________________	
	
*/5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.*/;

(SELECT SUM(population) AS total_population,cbsaname
FROM cbsa
JOIN population USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC
	LIMIT 1)
UNION
(SELECT SUM(population) AS min_population,cbsaname
FROM cbsa
JOIN population USING(fipscounty)
GROUP BY cbsaname
ORDER BY min_population ASC
	LIMIT 1)


total_population	cbsaname
116352			    "Morristown, TN"
1830410				"Nashville-Davidson--Murfreesboro--Franklin, TN"

-----------------------check_------------------------------------------------------------------------------------------------------------------------------------------------


*/5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.*/
	
SELECT MAX(population) AS MAX_pop,cbsaname 
	FROM population
JOIN cbsa USING(fipscounty)
WHERE cbsa IS NULL OR population IS NOT NULL
GROUP BY cbsaname ,population

ANSWER:42 ROWS
max-pop  cbsaname
192120	"Clarksville, TN-KY"
127135	"Knoxville, TN"
97887	"Jackson, TN"
63465	"Morristown, TN"
19176	"Knoxville, TN"
21639	"Knoxville, TN"
126437	"Johnson City, TN"


---------------------------------------------6Q--------------------------------------------------------------------------------------------------------
	
*/6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.*/

SELECT drug_name,total_claim_count
FROM prescription
WHERE total_claim_count >=3000
GROUP BY drug_name,total_claim_count

ANSWER:9 ROWS
	
drug_name				total_claim_count
"FUROSEMIDE"				3083
"GABAPENTIN"				3531
"HYDROCODONE-ACETAMINOPHEN"	3376
"LEVOTHYROXINE SODIUM"		3023
"LEVOTHYROXINE SODIUM"		3101
"LEVOTHYROXINE SODIUM"		3138
"LISINOPRIL"				3655
"MIRTAZAPINE"				3085
"OXYCODONE HCL"				4538
	
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
*/6b.For each instance that you found in part a, add a column that indicates whether the drug is an opioid.*/

SELECT drug_name,total_claim_count,opioid_drug_flag
FROM prescription
JOIN drug USING(drug_name)
WHERE total_claim_count >=3000 AND opioid_drug_flag ='Y'
GROUP BY drug_name,total_claim_count, opioid_drug_flag 


ANSWER:
	drug_name					total_claim_count	opioid_drug_flag 
"HYDROCODONE-ACETAMINOPHEN"			3376				"Y"
"OXYCODONE HCL"						4538				"Y"
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
*/6c.Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.*/

SELECT drug_name,total_claim_count,opioid_drug_flag,nppes_provider_first_name,nppes_provider_last_org_name
FROM prescription
JOIN drug USING(drug_name)
JOIN prescriber USING(npi)
WHERE total_claim_count >=3000 AND opioid_drug_flag ='Y'
GROUP BY drug_name,total_claim_count, opioid_drug_flag,nppes_provider_first_name,nppes_provider_last_org_name 

	
ANSWER:	
	drug_name					total_claim_count	 opioid_drug_flag	nppes_provider_first_name			nppes_provider_last_org_name 

"HYDROCODONE-ACETAMINOPHEN"		3376			"Y"							"DAVID"									"COFFEY"
"OXYCODONE HCL"					4538			"Y"							"DAVID"									"COFFEY"

	

-----------------------------------------------7Q---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/7. The goal of this exercise is to generate a full list of all pain managementspecialists in Nashville and the
	number of claims they had for each opioid.   **Hint:** The results from all 3 parts will have 637 rows.
*/7a.First, create a list of all npi/drug_name combinations for pain management specialists 
  (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
  where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. 
  You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.*/


SELECT P.npi,D.drug_name,P.specialty_description
FROM prescriber P
CROSS JOIN  drug D
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' 
	                           AND opioid_drug_flag = 'Y'
GROUP BY P.npi,D.drug_name,P.specialty_description;


ANSWER:637 ROWS with npi,drug_nmae and specialty_description
	

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
 */7b. Next, report the number of claims per drug per prescriber.Be sure to include all combinations, whether or not the prescriber had any claims.
	You should report the npi, the drug name, and the number of claims (total_claim_count).*/

SELECT P.npi,D.drug_name,SUM(P1.total_claim_count) AS total_claim_count
FROM prescriber P
CROSS JOIN  drug D
FULL JOIN prescription P1 USING(drug_name)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' 
	                           AND opioid_drug_flag = 'Y'
GROUP BY P.npi,D.drug_name;

ANSWER:637 ROWS with npi,drug_nmae and total_claim_count
----------------------------------------------------------------------------------------------------------------------------------------------------------------

*/7c.Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.
Hint - Google the COALESCE function.*/

SELECT P.npi,D.drug_name,COALESCE(SUM(P1.total_claim_count),0) AS total_claim_count
FROM prescriber P
CROSS JOIN  drug D
FULL JOIN prescription P1 USING(drug_name)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' 
	                           AND opioid_drug_flag = 'Y'
GROUP BY P.npi,D.drug_name;

ANSWER:637 ROWS with npi,drug_nmae and total_claim_count filling null with 0

----------------------------------------****END_FOR_PRESCRIBERS_MVP*********************************--------------------------------------------------------------------------



--------------******BONUS*****---------------*******BONUS********----************PRESCRIBERS_BONUS***************************__________________________________________________------------------------------------------------------------------------------------------------


	
---------------------------------------1Q------------------------------------------------------------------------------------------------

*/1.How many npi numbers appear in the prescriber table but not in the prescription table*/

SELECT COUNT( DISTINCT npi) 
FROM prescriber;

ANSWER:	count
		25050
----------------------------------------------------------2Q--------------------------------------------------------------------------------------------------------
	
*/2)a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice*/

SELECT D.generic_name,P2.specialty_description 
FROM prescription AS P
JOIN drug AS D USING(drug_name)
JOIN prescriber AS P2 USING(npi)
WHERE specialty_description ILIKE '%Family practice%'
LIMIT 5;


ANSWER:
	
generic_name		specialty_description
"GABAPENTIN"		"Family Practice"
"GLIPIZIDE"			"Family Practice"
"PAROXETINE HCL"	"Family Practice"
"SUCRALFATE"		"Family Practice"
"HYDRALAZINE HCL"	"Family Practice"
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	
*/2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology*/

SELECT D.generic_name,P2.specialty_description 
FROM prescription AS P
JOIN drug AS D USING(drug_name)
JOIN prescriber AS P2 USING(npi)
WHERE specialty_description ILIKE 'Cardiology%'
LIMIT 5;

ANSWER:
	
generic_name				specialty_description
"CLONIDINE HCL"					"Cardiology"
"SPIRONOLACTONE"				"Cardiology"
"PANTOPRAZOLE SODIUM"			"Cardiology"
"VALSARTAN"						"Cardiology"
"FLUDROCORTISONE ACETATE"		"Cardiology"
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/2c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? 
	Combine what you did for parts a and b into a single query to answer this question.*/

(SELECT D.generic_name,P2.specialty_description 
FROM prescription AS P
JOIN drug AS D USING(drug_name)
JOIN prescriber AS P2 USING(npi)
WHERE specialty_description ILIKE '%Family practice%'
LIMIT 5)
UNION
(SELECT D.generic_name,P2.specialty_description 
FROM prescription AS P
JOIN drug AS D USING(drug_name)
JOIN prescriber AS P2 USING(npi)
WHERE specialty_description ILIKE 'Cardiology%'
LIMIT 5)

ANSWER:
generic_name				specialty_description
"GABAPENTIN"	 			"Family Practice"
"VALSARTAN"	     			"Cardiology"
"SPIRONOLACTONE"			"Cardiology"
"FLUDROCORTISONE ACETATE"	"Cardiology"
"PANTOPRAZOLE SODIUM"		"Cardiology"
"PAROXETINE HCL"			"Family Practice"
"CLONIDINE HCL"				"Cardiology"
"SUCRALFATE"				"Family Practice"
"GLIPIZIDE"	"Family			 Practice"
"HYDRALAZINE HCL"			"Family Practice"
	

-------------------------------------------------------------3Q----------------------------------------------------------------------------------------------------------
*/3.Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
a.First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs.
Report the npi, the total number of claims, and include a column showing the city.*/

SELECT prescriber.npi,prescriber.nppes_provider_city AS city,COUNT(total_claim_count) AS total_no_of_claims
FROM prescriber                    
JOIN prescription USING(npi)
WHERE nppes_provider_city ILIKE '%Nashville%' 
GROUP BY city,prescriber.npi
ORDER BY total_no_of_claims DESC
LIMIT 5;

ANSWER:
	npi			city	  total_no_of_claims 
1538103692	"NASHVILLE"		356
1962499582	"NASHVILLE"		300
1881638971	"NASHVILLE"		282
1659331924	"NASHVILLE"		271
1013957976	"NASHVILLE"		230
	
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 */3b. Now, report the same for Memphis.*/

SELECT prescriber.npi,prescriber.nppes_provider_city AS city,COUNT(total_claim_count) AS total_no_of_claims
FROM prescriber                    
JOIN prescription USING(npi)
WHERE nppes_provider_city ILIKE '%Memphis%' 
GROUP BY city,prescriber.npi
ORDER BY total_no_of_claims DESC
LIMIT 5;

ANSWER:
  npi			  city	   total_no_of_claims
1346291432	"MEMPHIS"	349
1225056872	"MEMPHIS"	337
1669470316	"MEMPHIS"	327
1275601346	"MEMPHIS"	326
1801896881	"MEMPHIS"	299
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/3c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.*/

(SELECT prescriber.npi,prescriber.nppes_provider_city AS city,COUNT(total_claim_count) AS total_no_of_claims
FROM prescriber                    
JOIN prescription USING(npi)
WHERE nppes_provider_city ILIKE '%Nashville%' 
GROUP BY city,prescriber.npi
ORDER BY total_no_of_claims DESC
LIMIT 5)
UNION
(SELECT prescriber.npi,prescriber.nppes_provider_city AS city,COUNT(total_claim_count) AS total_no_of_claims
FROM prescriber                    
JOIN prescription USING(npi)
WHERE nppes_provider_city ILIKE '%Memphis%' 
GROUP BY city,prescriber.npi
ORDER BY total_no_of_claims DESC
LIMIT 5)
UNION	
(SELECT prescriber.npi,prescriber.nppes_provider_city AS city,COUNT(total_claim_count) AS total_no_of_claims
FROM prescriber                    
JOIN prescription USING(npi)
WHERE nppes_provider_city ILIKE '%Knoxville%' 
GROUP BY city,prescriber.npi
ORDER BY total_no_of_claims DESC
LIMIT 5)
UNION
(SELECT prescriber.npi,prescriber.nppes_provider_city AS city,COUNT(total_claim_count) AS total_no_of_claims
FROM prescriber                    
JOIN prescription USING(npi)
WHERE nppes_provider_city ILIKE '%Chattanooga%' 
GROUP BY city,prescriber.npi
ORDER BY total_no_of_claims DESC
LIMIT 5)


ANSWER:20 ROWS


----------------------4Q-------------------------------------------------------------------------------------------------------------------------------------------------
	
SELECT * FROM prescriber
SELECT * FROM prescription
SELECT * FROM drug
SELECT * FROM zip_fips
SELECT * FROM cbsa
SELECT * FROM population
SELECT * FROM fips_county
SELECT * FROM overdose_deaths

*/4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.*/






















	



