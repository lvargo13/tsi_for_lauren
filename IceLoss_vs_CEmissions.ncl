; NCL script to plot ice loss vs Gt Carbon emitted (like fig 2 from Winkelmann) 
; originally created 10/5/15, updated 10/5/15

wks = gsn_open_wks ("pdf","IceLoss_CEmissions")		;type of plot (can change x11 to pdf) and file name 
res = True
path = "/Users/lvargo/cosim1/lvargo/GIS_tsi/tsi_for_lauren/"	; path of where the files are

; Years to plot
Yr1 = 2500
Yr2 = 3500
Yr3 = 4500
Yr4 = 5500
Yr5 = 6500
Yr6 = 7500

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
IceVYr4 = new(200,float)
IceVYr5 = new(200,float)
IceVYr6 = new(200,float)
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
        	else if (Year(k) .eq. Yr4) then
                        IceVYr4(j-1) = IceVol(k)
		else if (Year(k) .eq. Yr5) then
                        IceVYr5(j-1) = IceVol(k)
		else if (Year(k) .eq. Yr6) then
                        IceVYr6(j-1) = IceVol(k)
		end if
		end if
                end if
                end if
                end if
		end if		
	end do
 
	delete([/Year,IceVol,k,h/])
end do 	

sGtC = dim_pqsort_n(GtC,2,0)  		; sort GtC in ascending order

sIceV = new((/200,7/),float)		; create a new array with all ice volume data
sIceV(:,0) = sGtC
sIceV(:,1) = IceVYr1
sIceV(:,2) = IceVYr2
sIceV(:,3) = IceVYr3
sIceV(:,4) = IceVYr4
sIceV(:,5) = IceVYr5
sIceV(:,6) = IceVYr6
sdata1 = dim_pqsort_n(sIceV,-2,0)	; sort ice volume data based on the order GtC was sorted 

IceVolPerc1 = (sIceV(:,1)/sIceV(0,1)) * 100	; convert ice volume to % of original ice sheet
IceVolPerc2 = (sIceV(:,2)/sIceV(0,2)) * 100
IceVolPerc3 = (sIceV(:,3)/sIceV(0,3)) * 100
IceVolPerc4 = (sIceV(:,4)/sIceV(0,4)) * 100     ; convert ice volume to % of original ice sheet
IceVolPerc5 = (sIceV(:,5)/sIceV(0,5)) * 100
IceVolPerc6 = (sIceV(:,6)/sIceV(0,6)) * 100
IceVfinal = new((/6,200/),float)		; new array with ice %
IceVfinal(0,:) = IceVolPerc1
IceVfinal(1,:) = IceVolPerc2
IceVfinal(2,:) = IceVolPerc3
IceVfinal(3,:) = IceVolPerc4
IceVfinal(4,:) = IceVolPerc5
IceVfinal(5,:) = IceVolPerc6

res@tiXAxisString = "Gt Carbon Emitted"			; X axis label
res@tiYAxisString = "% of Initial Ice Sheet"		; Y axis label
res@vpWidthF = 0.7					; width of plot
res@vpHeightF = 0.4					; height of plot
res@trYMaxF = 103					; Y axis maximum 
res@trXMaxF = 5100					; X axis maximum
res@trXMinF = 325					; X axis minimum
res@xyDashPattern = 0					; make all lines solid 
cMap = "GMT_drywet"
LY = ispan(1850,7500,1000)
LY1 = get_color_rgba(cMap,LY,Yr1)
LY2 = get_color_rgba(cMap,LY,Yr2)  
LY3 = get_color_rgba(cMap,LY,Yr3)
LY4 = get_color_rgba(cMap,LY,Yr4) 
LY5 = get_color_rgba(cMap,LY,Yr5) 
LY6 = get_color_rgba(cMap,LY,Yr6) 
res@xyLineColors = (/LY1,LY2,LY3,LY4,LY5,LY6/)
; res@xyLineColors =(/"blue","limegreen","tan1","darkorange2","red","black"/)	; line colors 
res@xyLineThicknesses =(/2,2,2,2,2,3/)

res@pmLegendDisplayMode = "Always"			; create a legend	
res@pmLegendSide           = "Top"       	        ; change location of legend
res@pmLegendParallelPosF   = .85                 	; move right
res@pmLegendOrthogonalPosF = -0.35            		; move down
res@pmLegendWidthF         = 0.15              		; change width
res@pmLegendHeightF        = 0.13              	  	; change height
res@lgPerimOn              = False               	; turn off box around legend
res@lgLabelFontHeightF     = .016                	; font of labels
res@xyExplicitLegendLabels = (/"Year "+sprinti("%4.0i",Yr1),"Year "+sprinti("%4.0i",Yr2),"Year "+sprinti("%4.0i",Yr3),"Year "+sprinti("%4.0i",Yr4),"Year "+sprinti("%4.0i",Yr5),"Year "+sprinti("%4.0i",Yr6)/) ;labels

plot = gsn_csm_xy (wks,GtC,IceVfinal,res)

