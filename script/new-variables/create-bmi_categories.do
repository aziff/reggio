// Create BMI variable

gen BMI_obese = 0

* replace BMI for obese adults
replace BMI_obese = 1 if BMI>30 & Age>=20

* replace BMI for obese male children
replace BMI_obese = 1 if childBMI >= 19.2789 & Male == 1 & Age >=2 & Age< 3
replace BMI_obese = 1 if childBMI >= 18.23842 & Male == 1 & Age >=3 & Age< 4
replace BMI_obese = 1 if childBMI >= 17.83614 & Male == 1 & Age >=4 & Age< 5
replace BMI_obese = 1 if childBMI >= 17.93893 & Male == 1 & Age >=5 & Age< 6
replace BMI_obese = 1 if childBMI >= 18.41421 & Male == 1 & Age >=6 & Age< 7
replace BMI_obese = 1 if childBMI >= 19.15236 & Male == 1 & Age >=7 & Age< 8
replace BMI_obese = 1 if childBMI >= 20.06793 & Male == 1 & Age >=8 & Age< 9
replace BMI_obese = 1 if childBMI >= 21.08893 & Male == 1 & Age >=9 & Age< 10
replace BMI_obese = 1 if childBMI >= 22.15409 & Male == 1 & Age >=10 & Age< 11
replace BMI_obese = 1 if childBMI >= 23.21358 & Male == 1 & Age >=11 & Age< 12
replace BMI_obese = 1 if childBMI >= 24.22985 & Male == 1 & Age >=12 & Age< 13
replace BMI_obese = 1 if childBMI >= 25.17811 & Male == 1 & Age >=13 & Age< 14
replace BMI_obese = 1 if childBMI >= 26.04662 & Male == 1 & Age >=14 & Age< 15
replace BMI_obese = 1 if childBMI >= 26.83688 & Male == 1 & Age >=15 & Age< 16
replace BMI_obese = 1 if childBMI >= 27.56393 & Male == 1 & Age >=16 & Age< 17
replace BMI_obese = 1 if childBMI >= 28.25676 & Male == 1 & Age >=17 & Age< 18
replace BMI_obese = 1 if childBMI >= 28.95862 & Male == 1 & Age >=18 & Age< 19
replace BMI_obese = 1 if childBMI >= 29.72674 & Male == 1 & Age >=19 & Age< 20

* replace BMI for obese female children
replace BMI_obese = 1 if childBMI >= 19.05824 & Male == 0 & Age >=2 & Age< 3
replace BMI_obese = 1 if childBMI >= 18.25475 & Male == 0 & Age >=3 & Age< 4
replace BMI_obese = 1 if childBMI >= 18.02851 & Male == 0 & Age >=4 & Age< 5
replace BMI_obese = 1 if childBMI >= 18.25738 & Male == 0 & Age >=5 & Age< 6
replace BMI_obese = 1 if childBMI >= 18.83778 & Male == 0 & Age >=6 & Age< 7
replace BMI_obese = 1 if childBMI >= 19.67794 & Male == 0 & Age >=7 & Age< 8
replace BMI_obese = 1 if childBMI >= 20.69525 & Male == 0 & Age >=8 & Age< 9
replace BMI_obese = 1 if childBMI >= 21.81725 & Male == 0 & Age >=9 & Age< 10
replace BMI_obese = 1 if childBMI >= 22.98258 & Male == 0 & Age >=10 & Age< 11
replace BMI_obese = 1 if childBMI >= 24.14141 & Male == 0 & Age >=11 & Age< 12
replace BMI_obese = 1 if childBMI >= 25.25564 & Male == 0 & Age >=12 & Age< 13
replace BMI_obese = 1 if childBMI >= 26.2988 & Male == 0 & Age >=13 & Age< 14
replace BMI_obese = 1 if childBMI >= 27.25597 & Male == 0 & Age >=14 & Age< 15
replace BMI_obese = 1 if childBMI >= 28.12369 & Male == 0 & Age >=15 & Age< 16
replace BMI_obese = 1 if childBMI >= 28.90981 & Male == 0 & Age >=16 & Age< 17
replace BMI_obese = 1 if childBMI >= 29.6335 & Male == 0 & Age >=17 & Age< 18
replace BMI_obese = 1 if childBMI >= 30.32554 & Male == 0 & Age >=18 & Age< 19
replace BMI_obese = 1 if childBMI >= 31.0288 & Male == 0 & Age >=19 & Age< 20


gen BMI_overweight = 0

* replace BMI for overweight  adults
replace BMI_overweight = 1 if BMI >=25 & BMI<=29.9 & Age>=20

