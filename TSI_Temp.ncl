; NCL script to plot tsi of atm surface air temp (A_sat) 
; originally created 10/19/15, updated 10/19/15

wks = gsn_open_wks ("png","SAT_timeseries")      ; plot type (can be "x11" or "pdf") and file name
color_map = "hotres"
gsn_define_colormap (wks,color_map)     ; colormap being used
cmap = gsn_retrieve_colormap(wks)
res = True
path = "/Users/lvargo/cosim1/lvargo/GIS_tsi/tsi_for_lauren/"    ; path to files
Clev = new(200,float)                   ; array to store values of totC

; loop to calculate GtC 
do i = 1,200    ; neet to start at 1 (not 0) to read in correct files 
        f = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
        C = f->F_co2emit                        ; read in co2 emissions
        Year = f->T_year                        ; read in year
        Cyr = C * 3.154E7                       ; convert seconds to year
        totCo2 = simpne(Year,Cyr)               ; ncl function to calculate area under curve/line
        totC = totCo2 * 1E-12                   ; convert kg to gigatons
        Clev(i-1) = totC                        ; store values of totC in array 
        delete([/C,Cyr,totCo2,totC,Year/])      ; delete values (ncl won't overwrite)
end do

ClevMax = max(Clev)                     ; maximum C emitted value
ClevMax := floattointeger(ClevMax)
ClevMin = min(Clev)                     ; minimum C emitted value
ClevMin := floattointeger(ClevMin)
lbClev = ispan(350,5050,20)     ; span from min to max C emitted values for coloring 
; lbClev = fspan(ClevMin,ClevMax,256)

; plot the first time series
        i = 1
        h = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
        Year = h->T_year                        ; read in year
	C = h->A_sat                            ; read in Temp  
        C := C - C(0)
	res@trXMinF = 1750                      ; plot X axis min
	res@trXMaxF = 8000                      ; plot X axis max 
      	res@trYMaxF = 8                       ; plot Y axis max
        res@trYMinF = 0
	res@tiYAxisString = "Global Mean dT (C)"    ; plot Y axis label
        res@tiXAxisString = "Year"    ; plot X axis label
	res@gsnDraw = False                     ; don't draw plot yet
        res@gsnFrame = False                    ; don't make plot yet
        res@xyLineColors = get_color_index(color_map,lbClev,Clev(i-1))  ; color the lines based on c emissions value
        plot = gsn_csm_xy (wks,Year,C,res)     ; plot  
delete(i)

; loop to plot the additional time series
do i = 2,199
        g = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
        C1 = g->A_sat                       ; read in temp 
	C1 := C1 - C1(0)
	Year1 = g->T_year                       ; read in year
        res@xyLineColors = get_color_index(color_map,lbClev,Clev(i-1))
        plot1 = gsn_csm_xy (wks,Year1,C1,res)
        overlay(plot,plot1)                     ; overlay- needed to plot all time series on same plot
        delete([/Year1,C1/])           ; delete varaibles, needed bc ncl wont rewrite var
end do
delete(i)

; plot the last time series, and draw the final plot
        i = 200
        j = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
        C2 = j->A_sat                       ; read in Carbon 
	C2 := C2 - C2(0)
	Year2 = j->T_year                       ; read in year
        res@xyLineColors = get_color_index(color_map,lbClev,Clev(i-1))
        plot2 = gsn_csm_xy (wks,Year2,C2,res)
        overlay(plot1,plot2)                    ; overlay- needed to plot all time series on same plot
        draw(plot)                              ; finally draw plot

  res_lb                    = True             ; turn on label bar res
  res_lb@vpWidthF           = 0.04             ; label bar location 
  res_lb@vpHeightF          = 0.6              ; label bar location
  res_lb@lbPerimOn          = False            ; turn off box around label bar
  res_lb@lbFillColors       = cmap(:,:)       ; label bar colors
  res_lb@lbMonoFillPattern  = True             ; fill label bar solid
  res_lb@lbLabelFontHeightF = 0.016            ; label font height
  res_lb@lbTitleString      = "Gt Carbon"         ; title
  res_lb@lbTitleFontHeightF = 0.022                       ; title font height
  res_lb@lbBoxLinesOn = False                   ; no boxes on each color
  gsn_labelbar_ndc (wks,dimsizes(lbClev),""+lbClev,0.82,0.8,res_lb)

frame(wks)



