	
	* Install the following packages (One time install only):
	* ssc install palettes, replace
	* ssc install colrspace, replace
	* ssc install schemepack, replace	
	* net install delaunay, from("https://raw.githubusercontent.com/asjadnaqvi/stata-delaunay-voronoi/main/installation/") replace force
	
	cd "~/Desktop/"
	
	sysuse auto, clear
	
	generate ID_var = _n
	
	tempfile original
	save `original'
	
	* Generating by group of foreign
	
	levelsof foreign, local(forlev)
	
	foreach level of local forlev {
		
		preserve
		
			keep if foreign == `level'
			delaunay price mpg, tri hull vor(lines polygons) replace
			
			rename (_ID hull_ID hull_Y hull_X) =_`level'
			
			tempfile file`level'
			save "`file`level''"
			
		restore
		
		capture noisily erase "_vorlines.dta"
		sleep 1000
		capture noisily erase "_vorpoly.dta"
		sleep 1000
		capture noisily erase "_triangles.dta"
		
		use `original', clear 
		
	}
	
	use `file0', clear
	keep *ID* hull*
	rename _ID_0 _ID_1
	
	merge 1:1 _ID_1 using `file1', keepusing(_ID_1 hull_ID_1 hull_X_1 hull_Y_1) 
	keep ID_var hull_X* hull_Y*	
	
	merge 1:1 ID_var using `original'
	
	
	twoway ///
					(line hull_Y_1 hull_X_1, lw(0.3) lc("31 119 180") recast(area) color("31 119 180%20")) ///
					(scatter price mpg if foreign == 1, msize(0.4) mc("31 119 180")) ///
					(line hull_Y_0 hull_X_0, lw(0.3) lc("255 127 14") recast(area) color("255 127 14%20")) ///
					(scatter price mpg if foreign == 0, msize(0.4) mc("255 127 14") ) ///
					, ///
					xlabel(#8, nogrid) ylabel(#8, nogrid) ///
					aspect(1) xsize(1) ysize(1) ///
					legend(order(1 "Foreign" 3 "Domestic") pos(12) ring(1) row(1) size(2)) ///
					title("{bf}Using a Convex Hull to encircle data points by group", pos(11) size(3)) ///
					xtitle("Length") ytitle("Price") ///
					scheme(white_tableau)
					
	graph export "~/Desktop/scatterplot_encircle_convex_hull.png", as(png) width(3840) replace