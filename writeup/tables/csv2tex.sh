# partially convert the comma-separated output of tabform into the body of a tex table

sed -i $'s/,/ \& /g' *.csv 	# change commas into " & "
sed -i 's/$/ \\\\/' *.csv # add double backslash at end of line
sed -i 's/"//g' *.csv # replace all " with nothing
sed  -i '1d' *.csv # delete the first line
sed  -i '$d' *.csv # delete the last line
sed -i $'s/\%/\\\%/g' *.csv # replace % with \%
sed -i 's/dv: //' *.csv
sed -i -e '$a\\\hline' *.csv # add \hline at the end of the file
for x in *.csv; do mv "$x" "${x%.csv}.tex"; done # convert the extention from .csv to .tex

