# tsi_for_lauren
Greenland Ice Sheet Carbon Threshold Project

ReadMe File describing the Greenland ice sheet carbon threshold project plots
Lauren Vargo (lvargo13@gmail.com)

Bash script that loops through 200 directories, and within each directory concatenates all files
Concat_all.sh

Time series plots:
  ** All time series plots are colored based on cumulative carbon emissions
  *** All 5 plots put into 1 panel- Fig 1?
  -TSI_CEmissions.ncl (plots C emissions)
  -TSI_atm_CO2.ncl (plots atmospheric CO2)  
  -TSI_Temp.ncl (plots dT)
  -TSI_SMB.ncl (plots SMB)
  -TSI_IceVolumeN.ncl (plots NH ice volume)

Histogram plot:
  -IceV_histo_manual.ncl - plots a histogram of final timestep ice volume,

Plot of ice volume vs. GtC (similar idea to Fig 2 from Winkelmann et al., 2015)
  -IceLoss_vs_CEmissions.ncl

Wind Speed plot:
  ** Plots wind vectors for 1)full topography of GrIS 2)no topography of GrIS and 3)difference
  -WindSpeedPlot.ncl

Also wrote script to plot a scatter plot of ice volume vs. (max C or rate of C)
  -MaxCarbon_scat.ncl
  ** Could not get the scatter plot to colorcode dots to correspond to cumulate C emissions
