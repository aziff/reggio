/* --------------------------------------------------------------------------- *
* Incorporating new school assignment information by Sylvi and Linor
* Author: Jessica Yu Kyung Koh
* Date:   12/16/2016
* Note: This is the driver file that reassigns individual school information according
        to revisions made by Linor (Part 1) and Sylvi (Part 2).
		
		The first do file includes the revisions on individual school types in Reggio
		made by Linor. The second do file includes the revisions on individual school
		types in Padova made by Sylvi.
* --------------------------------------------------------------------------- */

* Set macro
clear all

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd




do "${git_reggio}/data-construction/dataClean_namesManual_revised/1. dataClean_namesManual_changePart1.do"
do "${git_reggio}/data-construction/dataClean_namesManual_revised/2. dataClean_namesManual_changePart2.do"
