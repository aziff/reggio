# This file takes the output from stata and makes it into a tex-like format

  #------------------------------------ Children --------------------------------#
echo "------------------------------------ Children --------------------------------"
> childAsilo.tex  #empty the file if it is already there
> childMaterna.tex  #empty the file if it is already there

for outcome in childFriends_bin childinvMusic childinvReadTo_bin childinvTheater childinvDance childSDQ_score_bin worryMyself worryTeacher childBMI_bin childHealth_bin childNone_diag childSnackNo childSnackFruit difficultiesInterest difficultiesSit likeSchool_child_bin faceFamily_bin faceGeneral_bin candyGame_bin 
do
  #-----------Asilo------------#
  eval "fileAsilo=${outcome}_asilo_child.txt"   #create a new variable called $fileAsilo
  echo "Looping over $outcome"
  sed -n -e "4,5 p" -e "5 q" ${fileAsilo} >> childAsilo.tex   #cut lines 4 to 5 and append to childAsilo.tex
  sed -i "s/ReggioAsilo/$outcome/" childAsilo.tex        #replace ReggioAsilo with the name of the variable

  #-----------Materna------------#
  eval "fileMaterna=${outcome}_materna_child.txt" 
  #echo "Looping over $outcome --Materna"
  sed -n -e "4,5 p" -e "5 q" ${fileMaterna} >> childMaterna.tex   #cut lines 4 to 5 and append to childMaterna.tex
  sed -i "s/ReggioMaterna/$outcome/" childMaterna.tex        #replace ReggioMaterna with the name of the variable
done

  #------------------------------------Adolescents --------------------------------#
echo "------------------------------------ Adolescents --------------------------------"
> adoAsilo.tex  #empty the file if it is already there
> adoMaterna.tex  #empty the file if it is already there

for outcome in Friends_bin childinvTalkOut_bin childinvTalkSchool_bin closeDad_bin closeMom_bin childSDQ_score_bin BMI_cat_bin childHealth_bin childNone_diag childSnackNo childSnackFruit SmokeEver Drink difficultiesInterest difficultiesSit dropoutSchool likeSchool_ado_bin Satisfied Depression_bin Trust_bin

do
  #-----------Asilo------------#
  eval "fileAsilo=${outcome}_asilo_ado.txt"   #create a new variable called $fileAsilo
  echo "Looping over $outcome"
  sed -n -e "4,5 p" -e "5 q" ${fileAsilo} >> adoAsilo.tex   #cut lines 4 to 5 and append to adoAsilo.tex
  sed -i "s/ReggioAsilo/$outcome/" adoAsilo.tex        #replace ReggioAsilo with the name of the variable

  #-----------Materna------------#
  eval "fileMaterna=${outcome}_materna_ado.txt" 
  #echo "Looping over $outcome --Materna"
  sed -n -e "4,5 p" -e "5 q" ${fileMaterna} >> adoMaterna.tex   #cut lines 4 to 5 and append to adoMaterna.tex
  sed -i "s/ReggioMaterna/$outcome/" adoMaterna.tex        #replace ReggioMaterna with the name of the variable
done

  #------------------------------------ Variable labels --------------------------------#
sed -i 's/childFriends_bin/Many friends/g'   childAsilo.tex childMaterna.tex
sed -i 's/childinvMusic/Musical instr. at home/g'   childAsilo.tex childMaterna.tex
sed -i 's/childinvReadTo_bin/Often read to child/g'   childAsilo.tex childMaterna.tex
sed -i 's/childinvTheater/Art or drama class/g'   childAsilo.tex childMaterna.tex
sed -i 's/childinvDance/Music or dance class/g'   childAsilo.tex childMaterna.tex
sed -i 's/childSDQ_score_bin/Low SDQ score/g'   childAsilo.tex childMaterna.tex
sed -i 's/worryMyself/Tell worries to nobody/g'   childAsilo.tex childMaterna.tex
sed -i 's/worryTeacher/Tell worries to teacher/g'   childAsilo.tex childMaterna.tex
sed -i 's/childBMI_bin/Normal BMI/g'   childAsilo.tex childMaterna.tex
sed -i 's/childHealth_bin/Good health/g'   childAsilo.tex childMaterna.tex
sed -i 's/childNone_diag/No illness/g'   childAsilo.tex childMaterna.tex
sed -i 's/childSnackNo/Never snacks/g'   childAsilo.tex childMaterna.tex
sed -i 's/childSnackFruit/Fruit as snack/g'   childAsilo.tex childMaterna.tex
sed -i 's/difficultiesInterest/Excited to learn/g'   childAsilo.tex childMaterna.tex
sed -i 's/difficultiesSit/Can sit still/g'   childAsilo.tex childMaterna.tex
sed -i 's/likeSchool_child_bin/Likes school/g'   childAsilo.tex childMaterna.tex
sed -i 's/faceFamily_bin/Happy in family/g'   childAsilo.tex childMaterna.tex
sed -i 's/faceGeneral_bin/Happy in general/g'   childAsilo.tex childMaterna.tex
sed -i 's/candyGame_bin/Share candies/g'   childAsilo.tex childMaterna.tex


sed -i 's/Friends_bin/Many friends/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/childinvTalkOut_bin/Talks about activities/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/childinvTalkSchool_bin/Talks about school/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/closeDad_bin/Close to dad/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/closeMom_bin/Close to mom/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/childSDQ_score_bin/Low SDQ score/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/BMI_cat_bin/Normal BMI/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/childHealth_bin/Good health/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/childNone_diag/No illness/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/childSnackNo/Never snacks/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/childSnackFruit/Fruit as snack/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/SmokeEver/Never smoked/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/Drink/Does not drink/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/difficultiesInterest/Excited to learn/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/difficultiesSit/Can sit still/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/dropoutSchool/Attending school/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/likeSchool_ado_bin/Likes school/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/Satisfied/Satisfied/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/Depression_bin/Low depression score/g'   adoAsilo.tex adoMaterna.tex
sed -i 's/Trust_bin/High trust/g'   adoAsilo.tex adoMaterna.tex

  #------------------------------------ Latex --------------------------------#
sed -i 's/_/\\_/g'   adoAsilo.tex adoMaterna.tex  childAsilo.tex childMaterna.tex # replace _ with \_
sed -i 's/\t/ \& /g' adoAsilo.tex adoMaterna.tex  childAsilo.tex childMaterna.tex # change tabs into " & "
sed -i 's/$/ \\\\/'  adoAsilo.tex adoMaterna.tex  childAsilo.tex childMaterna.tex # add double backslash at end of line