* replace BMI for overweight male children
replace BMI_overweight = 1 if childBMI >= 18.11955 & childBMI < 19.2789 & Male == 1 & Age >=2 & Age< 3
replace BMI_overweight = 1 if childBMI >= 17.32627 & childBMI < 18.23842 & Male == 1 & Age >=3 & Age< 4
replace BMI_overweight = 1 if childBMI >= 16.92501 & childBMI < 17.83614 & Male == 1 & Age >=4 & Age< 5
replace BMI_overweight = 1 if childBMI >= 16.84076 & childBMI < 17.93893 & Male == 1 & Age >=5 & Age< 6
replace BMI_overweight = 1 if childBMI >= 17.01418 & childBMI < 18.41421 & Male == 1 & Age >=6 & Age< 7
replace BMI_overweight = 1 if childBMI >= 17.40122 & childBMI < 19.15236 & Male == 1 & Age >=7 & Age< 8
replace BMI_overweight = 1 if childBMI >= 17.95575 & childBMI < 20.06793 & Male == 1 & Age >=8 & Age< 9
replace BMI_overweight = 1 if childBMI >= 18.63222 & childBMI < 21.08893 & Male == 1 & Age >=9 & Age< 10
replace BMI_overweight = 1 if childBMI >= 19.39041 & childBMI < 22.15409 & Male == 1 & Age >=10 & Age< 11
replace BMI_overweight = 1 if childBMI >= 20.19667 & childBMI < 23.21358 & Male == 1 & Age >=11 & Age< 12
replace BMI_overweight = 1 if childBMI >= 21.02386 & childBMI < 24.22985 & Male == 1 & Age >=12 & Age< 13
replace BMI_overweight = 1 if childBMI >= 21.85104 & childBMI < 25.17811 & Male == 1 & Age >=13 & Age< 14
replace BMI_overweight = 1 if childBMI >= 22.66325 & childBMI < 26.04662 & Male == 1 & Age >=14 & Age< 15
replace BMI_overweight = 1 if childBMI >= 23.45117 & childBMI < 26.83688 & Male == 1 & Age >=15 & Age< 16
replace BMI_overweight = 1 if childBMI >= 24.21087 & childBMI < 27.56393 & Male == 1 & Age >=16 & Age< 17
replace BMI_overweight = 1 if childBMI >= 24.94362 & childBMI < 28.25676 & Male == 1 & Age >=17 & Age< 18
replace BMI_overweight = 1 if childBMI >= 25.65601 & childBMI < 28.95862 & Male == 1 & Age >=18 & Age< 19
replace BMI_overweight = 1 if childBMI >= 26.36054 & childBMI < 29.72674 & Male == 1 & Age >=19 & Age< 20

* replace BMI for overweight female children
replace BMI_overweight = 1 if childBMI >= 17.97371 & childBMI < 19.05824 & Male == 0 & Age >=2 & Age< 3
replace BMI_overweight = 1 if childBMI >= 17.16634 & childBMI < 18.25475 & Male == 0 & Age >=3 & Age< 4
replace BMI_overweight = 1 if childBMI >= 16.80058 & childBMI < 18.02851 & Male == 0 & Age >=4 & Age< 5
replace BMI_overweight = 1 if childBMI >= 16.80197 & childBMI < 18.25738 & Male == 0 & Age >=5 & Age< 6
replace BMI_overweight = 1 if childBMI >= 17.09974 & childBMI < 18.83778 & Male == 0 & Age >=6 & Age< 7
replace BMI_overweight = 1 if childBMI >= 17.62557 & childBMI < 19.67794 & Male == 0 & Age >=7 & Age< 8
replace BMI_overweight = 1 if childBMI >= 18.31718 & childBMI < 20.69525 & Male == 0 & Age >=8 & Age< 9
replace BMI_overweight = 1 if childBMI >= 19.11937 & childBMI < 21.81725 & Male == 0 & Age >=9 & Age< 10
replace BMI_overweight = 1 if childBMI >= 19.984 & childBMI < 22.98258 & Male == 0 & Age >=10 & Age< 11
replace BMI_overweight = 1 if childBMI >= 20.86984 & childBMI < 24.14141 & Male == 0 & Age >=11 & Age< 12
replace BMI_overweight = 1 if childBMI >= 21.74263 & childBMI < 25.25564 & Male == 0 & Age >=12 & Age< 13
replace BMI_overweight = 1 if childBMI >= 22.57506 & childBMI < 26.2988 & Male == 0 & Age >=13 & Age< 14
replace BMI_overweight = 1 if childBMI >= 23.34689 & childBMI < 27.25597 & Male == 0 & Age >=14 & Age< 15
replace BMI_overweight = 1 if childBMI >= 24.04503 & childBMI < 28.12369 & Male == 0 & Age >=15 & Age< 16
replace BMI_overweight = 1 if childBMI >= 24.66372 & childBMI < 28.90981 & Male == 0 & Age >=16 & Age< 17
replace BMI_overweight = 1 if childBMI >= 25.20482 & childBMI < 29.6335 & Male == 0 & Age >=17 & Age< 18
replace BMI_overweight = 1 if childBMI >= 25.67786 & childBMI < 30.32554 & Male == 0 & Age >=18 & Age< 19
replace BMI_overweight = 1 if childBMI >= 26.09993 & childBMI < 31.0288 & Male == 0 & Age >=19 & Age< 20
