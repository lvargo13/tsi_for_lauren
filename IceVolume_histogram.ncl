; NCL script to plot tsi of ice volume and 2 histograms with different numbers of blocks
; note: the colors of the histograms in this script are not correct (the colors do not 
;  represent the mean C emissions for each block)
; The script: IceV_histo_manual.ncl does plot a histogram with the correct colors
; Originally created 9/29/15, updated 10/15/15

wks = gsn_open_wks ("pdf","IceVolume_histo")	; plot type (can be "x11" or "pdf") and file name
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
; lbClev = fspan(ClevMin,ClevMax,256)

IceV_final = new(200,float)
; plot the first time series
	i = 1
        h = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
        IceVol = h->L_icevolN                   ; read in ice volume
        Year = h->T_year                        ; read in year  
	res@trXMinF = 1750			; plot X axis min 
	res@trYMaxF = 105			; plot Y axis max
	res@tiYAxisString = "% of Initial Ice Sheet"	; plot Y axis label
	res@gsnDraw = False			; don't draw plot yet
	res@gsnFrame = False			; don't make plot yet
	res@xyLineColors = get_color_index(color_map,lbClev,Clev(i-1))	; color the lines based on c emissions value
	IceVolPerc = (IceVol/IceVol(0)) * 100	; convert ice volume to a %
	IceV_final(i-1) = IceVolPerc(dimsizes(IceVolPerc)-1) 
	plot = gsn_csm_xy (wks,Year,IceVolPerc,res)	; plot	
delete(i)

; loop to plot the additional time series
do i = 2,199
	g = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
       	IceVol1 = g->L_icevolN			; read in ice volume 
       	Year1 = g->T_year			; read in year
	res@xyLineColors = get_color_index(color_map,lbClev,Clev(i-1))
    	IceVolPerc1 = (IceVol1/IceVol1(0)) * 100
	IceV_final(i-1) = IceVolPerc1(dimsizes(IceVolPerc1)-1)
	plot1 = gsn_csm_xy (wks,Year1,IceVolPerc1,res)	
	overlay(plot,plot1)			; overlay- needed to plot all time series on same plot
	delete([/IceVol1,IceVolPerc1,Year1/])		; delete varaibles, needed bc ncl wont rewrite var
end do 
delete(i)

; plot the last time series, and draw the final plot
	i = 200
        j = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
        IceVol2 = j->L_icevolN                  ; read in ice volume 
        Year2 = j->T_year                       ; read in year
        res@xyLineColors = get_color_index(color_map,lbClev,Clev(i-1))
       	IceVolPerc2 = (IceVol2/IceVol2(0)) * 100
	IceV_final(i-1) = IceVolPerc2(dimsizes(IceVolPerc2)-1)
	plot2 = gsn_csm_xy (wks,Year2,IceVolPerc2,res)
        overlay(plot1,plot2)                    ; overlay- needed to plot all time series on same plot
        draw(plot)                              ; finally draw plot
             
  res_lb                    = True	       ; turn on label bar res
  res_lb@vpWidthF           = 0.04             ; label bar location 
  res_lb@vpHeightF          = 0.6              ; label bar location
  res_lb@lbPerimOn          = False            ; turn off box around label bar
  res_lb@lbFillColors       = cmap(2:,:)       ; label bar colors
  res_lb@lbMonoFillPattern  = True             ; fill label bar solid
  res_lb@lbLabelFontHeightF = 0.013            ; label font height
  res_lb@lbTitleString      = "Gt Carbon Emitted"         ; title
  res_lb@lbTitleFontHeightF = 0.012           		  ; title font height
  res_lb@lbBoxLinesOn = False			; no boxes on each color
  gsn_labelbar_ndc (wks,dimsizes(lbClev),""+lbClev,0.82,0.8,res_lb)  

frame(wks)


gsn_reverse_colormap(wks)

resh = True
resh@gsnHistogramHorizontal  = True            ; draw horizontal histogram
resh@gsnHistogramNumberOfBins = 20
resh@tiYAxisString = "% of Initial Ice Sheet at the Final Timestep"    ; plot Y axis label
resh@gsnDraw = False
resh@gsnFrame = False
ploth = gsn_histogram(wks,IceV_final,resh) 
  resh@vpWidthF           = 0.04             ; label bar location 
  resh@vpHeightF          = 0.6              ; label bar location
  resh@lbPerimOn          = False            ; turn off box around label bar
  resh@lbFillColors       = cmap(2:,:)       ; label bar colors
  resh@lbMonoFillPattern  = True             ; fill label bar solid
  resh@lbLabelFontHeightF = 0.013            ; label font height
  resh@lbTitleString      = "Gt Carbon Emitted"         ; title
  resh@lbTitleFontHeightF = 0.012                       ; title font height
  resh@lbBoxLinesOn = False                   ; no boxes on each color
  gsn_labelbar_ndc (wks,dimsizes(lbClev),""+lbClev,0.82,0.8,resh)
draw(ploth)
frame(wks)


resh2 = True
resh2@gsnHistogramHorizontal  = True            ; draw horizontal histogram
resh2@gsnHistogramNumberOfBins = 40
resh2@tiYAxisString = "% of Initial Ice Sheet at the Final Timestep"    ; plot Y axis label
resh2@gsnDraw = False
resh2@gsnFrame = False
ploth2 = gsn_histogram(wks,IceV_final,resh2)               ; create histogram with 10 bins 
  resh2                    = True             ; turn on label bar res
  resh2@vpWidthF           = 0.04             ; label bar location 
  resh2@vpHeightF          = 0.6              ; label bar location
  resh2@lbPerimOn          = False            ; turn off box around label bar
  resh2@lbFillColors       = cmap(2:,:)       ; label bar colors
  resh2@lbMonoFillPattern  = True             ; fill label bar solid
  resh2@lbLabelFontHeightF = 0.013            ; label font height
  resh2@lbTitleString      = "Gt Carbon Emitted"         ; title
  resh2@lbTitleFontHeightF = 0.012                       ; title font height
  resh2@lbBoxLinesOn = False                   ; no boxes on each color
  gsn_labelbar_ndc (wks,dimsizes(lbClev),""+lbClev,0.82,0.8,resh2)
draw(ploth2)
frame(wks)

