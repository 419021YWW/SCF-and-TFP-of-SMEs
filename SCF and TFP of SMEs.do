foreach i in tfp_op Age Size Lev Profit Fhold Separation ROE Stated_owned Cash LnGDP  {
    drop if `i'==.
}
winsor2 Age Size Lev Profit Fhold Separation ROE Cash LnGDP,  cuts(1 99)
***Descriptive statistics****
sum2docx tfp_op LnSCF Age_w Size_w Lev_w Profit_w Fhold_w Separation_w ROE_w Stated_owned Cash_w LnGDP_w using  Descriptive_statistics.docx,replace stats(N mean(%9.3f) sd min(%9.3f) median(%9.3f) max(%9.3f))  title("Table 1.Descriptive statistics")
qui sum Profit_w
replace Profit_w=(Profit_w-r(min))/(r(max)-r(min))
qui sum Cash_w
replace Cash_w=(Cash_w-r(min))/(r(max)-r(min))
*********correlation
*pwcorr_a lntfp tfp_ols tfp_fix tfp_op supply_chain_finance lngdp ROA type two_power cash_holding JGTZZCGBL asset return TTM
logout, save(correlation) word replace: pwcorr_a tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w
***********************
******Baseline******
reghdfe tfp_op LnSCF, absorb( code year) vce(cluster code)
est store a1
reghdfe tfp_op LnSCF Age_w, absorb( code year) vce(cluster code)
est store a2
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w, absorb( code year) vce(cluster code)
est store a3 
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w, absorb( code year) vce(cluster code)
est store a4
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned, absorb( code year) vce(cluster code)
est store a5
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb( code year) vce(cluster code)
est store a6
esttab a1 a2 a3 a4 a5 a6 using Baseline.rtf,replace b(%12.3f) se(%12.3f)  nogap compress s(N r2) star(* 0.1 ** 0.05 *** 0.01)

***Robustness checks***
reghdfe tfp_op SCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb( code year) vce(cluster code)
est store a1
reghdfe tfp_ols LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb( code year) vce(cluster code)
est store a2
reghdfe tfp_fe LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb( code year) vce(cluster code)
est store a3
reghdfe tfp_lp LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb( code year) vce(cluster code)
est store a4
reghdfe tfp_opacf LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb( code year) vce(cluster code)
est store a5
esttab a1 a2 a3 a4 a5 using Robustness_checks.rtf,replace b(%12.3f) se(%12.3f)  nogap compress s(N r2) star(* 0.1 ** 0.05 *** 0.01)
*****Endophytism*****
gl Y tfp_op
gl X Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w  i.code i.year
gl D LnSCF
set seed 10086
ddml init partial, kfolds(5)
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, robust
*************instrumental variable******************
xtset code year
reghdfe tfp_op L.LnSCF L.Age_w L.Size_w L.Lev_w L.Profit_w L.ROE_w L.Cash_w L.Fhold_w L.Separation_w L.Stated_owned  L.LnGDP_w, absorb( code year) vce(cluster code)
bysort industry: egen SCF_mean = mean(LnSCF)
ivreghdfe tfp_op Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w (LnSCF=SCF_mean) , absorb(year code) first
***************************************************
***Mediation mechanism analysis***
qui sum turnover1
replace turnover1=(turnover1-r(min))/(r(max)-r(min))
reghdfe turnover1 LnSCF, absorb(year code) vce(cluster code)
est store a1
reghdfe turnover1 LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb(year code) vce(cluster code)
est store a2
reghdfe tfp_op LnSCF turnover1, absorb(year code) vce(cluster code)
est store a3
reghdfe tfp_op LnSCF turnover1 Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb(year code) vce(cluster code)
est store a4
esttab a1 a2 a3 a4 using Mediation_mechanism_analysis.rtf,replace b(%12.3f) se(%12.3f)  nogap compress s(N r2) star(* 0.1 ** 0.05 *** 0.01)
***************
center Dig LnSCF 
qui sum Dig
replace Dig=(Dig-r(min))/(r(max)-r(min))
gen cross=c_Dig*c_LnSCF
reghdfe tfp_op LnSCF Dig cross, absorb(year code) vce(cluster code)
est store a1
reghdfe tfp_op LnSCF Dig cross Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w, absorb(year code) vce(cluster code)
est store a2
esttab a1 a2 using Moderating_mechanism_analysis.rtf,replace b(%12.3f) se(%12.3f)  nogap compress s(N r2) star(* 0.1 ** 0.05 *** 0.01)
***************
***Heterogeneity analysis***
gen region = .
replace region = 0 if province == "北京市" | province == "天津市" | province == "河北省" | province == "上海市" | province == "江苏省" | province == "浙江省" | province == "福建省" | province == "山东省" | province == "广东省" | province == "海南省"
replace region =1 if province == "山西省" | province == "安徽省" | province == "江西省" | province == "河南省" | province == "湖北省" | province == "湖南省"
replace region = 2 if province == "内蒙古自治区" | province == "广西壮族自治区" | province == "重庆市" | province == "四川省" | province == "贵州省" | province == "云南省" | province == "西藏自治区" | province == "陕西省" | province == "甘肃省" |  province == "青海省" | province == "宁夏回族自治区" | province == "新疆维吾尔自治区"
replace region =3 if province == "辽宁省" | province == "吉林省" | province == "黑龙江省"
egen Size_median=median(Size)
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w if Size<=Size_median, absorb(year code) vce(cluster code)
est store a1
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w if Size>Size_median, absorb(year code) vce(cluster code)
est store a2
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w if region==0, absorb(year code) vce(cluster code)
est store a3
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w if region==1, absorb(year code) vce(cluster code)
est store a4
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w if region==2, absorb(year code) vce(cluster code)
est store a5
reghdfe tfp_op LnSCF Age_w Size_w Lev_w Profit_w ROE_w Cash_w Fhold_w Separation_w Stated_owned  LnGDP_w if region==3, absorb(year code) vce(cluster code)
est store a6
esttab a1 a2 a3 a4 a5 a6 using Heterogeneity_analysis.rtf,replace b(%12.3f) se(%12.3f)  nogap compress s(N r2) star(* 0.1 ** 0.05 *** 0.01)
*****************

