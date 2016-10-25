/* --------------------------------------------------------------------------- *
* Graph of migrants
* Authors: Anna Ziff
* Created: 10/18/16
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio = "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
global git_reggio  = "/mnt/ide0/home/aziff/projects/reggio"

global code = "${git_reggio}/script/linear-probability"

cd $data_reggio
use "${data_reggio}/Reggio_prepared"

include "${code}/../macros" 
