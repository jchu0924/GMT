@echo off
REM ========== 設定變數 ===============
set ps=interseismic_displacement_NEU.ps
set range=121:23/121:52/23:45/24:23
set oriDEM1="E:\GIS_DATA\TW20mWGS84.tif"
set oriDEM2="E:\GIS_DATA\Taidp200m.nc"
rem set oriDEM2="E:\01Data\GIS\DEM\topo.nc"
set coastline=twcoasts_84.txt
set twfault=ActiveFaults_CGS2010_WGS84.txt
set temp1=interseismic_cgps_NEU.txt
set temp2=interseismic_sgps_NEU.txt
set CGPS_raw_hours=tempsel1.txt
set SGPS_raw_hours=tempsel2.txt

gmt gmtset  PROJ_LENGTH_UNIT=i

REM ==========裁切數值高程與製作地形陰影檔 ===========
gmt grdcut %oriDEM1% -R%range% -GDEM1
gmt grdcut %oriDEM2% -R%range% -GDEM2
gmt grdgradient DEM1 -A315 -Gint1 -Ne0.8 -fg
gmt grdgradient DEM2 -A315 -Gint2 -Ne0.8 -fg
gmt select %temp1% -R%range% > %CGPS_raw_hours% 
gmt select %temp2% -R%range% > %SGPS_raw_hours%


REM =========製作灰階CPT==============================
echo -7000 180 0 180> temp.cpt
echo 0 155 4000 155 >> temp.cpt

REM ======= 軸一 ==================
REM =======畫底圖:框->海地形->海岸線內地形->海岸線->斷層==========
gmt psbasemap -JM10c -R%range% -B0.25 -BSWen+t"Horizontal Rate" -K  > %ps%
gmt grdimage -J -R DEM2 -Iint2 -Ctemp.cpt -O -K >> %ps%
gmt psclip %coastline% -J -R -O -K >> %ps%
gmt grdimage -J -R DEM1 -Iint1 -Ctemp.cpt -O -K >> %ps% 
gmt psclip %coastline% -J -R -O -K  -C >> %ps%
gmt psxy %coastline% -JM10c -R%range% -W1 -O -K >> %ps%
gmt psxy %twfault% -R -J -W1,red  -K -O   >> %ps%

REM ===============水平速度場===========================
set veloRate1=0.020
::set veloRate2=0.0035
::gawk "sqrt($3*$3+$4*$4)<80 {print $1,$2,$4,$3,0,0,0,$6}" %GPS_raw_hours% > GPS_EN_hours1.gmt
::gawk "sqrt($3*$3+$4*$4)>=80 {print $1,$2,$4,$3,0,0,0,$6}" %GPS_raw_hours% > GPS_EN_hours2.gmt
::gmt psxy %GPS_raw_hours% -J -R -St0.1 -G0 -O -K >> %ps%
::gmt psvelo GPS_EN_hours1.gmt -J -R -Se%veloRate1%/0.67/8 -A0.025/0.12/0.04 -W1 -Gblue -K -O  >> %ps%
::gmt psvelo GPS_EN_hours2.gmt -J -R -Se%veloRate2%/0.67/8 -A0.025/0.12/0.04 -W1 -Gred -K -O  >> %ps%
gawk "{print $1, $2, $3, $4, $6, $7}" %CGPS_raw_hours% > CGPS_EN_hours.gmt
gawk "{print $1, $2, $3, $4, $6, $7}" %SGPS_raw_hours% > SGPS_EN_hours.gmt
gmt psxy %CGPS_raw_hours% -J -R -St0.1 -G0 -O -K >> %ps%
gmt psxy %SGPS_raw_hours% -J -R -St0.1 -W1p,0/0/0 -O -K >> %ps%
gmt psvelo CGPS_EN_hours.gmt -J -R -Se%veloRate1%/0.67/8 -A0.025/0.12/0.04 -W1 -Gblue -K -O  >> %ps%
gmt psvelo SGPS_EN_hours.gmt -J -R -Se%veloRate1%/0.67/8 -A0.025/0.12/0.04 -W1 -Gred -K -O  >> %ps%


