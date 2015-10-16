; NCL script to plot a scatter plot of ice volume vs max C emitted 
; Haven't been able to color-code the dots to total C emissions
; originally created 10/15/15, updated 10/15/15

wks = gsn_open_wks ("x11","MaxC_scat")	; plot type (can be "x11" or "pdf") and file name
color_map = "hotres"
gsn_define_colormap (wks,color_map)	; colormap being used
cmap = gsn_retrieve_colormap(wks)
res = True
path = "/Users/lvargo/cosim1/lvargo/GIS_tsi/tsi_for_lauren/"	; path to files
Clev = new(200,float)			; array to store values of totC

; loop to calculate GtC 
do i = 1,200	; neet to start at 1 (not 0) to read in correct files 
	f = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
	C = f->F_co2emit			; read in co2 emissions
	Year = f->T_year			; read in year
	Cyr = C * 3.154E7			; convert seconds to year
	totCo2 = simpne(Year,Cyr)		; ncl function to calculate area under curve/line
	totC = totCo2 * 1E-12			; convert kg to gigatons
	Clev(i-1) = totC			; store values of totC in array 
	delete([/C,Cyr,totCo2,totC,Year/])	; delete values (ncl won't overwrite)
end do 

ClevMax = max(Clev)			; maximum C emitted value
ClevMax := floattointeger(ClevMax)
ClevMin = min(Clev)			; minimum C emitted value
ClevMin := floattointeger(ClevMin)
lbClev = ispan(350,5050,19) 	; span from min to max C emitted values for coloring 

; plot the first time series
maxC = new(200,float)
IceP = new(200,float)

do i = 1,200
        h = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
        IceVol = h->L_icevolN                   ; read in ice volume
       	C = h->F_co2emit
	maxC(i-1) = max(C)
	;res@trXMinF = 1750			; plot X axis min 
	;res@trYMaxF = 105			; plot Y axis max	
	IceVolPerc = (IceVol/IceVol(0)) * 100	; convert ice volume to a %
	dimIceV = dimsizes(IceVolPerc)
	IceP(i-1) = IceVolPerc(dimIceV-1)
	delete([/IceVol,C,IceVolPerc,dimIceV/])		; delete varaibles, needed bc ncl wont rewrite var
end do 
	
	res@tiYAxisString = "% of Initial Ice Sheet at the Final Time Step"       ; plot Y axis label
        res@tiXAxisString = "Maximum Carbon Emissions"       ; plot X axis label    
	res@xyMarkLineModes   = "Markers"                ; choose which have markers
	res@xyMarkers         =  16                      ; choose type of marker  
	res@xyMarkerColor     = "red"                    ; Marker color
	res@xyMarkerSizeF     = 0.005                     ; Marker size (default 0.01)
	plot = gsn_csm_xy (wks,Clev,IceP,res)
            
