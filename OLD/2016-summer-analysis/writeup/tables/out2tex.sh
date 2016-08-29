# partially convert the tab-separated output of tabform into the body of a tex table

sed -i $'s/\t/ \& /g' *.out 	# change tabs into " & "
sed -i 's/$/ \\\\/' *.out # add double backslash at end of line
sed -i 's/"//g' *.out # replace all " with nothing
sed  -i '1d' *.out # delete the first line
sed  -i '$d' *.out # delete last two lines
sed  -i '$d' *.out
sed -i $'s/\%/\\\%/g' *.out # replace % with \%
sed -i 's/dv: //' *.out
sed -i -e '$a\\\hline' *.out # add \hline at the end of the file
for x in *.out; do mv "$x" "${x%.out}.tex"; done # convert the extention from .out to .tex

