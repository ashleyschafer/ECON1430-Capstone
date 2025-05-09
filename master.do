*****************************************************
* Event Study: Recreational Marijuana Legalization
*****************************************************

*----------------------------------------------------
* Load Packages and Prepare Environment
*----------------------------------------------------
cap which did_imputation
if _rc ssc install did_imputation, replace
cap which event_plot
if _rc ssc install event_plot, replace

clear
cd "/Users/ashleyschafer/Desktop/capstone"
import delimited "Copy of Cleaned State Data - Sheet1.csv", clear

*----------------------------------------------------
* Encode and Clean Variables
*----------------------------------------------------
encode state, gen(state_id)
destring rec_legal_year, replace force
gen treated = !missing(rec_legal_year)
replace rec_legal_year = . if treated == 0

*----------------------------------------------------
* Generate Crime Rates (per 100,000)
*----------------------------------------------------
gen total_property_crime = burglary_total + mv_theft_total + larceny_total
gen total_violent_crime  = homicide_total + agg_assault_total + robbery_total
gen total_crime = total_property_crime + total_violent_crime

gen total_crime_rate = (total_crime / pop_est) * 100000
gen total_property_crime_rate = (total_property_crime / pop_est) * 100000
gen total_violent_crime_rate  = (total_violent_crime / pop_est) * 100000

drop if missing(year, state_id, total_crime_rate)

*----------------------------------------------------
* Optional: generate event time only for treated (labeling)
*----------------------------------------------------
gen event_time = year - rec_legal_year if treated == 1

//drop if event_time > 7

*****************************************************
* 1. DID Estimation: Total Crime
*****************************************************
did_imputation total_crime_rate state_id year rec_legal_year, ///
    allhorizons pretrend(5) minn(5) autosample
	

event_plot, default_look ///
    graph_opt(xtitle("Years Since Legalization") ///
              ytitle("ATT on Total Crime Rate (per 100k)") ///
              ylabel(-2000(500)2000) ///
              xlabel(-5(1)7) ///
              xscale(range(-5 7)) ///
              title("Effect of Legalization on Total Crime") ///
              yline(0, lpattern(dash)) ///
              graphregion(color(white)))

graph export "att_total_crime.png", width(2000) replace

* Tag only one row per state
bysort state_id (year): gen tag = (_n == 1)

* Now tabulate treatment status for unique states only
tab treated if tag == 1




*****************************************************
* 2. DID Estimation: Property Crime
*****************************************************
did_imputation total_property_crime_rate state_id year rec_legal_year, ///
    allhorizons pretrend(5) minn(5) autosample

event_plot, default_look ///
    graph_opt(xtitle("Years Since Legalization") ///
              ytitle("ATT on Property Crime Rate (per 100k)") ///
              ylabel(-2000(500)2000) ///
              title("Legalization & Property Crime") ///
              yline(0, lpattern(dash)) ///
              graphregion(color(white)))
graph export "att_property_crime.png", width(2000) replace

*****************************************************
* 3. DID Estimation: Violent Crime
*****************************************************
did_imputation total_violent_crime_rate state_id year rec_legal_year, ///
    allhorizons pretrend(5) minn(5) autosample

event_plot, default_look ///
    graph_opt(xtitle("Years Since Legalization") ///
              ytitle("ATT on Violent Crime Rate (per 100k)") ///
              ylabel(-500(300)500) ///
              title("Legalization & Violent Crime") ///
              yline(0, lpattern(dash)) ///
              graphregion(color(white)))
graph export "att_violent_crime.png", width(2000) replace



*****************************************************
* 4. Robustness Placebo Check (Lead = 5 years before)
*****************************************************
gen placebo_year = rec_legal_year - 5
*----------------------------------------------------
* Placebo Test: Total Crime
*----------------------------------------------------
did_imputation total_crime_rate state_id year placebo_year, ///
    allhorizons pretrend(5) minn(5) autosample

event_plot, default_look ///
    graph_opt(xtitle("Years Since Placebo Treatment") ///
              ytitle("Placebo ATT on Total Crime Rate (per 100k)") ///
              ylabel(-2000(500)2000) ///
              title("Placebo Test: Total Crime") ///
              yline(0, lpattern(dash)) ///
              graphregion(color(white)))

graph export "placebo_total_crime.png", width(2000) replace
   
*----------------------------------------------------
* Placebo Test: Property Crime
*----------------------------------------------------
did_imputation total_property_crime_rate state_id year placebo_year, ///
    allhorizons pretrend(5) minn(5) autosample

event_plot, default_look ///
    graph_opt(xtitle("Years Since Placebo Treatment") ///
              ytitle("Placebo ATT on Property Crime Rate (per 100k)") ///
              ylabel(-2000(500)2000) ///
              title("Placebo Test: Property Crime") ///
              yline(0, lpattern(dash)) ///
              graphregion(color(white)))

graph export "placebo_property_crime.png", width(2000) replace

*----------------------------------------------------
* Placebo Test: Violent Crime
*----------------------------------------------------
did_imputation total_violent_crime_rate state_id year placebo_year, ///
    allhorizons pretrend(5) minn(5) autosample

event_plot, default_look ///
    graph_opt(xtitle("Years Since Placebo Treatment") ///
              ytitle("Placebo ATT on Violent Crime Rate (per 100k)") ///
              ylabel(-2000(500)2000) ///
              title("Placebo Test: Violent Crime") ///
              yline(0, lpattern(dash)) ///
              graphregion(color(white)))

graph export "placebo_violent_crime.png", width(2000) replace

*****************************************************
* Summary Statistics
*****************************************************
summarize total_crime_rate total_property_crime_rate ///
          total_violent_crime_rate pop_est treated rec_legal_year year
		  
estpost tabstat total_crime_rate total_property_crime_rate total_violent_crime_rate ///
    med_house_income unem_rate poverty_rate educ_attainment, by(treated) statistics(mean sd)
esttab using summary_stats_by_group.rtf, replace

* Create a single entry per treated state
keep if treated == 1
bysort state_id (year): keep if _n == 1

* Keep only needed variables
keep state rec_legal_year

* List the states and when they legalized
sort rec_legal_year
list state rec_legal_year, clean

* Optional: export to CSV
export delimited using "treated_states_timing.csv", replace

*****************************************************
* State Data
*****************************************************

* RELOAD the data from scratch to undo prior drops
clear
import delimited "Copy of Cleaned State Data - Sheet1.csv", clear

* Encode state and create treatment flag
encode state, gen(state_id)
destring rec_legal_year, replace force
gen treated = !missing(rec_legal_year)

* Keep one observation per state
bysort state_id (year): gen tag = (_n == 1)
keep if tag == 1

* Keep only relevant columns
keep state treated rec_legal_year
sort treated state

list state treated rec_legal_year, clean


*****************************************************
* End of File
*****************************************************