REM =======圖例===============

echo 121.795 23.6960 40 mm/yr | gmt pstext -J -R -N -O -K -F+f12+jMC >> %ps%
echo 121.75 23.6775 40 0 0 0 0 | gmt psvelo -J -R -Se%veloRate1%/0.67/0 -A0.025/0.12/0.04 -Gblue -N -W1 -K -O >> %ps% 
echo 121.75 23.6475 40 0 0 0 0 | gmt psvelo -J -R -Se%veloRate1%/0.67/0 -A0.025/0.12/0.04 -Gred -W1 -N -K -O >> %ps% 
echo 121.75 23.6775  | gmt psxy -J -R -St0.1 -G0 -N -O -K >> %ps%
echo 121.75 23.6475  | gmt psxy -J -R -St0.1 -W1p,0/0/0 -N -O -K >> %ps%

echo 121.67 23.68 CGPS station | gmt pstext -J -R -N -O -K -F+f12+jMC >> %ps%
echo 121.67 23.65 SGPS station | gmt pstext -J -R -N -O -K -F+f12+jMC >> %ps%

echo 121.78 24.165 Hsincheng Ridge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.70 24.070 Hualien Ridge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.56 23.830 Coastal Radge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.80 23.780 Hoping Basin | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.46 24.120 Central Radge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.48 23.800 Huadong Valley | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%


::echo 121.65 23.78 \074 80mm | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%

::echo 121.65 23.82 \076\075 80 mm | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
::echo 121.73 23.83 200 mm | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%

REM ====震源機制解====
::echo 121:41.95	24:12.33	2.99	209.01	36.52	26.9	5.35	121:47   	24:16 > eq_mach.txt	
::echo 121:42.02	24:11.08	3.38	248.35	10.6	112.45	5.62	121:48   	24:13	>> eq_mach.txt
::echo 121:42.35	24:10.37	10.23	209.01	36.52	26.9	5.28	121:47	    24:10.5 >> eq_mach.txt	
::echo 121:44.62	24:9.04	    10.61	327	    13	    167	    5.89	121:49      24:07 	0204_M@-L@-5.89 >> eq_mach.txt
::echo 121:43.74	24:6.94	    6.69	223.34	48.01	26.9	5.38	121:49	    24:04.5	>> eq_mach.txt
::echo 121:46.62	24:4.91	    7.75	244.42	14.61	105.01	5.85	121:49	    24:2	>> eq_mach.txt
::echo 121:44.78	24:5.89	    1.59	235	    22.3	98.66	5.02	121:49   	23:59	 >> eq_mach.txt
::echo 121:44.11	24:6.37	    8.32	204.83	10.49	57.67	5.04	121:49	    23:56	>> eq_mach.txt
::echo 121:43.78	24:6.04	    6.31	215.68	56.36	25.57	6.26	121:49      23:52	0206_M@-L@-6.26 >> eq_mach.txt
::echo 121:42.55	24:2.41	    4.17	243.49	14.38	127.14	5.39	121:41	24:0	>> eq_mach.txt
::echo 121:43.63	24:0.63	    5.65	252.37	14.5	112.9	5.46	121:42	23:56	>> eq_mach.txt
::gmt psmeca eq_mach.txt -J -R -Sa.3 -Zeq_depth.cpt -W0.1  -C0.2,0/0/0 -O -K  >> %ps%
::gmt psxy eq_mach.txt -J -R -Sa0.1 -Gblack -W0.1 -O -K >> %ps%


