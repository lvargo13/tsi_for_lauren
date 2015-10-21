; Script to plot wind speed vectors over Greenland from UVic climate model output
; Created 10/20/15, update 10/20/15

;------- Read in Data -------------
f = addfile("wind_adv_ann.nc","r")		; read in wind speeds
uq = f->wx_q(80:99,75:99)			; selecting the area including Greenland			
vq = f->wy_q(80:99,75:99)

g = addfile("no_topography.nc","r") 		; read in wind anomalies for no topography
au_noT = g->A_awindX(0,80:99,75:99)
av_noT = g->A_awindY(0,80:99,75:99)
lat2d = g->G_latT(80:99,75:99)
lon2d = g->G_lonT(80:99,75:99)

dimgrd= dimsizes(lat2d)				; get number of lat and lon points
nlat  = dimgrd(0)
mlon  = dimgrd(1)

h = addfile("full_topography.nc","r") 		; read in wind anomalies for full topography
au_fullT = h->A_awindX(0,80:99,75:99)
av_fullT = h->A_awindY(0,80:99,75:99)

;------- Compute wind speeds -----------
u_noT = uq + au_noT
v_noT = vq + av_noT

u_fullT = uq + au_fullT
v_fullT = vq + av_fullT

du = u_noT - u_fullT
dv = v_noT - v_fullT 

;------- Set up plot attributes ------------
wks = gsn_open_wks("pdf","winds")         	; open a workstation

;-- Attributes for full topo and no topo plot
  res                   =  True             	; plot mods desired
  res@mpProjection          = "Mercator"	; This is the projection selected 
  res@mpDataBaseVersion     = "mediumres"	; resolution of GL coast
  res@mpGeophysicalLineColor = "gray50"		; color to draw Greenland
  res@mpMinLatF = lat2d(0,0)			; plot the make over same region selected 
  res@mpMaxLatF = lat2d(nlat-1,mlon-1)		; plot the make over same region selected
  res@mpMinLonF = lon2d(0,0)			; plot the make over same region selected
  res@mpMaxLonF = lon2d(nlat-1,mlon-1)		; plot the make over same region selected
  res@mpLimitMode = "LatLon"			; plot the make over same region selected
  res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              =  False          	; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"      	; draw continental outline last
  res@tfDoNDCOverlay = True
  res@gsnAddCyclic            = False           ; regional data 
  res@vcRefMagnitudeF         = 2             	; define vector ref mag
  res@vcRefLengthF            = 0.05            ; define length of vec ref
  res@vcGlyphStyle            = "CurlyVector"   ; turn on curly vectors
  res@vcMinDistanceF          = 0.02
  res@gsnDraw = False				; don't draw plot yet
  res@gsnFrame = False				; don't draw plot yet

;-- Attributes for difference plot
  resd                   =  True              	; plot mods desired
  resd@mpProjection          = "Mercator"
  resd@mpDataBaseVersion     = "mediumres"
  resd@mpGeophysicalLineColor = "gray50"
  resd@mpMinLatF = lat2d(0,0)
  resd@mpMaxLatF = lat2d(nlat-1,mlon-1)
  resd@mpMinLonF = lon2d(0,0)
  resd@mpMaxLonF = lon2d(nlat-1,mlon-1)
  resd@mpLimitMode = "LatLon"
  resd@pmTickMarkDisplayMode = "Always"
  resd@mpFillOn              =  False        	; turn off map fill
  resd@mpOutlineDrawOrder    = "PostDraw"     	; draw continental outline last
  resd@tfDoNDCOverlay = True
  resd@gsnAddCyclic            = False          ; regional data 
  resd@vcRefMagnitudeF         = 0.25           ; define vector ref mag
  resd@vcRefLengthF            = 0.05           ; define length of vec ref
  resd@vcGlyphStyle            = "CurlyVector"  ; turn on curly vectors
  resd@vcMinDistanceF          = 0.02     
  resd@gsnDraw = False
  resd@gsnFrame = False

;-- Attributes for paneling the 3 plots
 resP = True
 resP@gsnMaximize = True

;--------- Plot --------------------------
     plot1 = new(3,graphic)					; Create panel for plots
     res@tiMainString   = "Full Topography"			; plot1 label
     plot1(0) = gsn_csm_vector_map(wks,u_fullT,v_fullT,res)	
     res@tiMainString   = "No Topography"			; plot2 label
     plot1(1) = gsn_csm_vector_map(wks,u_noT,v_noT,res)
     resd@tiMainString   = "No Topography - Full Topography"	; plot3 label
     plot1(2) = gsn_csm_vector_map(wks,du,dv,resd)
     gsn_panel(wks,plot1,(/1,3/),resP)				; put all plots into panel and draw it


