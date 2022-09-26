	
	* Install the following packages (One time install only):
	* ssc install palettes, replace
	* ssc install colrspace, replace
	* ssc install schemepack, replace	
	* net install delaunay, from("https://raw.githubusercontent.com/asjadnaqvi/stata-delaunay-voronoi/main/installation/") replace force
	
	clear
	sysuse auto, clear 

	levelsof foreign, local(lvls)

	foreach x of local lvls {

		cap drop _ID
		delaunay price mpg if foreign==`x', hull 

		ren hull* for`x'*

	}

	twoway ///
	(area for0_Y for0_X, lw(0.3) lc("31 119 180") color("31 119 180%20")) ///
	(scatter price mpg if foreign == 0, msize(0.4) mc("31 119 180")) ///
	(area for1_Y for1_X, lw(0.3) lc("255 127 14") color("255 127 14%20")) ///
	(scatter price mpg if foreign == 1, msize(0.4) mc("255 127 14") ) ///
	, ///
	xlabel(#8, nogrid) ylabel(#8, nogrid) ///
	aspect(1) xsize(1) ysize(1) ///
	legend(order(1 "Foreign" 3 "Domestic") pos(12) ring(1) row(1) size(2)) ///
	title("{bf}Using a Convex Hull to encircle data points by group", pos(11) size(3)) ///
	xtitle("Length") ytitle("Price") ///
	scheme(white_tableau)