REM ======= 軸二 ==================
REM =======畫底圖:框->海地形->海岸線內地形->海岸線->斷層==========
gmt psbasemap -JM10c -R%range% -B0.25 -BSEwn+t"Vertical Rate" -K -O -X11c >> %ps%
gmt grdimage -J -R DEM2 -Iint2 -Ctemp.cpt -O -K >> %ps%
gmt psclip %coastline% -J -R -O -K >> %ps%
gmt grdimage -J -R DEM1 -Iint1 -Ctemp.cpt -O -K >> %ps% 
gmt psclip %coastline% -J -R -O -K  -C >> %ps%
gmt psxy %coastline% -JM10c -R%range% -W1 -O -K >> %ps%
gmt psxy %twfault% -R -J -W1,red  -K -O   >> %ps%

REM ===============垂直速度場===========================
set veloRate1=0.040
::set veloRate2=0.01
::gawk "{print $1,$2,0,$5,0,0,0,$6}" %GPS_raw_hours% > GPS_U_hours.gmt
::gawk "sqrt($5*$5)<100 {print $1,$2,0,$5,0,0,0,$6}" %GPS_raw_hours% > GPS_U_hours1.gmt
::gawk "sqrt($5*$5)>=100 {print $1,$2,0,$5,0,0,0,$6}" %GPS_raw_hours% > GPS_U_hours2.gmt
::gmt psxy %GPS_raw_hours% -J -R -St0.1 -G0 -O -K >> %ps%
::gawk "$4>0{print $0}" GPS_U_hours.gmt | gmt psvelo -J -R -Se%veloRate1%/0.67/8 -A0.025/0.12/0.04 -W1 -Gred -K -O   >> %ps%
::gawk "$4<=0{print $0}" GPS_U_hours.gmt | gmt psvelo -J -R -Se%veloRate1%/0.67/8 -A0.025/0.12/0.04 -W1 -Gblue -K -O   >> %ps%
gawk "{print $1, $2, 0, $5, 0, $8}" %CGPS_raw_hours% > CGPS_U_hours.gmt
gawk "{print $1, $2, 0, $5, 0, $8}" %SGPS_raw_hours% > SGPS_U_hours.gmt
gmt psxy %CGPS_raw_hours% -J -R -St0.1 -G0 -O -K >> %ps%
gmt psxy %SGPS_raw_hours% -J -R -St0.1 -W1p,0/0/0 -O -K >> %ps%
gmt psvelo CGPS_U_hours.gmt -J -R -Se%veloRate1%/0.67/8 -A0.025/0.12/0.04 -W1 -Gblue -N -K -O  >> %ps%
gmt psvelo SGPS_U_hours.gmt -J -R -Se%veloRate1%/0.67/8 -A0.025/0.12/0.04 -W1 -Gred -N -K -O  >> %ps%

REM =======圖例===============
echo 121.680 23.665 20 mm/yr | gmt pstext -J -R -N -O -K -F+f12+jMC >> %ps%
echo 121.650 23.645 20 0 0 0 0 | gmt psvelo -J -R -Se%veloRate1%/0.67/0 -A0.025/0.12/0.04 -Gblack -W1 -N -K -O >> %ps% 
echo 121.78 24.165 Hsincheng Ridge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.70 24.070 Hualien Ridge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.56 23.830 Coastal Radge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.80 23.780 Hoping Basin | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.46 24.120 Central Radge | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%
echo 121.48 23.800 Huadong Valley | gmt pstext -J -R -O -K -F+f12+jMC >> %ps%

::gmt psmeca eq_mach.txt -J -R -Sa.3 -Zeq_depth.cpt -W0.1  -C0.2,0/0/0 -O -K  >> %ps%
::gmt psxy eq_mach.txt -J -R -Sa0.1 -Gblack -W0.1 -O -K >> %ps%
gmt psscale -J -R -Ceq_depth.cpt -Bswen -By+l"Depth(km)" -Dx2/-0.5+w1/0.05+h -N -O -K >> %ps%


del gmt.*  temp.cpt
rem del DEM
pause