; NCL script to plot tsi of CO2 emissions (F_co2emit) 
; originally created 9/30/15, updated 9/30/15

wks = gsn_open_wks ("x11","C_Emit_tsi")
res = True
path = "/Users/lvargo/cosim1/lvargo/GIS_tsi/tsi_for_lauren/"

	i = 1
	f = addfile(path+sprinti("%0.3i",i)+"/Concat_"+sprinti("%0.3i",i)+".nc","r")
	IceVol = f->L_icevolN
	Year = f->T_year
	C = f->F_co2emit
	res@gsnDraw = False
	res@gsnFrame = False
	res@gsnMaximize = True
	res@trYMaxF = 800000
	res@trXMinF = 1750
	res@trXMaxF = 2500
	plot = gsn_csm_xy (wks,Year,C,res)	

do i = 1,199
	g = addfile(path+sprinti("%0.3i",i+1)+"/Concat_"+sprinti("%0.3i",i+1)+".nc","r")
       	IceVol1 = g->L_icevolN
       	Year1 = g->T_year
	C1 = g->F_co2emit
        plot1 = gsn_csm_xy (wks,Year1,C1,res)
	overlay(plot,plot1)
	draw(plot)
	frame(wks)
	delete(IceVol1)
	delete(Year1)
	delete(C1)
end do 





