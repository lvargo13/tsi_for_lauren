; NCL script to plot ice loss vs Gt Carbon emitted (like fig 2 from Winkelmann) 
; originally created 10/5/15, updated 10/5/15

wks = gsn_open_wks ("x11","IceLoss_CEmissions")		;type of plot (can change x11 to pdf) and file name 
res = True
path = "/Users/lvargo/cosim1/lvargo/GIS_tsi/tsi_for_lauren/"	; path of where the files are

; Years to plot
Yr1 = 3000
Yr2 = 5000
Yr3 = 7500

; loop to calculate GtC
GtC = new(200,float)		; array to store values of totC 
do i = 1,200			; need to start at 1 (not 0) to be able to read in files
	f = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
	C = f->F_co2emit			; read in co2 emissions
	Year = f->T_year			; read in Year
	Cyr = C * 3.154E7			; convert seconds to year
	totC = simpne(Year,Cyr)			; ncl function to calculate area under curve/line
	totC := totC * 1E-12			; convert kg to gigatons
	GtC(i-1) = totC				; store values of totC in array 
	delete([/C,Cyr,totC,Year/])		; delete all values (ncl doesn't overwrite)
end do 

; for each of the 200 runs (for each GtC value), read in ice vol for 1kyr, 3kyr, 5.5kyr in the future 
IceVYr1 = new(200,float)	; create new arrays to store ice volume values
IceVYr2 = new(200,float)
IceVYr3 = new(200,float) 
do j = 1,200    		; do loop to loop through all 200 runs
	h = addfile(path+sprinti("%0.3i",j)+"/Concat_"+sprinti("%0.3i",j)+".nc","r")
       	Year = h->T_year			; read in year
	IceVol = h->L_icevolN                   ; read in ice volume
	
	do k = 0,dimsizes(Year)-1 		; do loop to loop through all years in each run
		if (Year(k) .eq. Yr1) then
			IceVYr1(j-1) = IceVol(k) 
		else if (Year(k) .eq. Yr2) then
			IceVYr2(j-1) = IceVol(k)
                else if (Year(k) .eq. Yr3) then
                        IceVYr3(j-1) = IceVol(k)
        	end if
		end if
		end if
	end do
 
	delete([/Year,IceVol,k,h/])
end do 	

sGtC = dim_pqsort_n(GtC,2,0)  		; sort GtC in ascending order

sIceV = new((/200,4/),float)		; create a new array with all ice volume data
sIceV(:,0) = sGtC
sIceV(:,1) = IceVYr1
sIceV(:,2) = IceVYr2
sIceV(:,3) = IceVYr3
sdata1 = dim_pqsort_n(sIceV,-2,0)	; sort ice volume data based on the order GtC was sorted 

IceVolPerc1 = (sIceV(:,1)/sIceV(0,1)) * 100	; convert ice volume to % of original ice sheet
IceVolPerc2 = (sIceV(:,2)/sIceV(0,2)) * 100
IceVolPerc3 = (sIceV(:,3)/sIceV(0,3)) * 100
IceVfinal = new((/3,200/),float)		; new array with ice %
IceVfinal(0,:) = IceVolPerc1
IceVfinal(1,:) = IceVolPerc2
IceVfinal(2,:) = IceVolPerc3

res@tiXAxisString = "Gt Carbon Emitted"			; X axis label
res@tiYAxisString = "% of Initial Ice Sheet"		; Y axis label
res@vpWidthF = 0.6					; width of plot
res@vpHeightF = 0.4					; height of plot
res@trYMaxF = 103					; Y axis maximum 
res@trXMaxF = 5100					; X axis maximum
res@trXMinF = 325					; X axis minimum
res@xyDashPattern = 0					; make all lines solid 
res@xyLineColors =(/"deepskyblue","tan1","brown1"/)	; line colors 

res@pmLegendDisplayMode = "Always"			; create a legend	
res@pmLegendSide           = "Top"       	        ; change location of legend
res@pmLegendParallelPosF   = .8                 	; move right
res@pmLegendOrthogonalPosF = -0.3              		; move down
res@pmLegendWidthF         = 0.15              		; change width
res@pmLegendHeightF        = 0.1               	  	; change height
res@lgPerimOn              = False               	; turn off box around legend
res@lgLabelFontHeightF     = .017                	; font of labels
res@xyExplicitLegendLabels = (/"Year "+sprinti("%4.0i",Yr1),"Year "+sprinti("%4.0i",Yr2),"Year "+sprinti("%4.0i",Yr3)/) ;labels

plot = gsn_csm_xy (wks,GtC,IceVfinal,res)

