*** Risk Preferences

clear all
set obs 500
gen x = 160
gen y = 250
foreach i in 264 219 180 170 165 175 206 217 234 228 240 296 190 195 185 223 212 323 309 316 303 336 343 329 270 258 252 283 277 290 {
gen a`i' = `i'
gen p`i' = (a`i' - x) / x
gen yinc`i' = (y * p`i')
}
collapse a165 a170 a175 a180 a185 a190 a195 a206 a212 a217 a219 a223 a228 a234 a240 a252 a258 a264 a270 a277 a283 a290 a296 a303 a309 a316 a323 a329 a336 a343



*** Time Discounting

clear all
set obs 500
gen x = 160
gen y = 250
foreach i in 264 219 180 170 165 175 206 217 234 228 240 296 190 195 185 223 212 323 309 316 303 336 343 329 270 258 252 283 277 290 {
gen a`i' = `i'
gen p`i' = (a`i' - x) / x
gen yinc`i' = (y * (1+ p`i'))
}
collapse yinc343 yinc336 yinc329 yinc323 yinc316 yinc309 yinc303 yinc296 yinc290 yinc283 yinc277 yinc270 yinc264 yinc258 yinc252 yinc240 yinc234 yinc228 yinc223 yinc219 yinc217 yinc212 yinc206 yinc195 yinc190 yinc185 yinc180 yinc175 yinc170 yinc165
