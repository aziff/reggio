* --------------------------------------------------------------------------- *
* Incorporating new school assignment information by Sylvi and Linor
* Author: Jessica Yu Kyung Koh
* Date:   12/16/2016
* --------------------------------------------------------------------------- *

* Set macro
clear all

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd




do "${git_reggio}/data-construction/dataClean_namesManual_revised/1. dataClean_namesManual_LinorChange.do"
do "${git_reggio}/data-construction/dataClean_namesManual_revised/2. dataClean_namesManual_SylviChange.do"
