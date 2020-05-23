capture log close
qui local date : di %tdCY-N-D date("$S_DATE", "DMY") // get current date in YYYY-MM-DD format
log using "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\\`date' Monakhov DHS markov variation.log", replace
set more off
set linesize 100
timer clear
timer on 1


/*	This code generates the results reported in "! sex ratio DRAFT 2015-12-01.docx"
	The code contains redundancies. The objective is just to generate the results, not to do it as fast as possible.
	I'm using Stata/MP 13.0.
	I recommend handling this .do file with Notepad++, integrated with Stata (see http://huebler.blogspot.in/2008/04/stata.html)
	
	Preparations:
	1. Download datasets from DHS website (an approval from DHS is needed). Use "individual response" dataset in .dta format. Unzip.
	2. Keep them in a directory "DHS datasets" . Each dataset will be in a separate folder, for example "BJ_1996_DHS_09192015_652_80934". Within that 
		folder will be only one subfolder (e.g. "bjir31dt"), and within that subfolder will be our Stata file (e.g. "BJIR31FL.DTA") along with some
		auxilliary files. 
		
	Content:
	1. Convert DHS datasets in order to retain only relevant information (based on "2015-10-14 prepare data for merging DHS datasets.do").
		1.1 Define the list of datasets 
		1.2 Make a processed file for each dataset
	2. Combine processed files into one 
	3. Tabulation tests
		3.1 Omnibus tabulation
		3.2	Tabulation test for each sibship type (as characterized by n and k)
	4.	Logistic regression
		4.1.	Process individual datasets to make them suitable for logit
		4.2	Merge processed files for logit
		4.3	Logit in combined sample
		4.4	Logit by n and i
		4.5 Meta-analysis
		4.6	Effect of the interval between last birth and the interview
		4.7 	Correlations between sexes of siblings separated by various numbers of births
	 5.	Modelling with MLE
		5.1	Prepare data for the use with Astolfi's code
		5.2	The MLE
	6.	Effects of birth-to-birth interval on the correlation between sexes
		6.1 Interaction between preceding sib's sex and BTB
		6.2	Logit by BTB, excluding last child
		6.3	Logit by BTB, only last children
		6.4	BTB between same-sex and opposite sex pairs
		6.5	BTB between same-sex and opposite sex pairs, repeat by n and i
	7.	Additional datasets  	
*/




* 1. Convert DHS datasets in order to retain only relevant information (based on "2015-10-14 prepare data for merging DHS datasets.do").
timer on 10

* 1.1 Define the list of datasets 
*based on "list of dataset file paths 2015-09-22 v3.do"
*it excludes datasets from Bangladesh, Cambodia and Vietnam (these countries impose restrictions on data reporting, see their "Conditions of use")
timer on 11

global path_to_dta `""E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\DHS\DHS datasets"'
#delimit ;
global path_list_20150922 `"
$path_to_dta\AL_2008-09_DHS_08032015_2231_80934\alir50dt\ALIR50FL" 
$path_to_dta\AM_2000_DHS_09192015_613_80934\amir42dt\AMIR42FL"
$path_to_dta\AM_2005_DHS_09192015_67_80934\amir54dt\AMIR54FL"
$path_to_dta\AM_2010_DHS_08042015_525_80934\amir61dt\AMIR61FL" 
$path_to_dta\AO_2011_MIS_08042015_56_80934\aoir61dt\AOIR61FL" 
$path_to_dta\AZ_2006_DHS_08042015_542_80934\azir52dt\AZIR52FL" 
$path_to_dta\BF_1993_DHS_09192015_717_80934\bfir21dt\BFIR21FL"
$path_to_dta\BF_1998-99_DHS_09192015_717_80934\bfir31dt\BFIR31FL"
$path_to_dta\BF_2003_DHS_09192015_717_80934\bfir43dt\BFIR43FL"
$path_to_dta\BF_2010_DHS_08042015_735_80934\bfir62dt\BFIR62FL" 
$path_to_dta\BJ_1996_DHS_09192015_652_80934\bjir31dt\BJIR31FL"
$path_to_dta\BJ_2001_DHS_09192015_651_80934\bjir41dt\BJIR41FL"
$path_to_dta\BJ_2011-12_DHS_08042015_544_80934\bjir61dt\BJIR61FL" 
$path_to_dta\BO_1989_DHS_09192015_71_80934\boir01dt\BOIR01FL"
$path_to_dta\BO_1998_DHS_09192015_70_80934\boir3bdt\BOIR3BFL"
$path_to_dta\BO_2003_DHS_09192015_70_80934\boir41dt\BOIR41FL"
$path_to_dta\BO_2008_DHS_08042015_547_80934\boir51dt\BOIR51FL" 
$path_to_dta\BR_1986_DHS_09192015_716_80934\brir01dt\BRIR01FL"
$path_to_dta\BR_1991_DHS_09192015_716_80934\brir21dt\BRIR21FL"
$path_to_dta\BR_1996_DHS_08042015_734_80934\brir31dt\BRIR31FL" 
$path_to_dta\BU_1987_DHS_09192015_725_80934\buir02dt\BUIR02FL"
$path_to_dta\BU_2010_DHS_08042015_738_80934\buir61dt\BUIR61FL" 
$path_to_dta\CD_2007_DHS_09202015_842_80934\cdir50dt\cdir50fl"
$path_to_dta\CD_2013-14_DHS_08052015_98_80934\cdir61dt\CDIR61FL" 
$path_to_dta\CF_1994-95_DHS_08052015_94_80934\cfir31dt\CFIR31FL" 
$path_to_dta\CG_2005_DHS_09202015_842_80934\cgir51dt\CGIR51FL"
$path_to_dta\CG_2011-12_DHS_08052015_97_80934\cgir60dt\CGIR60FL" 
$path_to_dta\CI_1994_DHS_09202015_842_80934\ciir35dt\CIIR35FL"
$path_to_dta\CI_1998-99_DHS_09202015_842_80934\ciir3adt\CIIR3AFL"
$path_to_dta\CI_2011-12_DHS_08052015_99_80934\ciir61dt\CIIR61FL" 
$path_to_dta\CM_1991_DHS_09202015_816_80934\cmir22dt\CMIR22FL"
$path_to_dta\CM_1998_DHS_09202015_815_80934\cmir31dt\CMIR31FL"
$path_to_dta\CM_2004_DHS_09202015_815_80934\cmir44dt\CMIR44FL"
$path_to_dta\CM_2011_DHS_08042015_739_80934\cmir60dt\CMIR60FL" 
$path_to_dta\CO_1986_DHS_09202015_823_80934\coir01dt\COIR01FL"
$path_to_dta\CO_1990_DHS_09202015_823_80934\coir22dt\coir22fl"
$path_to_dta\CO_1995_DHS_09202015_822_80934\coir31dt\COIR31FL"
$path_to_dta\CO_2000_DHS_09202015_822_80934\coir41dt\COIR41FL"
$path_to_dta\CO_2005_DHS_09202015_821_80934\coir53dt\COIR53FL"
$path_to_dta\CO_2010_DHS_08052015_95_80934\coir61dt\COIR61FL" 
$path_to_dta\DR_1986_DHS_09202015_848_80934\drir01dt\DRIR01FL"
$path_to_dta\DR_1991_DHS_09202015_848_80934\drir21dt\DRIR21FL"
$path_to_dta\DR_1996_DHS_09202015_848_80934\drir32dt\DRIR32FL"
$path_to_dta\DR_1999_DHS_09202015_848_80934\drir41dt\DRIR41FL"
$path_to_dta\DR_2002_DHS_09202015_848_80934\drir4adt\DRIR4AFL"
$path_to_dta\DR_2007_DHS_09202015_847_80934\drir52dt\DRIR52FL"
$path_to_dta\DR_2007_SpecialDHS_09222015_27_80934\drir5adt\DRIR5AFL"
$path_to_dta\DR_2013_DHS_08052015_99_80934\drir61dt\DRIR61FL" 
$path_to_dta\DR_2013_SpecialDHS_09222015_27_80934\drir6adt\DRIR6AFL"
$path_to_dta\EC_1987_DHS_08052015_910_80934\ecir01dt\ECIR01FL" 
$path_to_dta\EG_1988_DHS_09202015_90_80934\egir01dt\EGIR01FL"
$path_to_dta\EG_1992_DHS_09202015_90_80934\egir21dt\EGIR21FL"
$path_to_dta\EG_1995_DHS_09202015_90_80934\egir33dt\EGIR33FL"
$path_to_dta\EG_2000_DHS_09202015_90_80934\egir42dt\EGIR42FL"
$path_to_dta\EG_2003_InterimDHS_09222015_27_80934\egir4adt\EGIR4AFL"
$path_to_dta\EG_2005_DHS_09202015_90_80934\egir51dt\EGIR51FL"
$path_to_dta\EG_2008_DHS_09222015_412_80934\egir5adt\EGIR5AFL"
$path_to_dta\EG_2014_DHS_08052015_916_80934\egir61dt\EGIR61FL" 
$path_to_dta\ES_1985_DHS_08052015_917_80934\esir01dt\ESIR01FL" 
$path_to_dta\ET_2000_DHS_09212015_447_80934\etir41dt\ETIR41FL"
$path_to_dta\ET_2005_DHS_09212015_447_80934\etir51dt\ETIR51FL"
$path_to_dta\ET_2011_DHS_08052015_919_80934\etir61dt\ETIR61FL" 
$path_to_dta\GA_2000_DHS_09212015_451_80934\gair41dt\GAIR41FL"
$path_to_dta\GA_2012_DHS_08052015_919_80934\gair60dt\GAIR60FL" 
$path_to_dta\GH_1988_DHS_09212015_452_80934\ghir02dt\GHIR02FL"
$path_to_dta\GH_1993_DHS_09212015_452_80934\ghir31dt\GHIR31FL"
$path_to_dta\GH_1998_DHS_09212015_451_80934\ghir41dt\GHIR41FL"
$path_to_dta\GH_2003_DHS_09212015_451_80934\ghir4bdt\GHIR4BFL"
$path_to_dta\GH_2008_DHS_08052015_921_80934\ghir5adt\GHIR5AFL" 
$path_to_dta\GM_2013_DHS_08052015_920_80934\gmir60dt\GMIR60FL" 
$path_to_dta\GN_1999_DHS_09212015_510_80934\gnir41dt\GNIR41FL"
$path_to_dta\GN_2005_DHS_09212015_510_80934\gnir52dt\gnir52fl"
$path_to_dta\GN_2012_DHS_08052015_922_80934\gnir61dt\GNIR61FL" 
$path_to_dta\GU_1987_DHS_09212015_510_80934\guir01dt\GUIR01FL"
$path_to_dta\GU_1995_DHS_09212015_510_80934\guir34dt\GUIR34FL"
$path_to_dta\GU_1998-99_InterimDHS_08052015_921_80934\guir41dt\GUIR41FL" 
$path_to_dta\GU_1998-99_InterimDHS_09222015_27_80934\guir41dt\GUIR41FL"
$path_to_dta\GY_2009_DHS_08052015_922_80934\gyir5idt\GYIR5IFL" 
$path_to_dta\HN_2005-06_DHS_09212015_516_80934\hnir52dt\HNIR52FL"
$path_to_dta\HN_2011-12_DHS_08052015_923_80934\hnir62dt\HNIR62FL" 
$path_to_dta\HT_1994-95_DHS_09212015_515_80934\htir31dt\HTIR31FL"
$path_to_dta\HT_2000_DHS_09212015_514_80934\htir42dt\HTIR42FL"
$path_to_dta\HT_2005-06_DHS_09212015_514_80934\htir52dt\HTIR52FL"
$path_to_dta\HT_2012_DHS_08052015_923_80934\htir61dt\HTIR61FL" 
$path_to_dta\IA_1992-93_DHS_09212015_525_80934\iair23dt\IAIR23FL"
$path_to_dta\IA_1998-99_DHS_09212015_526_80934\iair42dt\IAIR42FL"
$path_to_dta\IA_2005-06_DHS_08052015_924_80934\iair52dt\IAIR52FL" 
$path_to_dta\ID_1987_DHS_09212015_535_80934\idir01dt\IDIR01FL"
$path_to_dta\ID_1991_DHS_09212015_535_80934\idir21dt\IDIR21FL"
$path_to_dta\ID_1994_DHS_09212015_535_80934\idir31dt\IDIR31FL"
$path_to_dta\ID_1997_DHS_09212015_535_80934\idir3adt\IDIR3AFL"
$path_to_dta\ID_2002-03_DHS_09212015_534_80934\idir42dt\IDIR42FL"
$path_to_dta\ID_2007_DHS_09212015_534_80934\idir51dt\IDIR51FL"
$path_to_dta\ID_2012_DHS_08052015_925_80934\idir62dt\IDIR62FL" 
$path_to_dta\JO_1990_DHS_09212015_547_80934\joir21dt\JOIR21FL"
$path_to_dta\JO_1997_DHS_09212015_546_80934\joir31dt\JOIR31FL"
$path_to_dta\JO_2002_DHS_09212015_546_80934\joir42dt\JOIR42FL"
$path_to_dta\JO_2007_DHS_09212015_546_80934\joir51dt\JOIR51FL"
$path_to_dta\JO_2009_InterimDHS_09212015_546_80934\joir61dt\JOIR61FL"
$path_to_dta\JO_2012_DHS_08112015_141_80934\JOIR6CDT\JOIR6CFL" 
$path_to_dta\KE_1989_DHS_09212015_550_80934\keir03dt\KEIR03FL"
$path_to_dta\KE_1993_DHS_09212015_550_80934\keir33dt\KEIR33FL"
$path_to_dta\KE_1998_DHS_09212015_550_80934\keir3adt\KEIR3AFL"
$path_to_dta\KE_2003_DHS_09212015_550_80934\keir42dt\KEIR42FL"
$path_to_dta\KE_2008-09_DHS_08112015_146_80934\KEIR52DT\KEIR52FL" 
$path_to_dta\KK_1995_DHS_09212015_550_80934\kkir31dt\KKIR31FL"
$path_to_dta\KK_1999_DHS_08112015_145_80934\KKIR42DT\KKIR42FL" 
$path_to_dta\KM_1996_DHS_09202015_842_80934\kmir32dt\KMIR32FL"
$path_to_dta\KM_2012_DHS_08052015_96_80934\kmir61dt\KMIR61FL" 
$path_to_dta\KY_1997_DHS_09212015_553_80934\kyir31dt\KYIR31FL"
$path_to_dta\KY_2012_DHS_08112015_146_80934\KYIR61DT\KYIR61FL" 
$path_to_dta\LB_1986_DHS_09212015_554_80934\lbir01dt\LBIR01FL"
$path_to_dta\LB_2007_DHS_09212015_553_80934\lbir51dt\LBIR51FL"
$path_to_dta\LB_2013_DHS_08112015_147_80934\LBIR6ADT\LBIR6AFL" 
$path_to_dta\LK_1987_DHS_08112015_213_80934\LKIR02DT\LKIR02FL" 
$path_to_dta\LS_2004_DHS_09212015_553_80934\lsir41dt\LSIR41FL"
$path_to_dta\LS_2009_DHS_11302015_2324_80934\lsir61dt\LSIR61FL" 
$path_to_dta\MA_1987_DHS_09212015_61_80934\mair01dt\MAIR01FL"
$path_to_dta\MA_1992_DHS_09212015_61_80934\mair21dt\MAIR21FL"
$path_to_dta\MA_2003-04_DHS_08112015_152_80934\MAIR43dt\MAIR43FL" 
$path_to_dta\MB_2005_DHS_08112015_151_80934\MBIR53DT\MBIR53FL" 
$path_to_dta\MD_1992_DHS_09212015_555_80934\mdir21dt\MDIR21FL"
$path_to_dta\MD_1997_DHS_09212015_555_80934\mdir31dt\MDIR31FL"
$path_to_dta\MD_2003-04_DHS_09212015_555_80934\mdir41dt\MDIR41FL"
$path_to_dta\MD_2008-09_DHS_08112015_148_80934\MDIR6HDT\MDIR6HFL" 
$path_to_dta\ML_1987_DHS_09212015_559_80934\mlir01dt\MLIR01FL"
$path_to_dta\ML_1995-96_DHS_09212015_559_80934\mlir32dt\MLIR32FL"
$path_to_dta\ML_2001_DHS_09212015_559_80934\mlir41dt\MLIR41FL"
$path_to_dta\ML_2006_DHS_09212015_559_80934\mlir53dt\MLIR53FL"
$path_to_dta\ML_2012-13_DHS_08112015_150_80934\MLIR6HDT\MLIR6HFL" 
$path_to_dta\MV_2009_DHS_08112015_149_80934\MVIR51DT\MVIR51FL" 
$path_to_dta\MW_1992_DHS_09212015_556_80934\mwir22dt\MWIR22FL"
$path_to_dta\MW_2000_DHS_09212015_555_80934\mwir41dt\MWIR41FL"
$path_to_dta\MW_2004_DHS_09212015_555_80934\mwir4ddt\MWIR4DFL"
$path_to_dta\MW_2010_DHS_08112015_149_80934\MWIR61DT\MWIR61FL" 
$path_to_dta\MX_1987_DHS_08112015_150_80934\MXIR01DT\MXIR01FL" 
$path_to_dta\MZ_1997_DHS_09212015_62_80934\mzir31dt\MZIR31FL"
$path_to_dta\MZ_2003_DHS_09212015_61_80934\mzir41dt\MZIR41FL"
$path_to_dta\MZ_2011_DHS_08112015_152_80934\MZIR62DT\MZIR62FL" 
$path_to_dta\NC_1998_DHS_09212015_69_80934\ncir31dt\NCIR31FL"
$path_to_dta\NC_2001_DHS_08112015_154_80934\NCIR41DT\NCIR41FL" 
$path_to_dta\NG_1990_DHS_09212015_612_80934\ngir21dt\NGIR21FL"
$path_to_dta\NG_2003_DHS_09212015_612_80934\ngir4bdt\NGIR4BFL"
$path_to_dta\NG_2008_DHS_09212015_612_80934\ngir53dt\NGIR53FL"
$path_to_dta\NG_2013_DHS_08112015_155_80934\NGIR6ADT\NGIR6AFL" 
$path_to_dta\NI_1992_DHS_09212015_610_80934\niir22dt\NIIR22FL"
$path_to_dta\NI_1998_DHS_09212015_610_80934\niir31dt\NIIR31FL"
$path_to_dta\NI_2006_DHS_09212015_69_80934\niir51dt\NIIR51FL"
$path_to_dta\NI_2012_DHS_08112015_154_80934\NIIR61DT\NIIR61FL" 
$path_to_dta\NM_1992_DHS_09212015_66_80934\nmir21dt\NMIR21FL"
$path_to_dta\NM_2000_DHS_09212015_65_80934\nmir41dt\NMIR41FL"
$path_to_dta\NM_2006-07_DHS_09212015_65_80934\nmir51dt\nmir51fl"
$path_to_dta\NM_2013_DHS_08112015_153_80934\NMIR61DT\NMIR61FL" 
$path_to_dta\NP_1996_DHS_09212015_66_80934\npir31dt\NPIR31FL"
$path_to_dta\NP_2001_DHS_09212015_66_80934\npir41dt\NPIR41FL"
$path_to_dta\NP_2006_DHS_09212015_66_80934\npir51dt\NPIR51FL"
$path_to_dta\NP_2011_DHS_08112015_154_80934\NPIR60DT\NPIR60FL" 
$path_to_dta\OS_1986_SpecialDHS_08112015_156_80934\OSIR01DT\OSIR01FL" 
$path_to_dta\PE_1986_DHS_09212015_98_80934\peir01dt\PEIR01FL"
$path_to_dta\PE_1991-92_DHS_09212015_98_80934\peir21dt\PEIR21FL"
$path_to_dta\PE_1996_DHS_09212015_620_80934\peir31dt\PEIR31FL"
$path_to_dta\PE_2000_DHS_09212015_620_80934\peir41dt\PEIR41FL"
$path_to_dta\PE_2004-06_ContinuousDHS_09212015_620_80934\peir51dt\PEIR51FL"
$path_to_dta\PE_2007-08_ContinuousDHS_09212015_620_80934\peir5adt\PEIR51FL"
$path_to_dta\PE_2009_ContinuousDHS_09212015_620_80934\peir5idt\PEIR5IFL"
$path_to_dta\PE_2010_ContinuousDHS_09212015_619_80934\peir61dt\PEIR61FL"
$path_to_dta\PE_2011_ContinuousDHS_09212015_613_80934\peir6adt\PEIR6AFL"
$path_to_dta\PE_2012_ContinuousDHS_08112015_20_80934\PEIR6IDT\PEIR6IFL" 
$path_to_dta\PH_1993_DHS_09212015_99_80934\phir31dt\PHIR31FL"
$path_to_dta\PH_1998_DHS_09212015_99_80934\phir3bdt\PHIR3BFL"
$path_to_dta\PH_2003_DHS_09212015_98_80934\phir41dt\PHIR41FL"
$path_to_dta\PH_2008_DHS_09212015_98_80934\phir52dt\PHIR52FL"
$path_to_dta\PH_2013_DHS_08112015_21_80934\PHIR61DT\PHIR61FL" 
$path_to_dta\PK_1990-91_DHS_09212015_612_80934\pkir21dt\PKIR21FL"
$path_to_dta\PK_2006-07_DHS_09212015_612_80934\pkir52dt\pkir52fl"
$path_to_dta\PK_2012-13_DHS_08112015_158_80934\PKIR61DT\PKIR61FL" 
$path_to_dta\PY_1990_DHS_08112015_20_80934\PYIR21DT\PYIR21FL" 
$path_to_dta\RW_1992_DHS_09212015_913_80934\rwir21dt\RWIR21FL"
$path_to_dta\RW_2000_DHS_09212015_913_80934\rwir41dt\RWIR41FL"
$path_to_dta\RW_2005_DHS_09212015_912_80934\rwir53dt\RWIR53FL"
$path_to_dta\RW_2007-08_InterimDHS_09212015_912_80934\rwir5adt\RWIR5AFL"
$path_to_dta\RW_2010_DHS_08112015_29_80934\RWIR61DT\RWIR61FL" 
$path_to_dta\SD_1989-90_DHS_08112015_225_80934\SDIR02DT\SDIR02FL" 
$path_to_dta\SL_2008_DHS_09212015_932_80934\slir51dt\SLIR51FL"
$path_to_dta\SL_2013_DHS_08112015_212_80934\SLIR61DT\SLIR61FL" 
$path_to_dta\SN_1986_DHS_09212015_914_80934\snir02dt\SNIR02FL"
$path_to_dta\SN_1992-93_DHS_09212015_914_80934\snir21dt\SNIR21FL"
$path_to_dta\SN_1997_DHS_09212015_914_80934\snir32dt\SNIR32FL"
$path_to_dta\SN_2005_DHS_09212015_914_80934\snir4hdt\SNIR4HFL"
$path_to_dta\SN_2010-11_DHS_09212015_928_80934\snir61dt\SNIR61FL"
$path_to_dta\SN_2012-13_ContinuousDHS_09212015_913_80934\snir6ddt\SNIR6DFL"
$path_to_dta\SN_2014_ContinuousDHS_08112015_211_80934\SNIR70DT\SNIR70FL" 
$path_to_dta\ST_2008-09_DHS_08112015_29_80934\STIR50DT\STIR50FL" 
$path_to_dta\SZ_2006-07_DHS_08112015_225_80934\SZIR51dt\szir51fl" 
$path_to_dta\TD_1996-97_DHS_09202015_821_80934\tdir31dt\TDIR31FL"
$path_to_dta\TD_2004_DHS_08052015_94_80934\tdir41dt\TDIR41FL" 
$path_to_dta\TG_1988_DHS_09212015_934_80934\tgir01dt\TGIR01FL"
$path_to_dta\TG_1998_DHS_09212015_934_80934\tgir31dt\TGIR31FL"
$path_to_dta\TG_2013-14_DHS_08112015_228_80934\TGIR61DT\TGIR61FL" 
$path_to_dta\TH_1987_DHS_08112015_227_80934\THIR01DT\THIR01FL" 
$path_to_dta\TJ_2012_DHS_08112015_226_80934\TJIR61DT\TJIR61FL" 
$path_to_dta\TL_2009-10_DHS_08112015_227_80934\TLIR61DT\TLIR61FL" 
$path_to_dta\TN_1988_DHS_08112015_229_80934\TNIR02DT\TNIR02FL" 
$path_to_dta\TR_1993_DHS_09212015_948_80934\trir31dt\TRIR31FL"
$path_to_dta\TR_1998_DHS_09212015_948_80934\trir41dt\TRIR41FL"
$path_to_dta\TR_2003_DHS_08112015_229_80934\TRIR4ADT\TRIR4AFL" 
$path_to_dta\TT_1987_DHS_08112015_228_80934\TTIR01DT\TTIR01FL" 
$path_to_dta\TZ_1991-92_DHS_09212015_933_80934\tzir21dt\TZIR21FL"
$path_to_dta\TZ_1996_DHS_09212015_933_80934\tzir3adt\TZIR3AFL"
$path_to_dta\TZ_1999_DHS_09212015_932_80934\tzir41dt\TZIR41FL"
$path_to_dta\TZ_2004-05_DHS_09212015_932_80934\tzir4idt\TZIR4IFL"
$path_to_dta\TZ_2010_DHS_08132015_739_80934\TZIR63DT\TZIR63FL" 
$path_to_dta\UA_2007_DHS_08112015_230_80934\UAIR51dt\UAIR51FL" 
$path_to_dta\UG_1988-89_DHS_09212015_949_80934\ugir01dt\UGIR01FL"
$path_to_dta\UG_1995_DHS_09212015_949_80934\ugir33dt\UGIR33FL"
$path_to_dta\UG_2000-01_DHS_09212015_949_80934\ugir41dt\UGIR41FL"
$path_to_dta\UG_2006_DHS_09212015_949_80934\ugir52dt\UGIR52FL"
$path_to_dta\UG_2011_DHS_08132015_738_80934\UGIR60DT\UGIR60FL" 
$path_to_dta\UZ_1996_DHS_09212015_954_80934\uzir31dt\UZIR31FL"
$path_to_dta\YE_1991-92_DHS_09212015_954_80934\yeir21dt\YEIR21FL"
$path_to_dta\YE_2013_DHS_08112015_232_80934\YEIR61DT\YEIR61FL" 
$path_to_dta\ZA_1998_DHS_08112015_212_80934\ZAIR31DT\ZAIR31FL" 
$path_to_dta\ZM_1992_DHS_09212015_955_80934\zmir21dt\ZMIR21FL"
$path_to_dta\ZM_1996_DHS_09212015_955_80934\zmir31dt\ZMIR31FL"
$path_to_dta\ZM_2001-02_DHS_09212015_955_80934\zmir42dt\ZMIR42FL"
$path_to_dta\ZM_2007_DHS_09212015_954_80934\zmir51dt\ZMIR51FL"
$path_to_dta\ZM_2013-14_DHS_08112015_233_80934\ZMIR61DT\ZMIR61FL" 
$path_to_dta\ZW_1988_DHS_09212015_100_80934\zwir01dt\ZWIR01FL"
$path_to_dta\ZW_1994_DHS_09212015_101_80934\zwir31dt\ZWIR31FL"
$path_to_dta\ZW_1999_DHS_09212015_101_80934\zwir42dt\ZWIR42FL"
$path_to_dta\ZW_2005-06_DHS_09212015_101_80934\zwir51dt\ZWIR51FL"
$path_to_dta\ZW_2010-11_DHS_08112015_233_80934\ZWIR62DT\ZWIR62FL" 
"'
;
#delimit cr

timer off 11




* 1.2 Make a processed file for each dataset
timer on 12

*Define a program for the processing
capture program drop preparation
program define preparation // 
	args dataset_arg
	qui {
		keep case*id v000 v011 v102 b0_*  b4_*  v201 v218 // retain only relevant variables
		forval i = 1(1)20 { // loop over births
			gen var`i' = . // generate binary variables for sexes of sibs
		}
		gen sequence = "" // generate a variable where birth sequences will be recorded (e.g. it could be BBGG)
		
		local i = 1
		foreach var of varlist b4*  { // loop over births
			replace var`i' = `var' // put values from b4*-variables into newly created "var"-variables. I assume that b4*-vars are properly sorted in DHS file.
			replace var`i' = . if var`i' ==9 // recode missing values (9 in DHS)
			replace var`i' = var`i' - 1 // recode males as 0, females as 1
			gen seq`i' = "" // 
				replace seq`i' = "B" if var`i' == 0 // record the sex as a letter: B for boy...
				replace seq`i' = "G" if var`i' == 1 // ... and G for girl
				replace sequence = sequence + seq`i' // append this letter to the birth sequence
				drop seq`i'
			local i = `i' + 1
			if `i' == 21 continue, break // need this because few datasets contain more than 20 b4-variables.
		}
		drop if sequence == "" // remove empty sequences (women without children)
		replace sequence = reverse(sequence) // this would be correct birth order, because variables b4* list sibs starting from last one.
		gen length = length(sequence) // record offspring size
		gen dataset = "`dataset_arg'" // record dataset code
		capture drop b4_*   // drop unnecessary variables
	} // end of -qui-	
end

foreach path in  $path_list_20150922 { // Loop over datasets. 
	local dataset = substr("`path'", 115, 7)
	di "`dataset'"
	use "`path'.dta", clear  // using big (originally downloaded from DHS) file
	preparation `dataset' // run the program for conversion
	qui saveold "`path'_processed_151014.dta", replace // save converted file
	local country = substr("`path'",115,7) // record country code into the macro `country'. The two-letter code starts with character #115 in the file path.
}
timer off 12
timer off 10


*Summary statistics of datasets
capture program drop test
program define test, byable(recall, noheader) rclass
		*Calculate sex ratio (one for whole sample)
		local a = 0 
		local b = 0
		forval i = 1/20 { // loop over birth index, from last to first child
			qui count if var`i' !=. // total number of children with index `i' 
			local a = `a' + r(N) // add this number to the `a'
			qui count if var`i' == 0 // number of boys with index `i'
			local b = `b' + r(N) // add this number to the `b'
		}
		return local r = `b'/`a' // sex ratio for whole sample
		* di "r= " `r'
end

di "Header: dataset, number of women, number of children, mean sibship size, median sibship size, sex ratio"
foreach path in  $path_list_20150922 { // loop over datasets
	qui use "`path'_processed_151014.dta", clear 
	local dataset = substr("`path'",115,7) // the second argument (positition in the path where country code starts) depends on where the file is located. 
	test
	local r = r(r)
	qui su length, detail
	di "`dataset'" char(9) r(N) char(9) r(sum) char(9) r(mean) char(9) r(p50) char(9) `r' // display dataset code
	
}



* 2. Combine processed files into one 
* based on "2015-10-14 merge DHS datasets for tabulation tests.do"
* List of file paths was defined at step 1.1
timer on 20

local i=1
foreach path in  $path_list_20150922 { // loop over datasets
	if `i'==1 { // open the first converted dataset, save it as a primer of new large merged file
		qui use "`path'_processed_151014.dta", clear 
		qui saveold "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-10-14 merged DHS data for tabulation.dta", replace
	}
	else { // append all other converted datasets
		qui append using "`path'_processed_151014.dta", nolabel 
	}
	local dataset = substr("`path'",115,7) // the second argument (positition in the path where country code starts) depends on where the file is located. 
	di "`dataset'" // display dataset code
	local i=`i'+1
}

* Generate additional variables: indicator of plural birht, numbers of boys and girls (see dairy for Oct 14, 2015)
capture drop plural_birth 
gen plural_birth = 0
forval i = 1/9 {
	replace plural_birth = 1 if b0_0`i' != 0 & b0_0`i' != .
}
forval i = 10/20 {
	replace plural_birth = 1 if b0_`i' != 0 & b0_`i' != .
}
egen girls = rowtotal(var1-var20)
gen boys = length - girls
qui saveold "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-10-14 merged DHS data for tabulation.dta", replace



* Display total number of sibships and number of children. 
*assuming that the file "2015-10-14 merged DHS data for tabulation.dta" is already open
su length
di "Number of children = " r(sum) ", number of sibships = " r(N)
* Display summary statistics
tab length // 

timer off 20




* 3. Tabulation tests
*based on "2015-10-14 omnibus tabulation test.do"
*assuming that the file "2015-10-14 merged DHS data for tabulation.dta" is already open
timer on 30


* 3.1 Omnibus tabulation
*assuming that the file "2015-10-14 merged DHS data for tabulation.dta" is already open
timer on 31

*Define a program for tabulation tests
capture program drop ch_test_omnibus
program define ch_test_omnibus, rclass
		syntax [name (name=choice_of_r)] [if]	
		
	qui {
		preserve
		capture keep `if'
		tempname boys x y
		
		*Calculate sex ratio (one for whole sample)
		local a = 0 
		local b = 0
		forval i = 1/20 { // loop over birth index, from last to first child
			qui count if var`i' !=. // total number of children with index `i' 
			local a = `a' + r(N) // add this number to the `a'
			qui count if var`i' == 0 // number of boys with index `i'
			local b = `b' + r(N) // add this number to the `b'
		}
		local r = `b'/`a' // sex ratio for whole sample
		*noi di "sex ratio = " `r'
	
		*Calculate expected and observed frequencies, record then into string macros
		local tabi_line1 // empty macro for a string of observed frequencies. Numbers will be added here during the loops below
		local tabi_line2 // empty macro for a string of expected frequencies.  			
		
		*loop over offspring lengths
		forval n = 1/20 { // 
			count if length == `n' // number of offsprings with this length
			local N_`n' = r(N) // save this number
			
			*Calculate sex ratio for offsprings with size `n'
			local a = 0 // it will be total number of children (in offsprings with size `n')
			local b = 0 // it will be number of boys in these offsprings
				forval i = 1/`n' { // loop over birth index, from last to first child
					qui count if var`i' !=. & length==`n' // total number of children with index `i' 
					local a = `a' + r(N) // add this number to the `a'
					qui count if var`i'==0  & length==`n' // number of boys with index `i'
					local b = `b' + r(N) // add this number to the `b'
				}
			local r_`n' = `b'/`a' // sex ratio for given offspring size
			*noi di "sex ratio for n = " `n' " : " `r_`n''

			*loop over possible numbers of boys in the offpring of size n
			forval k = 0/`n' { // 
				if "`choice_of_r'" == "n_specific" {
					local exp_`k'_`n' = int(binomialp(`n',`k',`r_`n'')*`N_`n'')  // expected frequency to have k boys in an offspring with size n.
				}
				if "`choice_of_r'" == "one_for_whole_sample" {
					local exp_`k'_`n' = int(binomialp(`n',`k',`r')*`N_`n'')  // expected frequency to have k boys in an offspring with size n.
				}				
				count if boys == `k' & length == `n' // observed frequency
				local obs_`k'_`n' = r(N) // save the observed frequency
				local tabi_line1 `tabi_line1' , `obs_`k'_`n'' // record observed frequency for given k/n  into the string
				local tabi_line2 `tabi_line2' , `exp_`k'_`n'' // record expected frequency for given k/n  into the string 
			}
		}
		mat input `x' = (`tabi_line1' \ `tabi_line2') // matrix with two long rows (it is not suitable for -tabi-)
		mat `y' = `x'' // traspose the matrix x, make matrix y with two long columns (suitable for -tabi-).
		
		*Using tranposed matrix, create one string that will be used as an input for -tabi- 
			*(code from http://www.stata.com/statalist/archive/2010-06/msg01631.html)
		local r = rowsof(`y')					// count rows of matrix
		local c = colsof(`y')					// count cols of matrix
		forvalues k = 1 / `r' {	
			forvalues j = 1 / `c' {
				local n = `y'[`k',`j']
				local tchi "`tchi' `n'"
				if `j' == `c' & `k' != `r' { 	// backslash after last col but not in last row
					local tchi "`tchi' \"
				}
			}
		} 
		
		*Chi2-Test
		tabi "`tchi'", chi lrchi2  					
		local df = r(r) - 1 // degrees of freedom
		
		restore
	} // end of -qui-
	di "chi-square = " r(chi2) "; df = " `df' "; p = " r(p)
end

*Run the tests
*assuming that the file "2015-10-14 merged DHS data for tabulation.dta" is already open.
di "Tabulation test for all sibships, using specific r for each sibship size:"
	ch_test_omnibus n_specific
di "... excluding sibships with at least one plural birth:"
	ch_test_omnibus n_specific if plural_birth!=1
di "... using only one value of `r', calculated for whole samples (instead of n-specific r's):"
	ch_test_omnibus one_for_whole_sample 
timer off 31




* 3.2	Tabulation test for each sibship type (as characterized by n and k)
* based on "2015-10-14 tabulation by n and k _in combined data.do"
timer on 32

*Define a program
capture program drop ch_test_composition
program define ch_test_composition, rclass
	args n k 
	qui {
		preserve
			keep if plural_birth!=1
			keep if length == `n' // keep only offsprings with specific size
			
			*Calculate observed frequencies
			count
			local total = r(N) // total number of offsprings
			count if boys==`k'
			if r(N)==0 exit // stop the program if there are no offsprings with k boys
			local seq_of_interest = r(N) // number of offsprings of iterest
			local others = `total' - `seq_of_interest' // offsprings other than the sequence of interest
						
			*Calculate expected frequencies
			local a = 0 // it will be total number of children
			local b = 0 // it will be number of boys
			forval i = 1/`n' { // loop over birth index, from last to first child
				count if var`i' !=. // total number of children with index `i' 
				local a = `a' + r(N) // add this number to the 'a'
				count if var`i' == 0 // number of boys with index `i'
				local b = `b' + r(N) // add this number to the `b'
			}
			local r = `b'/`a' // frequency of boys
			noi di "sex ratio = " `r'
			
			local seq_of_interest_exp = int(binomialp(`n',`k',`r')*`total')  // expected frequency to have k boys in an offspring with size n (take integral part of this).
			local others_exp = `total' - `seq_of_interest_exp' // expected number of other offsprings
			local freq_obs = `seq_of_interest'/`total'
			local freq_exp = `seq_of_interest_exp'/`total'
		restore
	} // end of -qui-
	
	tabi "`seq_of_interest'" "`others'" \ "`seq_of_interest_exp'" "`others_exp'"
	
	return scalar seq_of_interest = `seq_of_interest'
	return scalar others = `others'
	return scalar seq_of_interest_exp = `seq_of_interest_exp'
	return scalar others_exp = `others_exp'
	return scalar or = (`seq_of_interest'/`others')/(`seq_of_interest_exp'/`others_exp')
	return scalar sample_size = `total'
	return scalar freq_obs = `freq_obs'
	return scalar freq_exp = `freq_exp'
	return scalar p_exact = r(p_exact)
end


*Run the tabulation test for each pair of `n' and `k'
*assuming that the file "2015-10-14 merged DHS data for tabulation.dta" is already open.
di "n / k / Observed frequency / Expected frequency / Sample size / OR / p-value" // header of the table
forval n = 2/10 { // loop over offspring sizes. Here I analyse only sibships with up to 10 children
	forval k = 0/`n' { // loop over possible numbers of boys in the offspring
		qui ch_test_composition `n' `k'
		di "`n'" char(9) "`k'" char(9) r(freq_obs) char(9) r(freq_exp) char(9) r(sample_size) char(9) r(or) char(9) r(p_exact) 
	}
}	
timer off 32
timer off 30




*	4.	Logistic regression
timer on 40

*	4.1.	Process individual datasets to make them suitable for logit
* based on "2015-10-19 preparation.do"
*list of datasets was defined at step 1.1
timer on 41


*Define the program for preparation of datasets for logit
capture program drop preparation
program define preparation
	args dataset_arg
	qui {
		rename (b11_0* b3_0* b0_0*) (b11_* b3_* b0_*)  // renaming DHS vars, so each of these var will have just a number after underscore sign, not a number preceeded by zeros symbol.
		duplicates drop case*id, force
		
		gen dv = . // Dependent varirable for logit
		gen date_of_birth = . // Date of birth (CMC) of child
		gen mult_birth = . // doesn't equal zero if the child is from multiple birth
		gen prev_mult_birth = . // doesn't equal zero if PREVIOUS child is from multiple birth
		gen sequence = "" // generate birth sequences (BBGG etc)
		gen woman = _n // give serial number to each woman
		gen dataset = "`dataset_arg'"
		forval i = 1/20 {
			gen var`i' = . // generate binary variables for sexes of sibs
			gen iv`i' = . // independent variables for logit (sexes of previous sibs, if any)
			gen date_of_birth_iv`i' =. // date of birth of sib corresponding to iv`i' variable
			gen interval_iv`i' =. // time between current birth and birth of sib corresponding to iv`i' variable
			gen prev_mult_birth_iv`i' =. // whether iv`i'th sib was from plural birth
		}
				
		*Copy sibs' sexes from variables b4* to variables var1-var20; create birth sequence as BGBB...
		local i = 1
		foreach var of varlist b4*  { // some datasets have less than 20 b4* variables. 
			replace var`i' = `var' // put values from b4*-variables into newly created "var"-variables. I assume that b4*-vars are properly sorted in DHS file.
			replace var`i' = . if var`i' ==9 // recode missing values (9 in DHS)
			replace var`i' = var`i' - 1 // recode males as 0, females as 1
			gen seq`i' = ""
				replace seq`i' = "B" if var`i' == 0
				replace seq`i' = "G" if var`i' == 1
				replace sequence = sequence + seq`i'
				drop seq`i'
			local i = `i' + 1
			if `i' == 21 continue, break // need this because some datasets contain more than 20 b4-variables.
		}
		drop if sequence == ""
		replace sequence = reverse(sequence) // this would be correct birth order, because variables b4* list sibs starting from last one.
		gen length = length(sequence) // record offspring size
		
		*Expand dataset (each offspring is represented by N rows, where N is the size of this offspring)
		expand length 
		sort woman
		by woman: gen child_number = _n // count number of children of each woman. This var will correspond to birth order.
		gen child_index = length - child_number + 1 // this var will correspond to birth index (reverse of birth order)

		*Record values of dependent, independent variables and covariates
		forval i = 20(-1)1 { // `i' would be child_index of "dep var" child. Counting in reverse order, because higher child_index corresponds to earlier birth.
			capture replace dv = var`i' if child_index==`i'
			capture replace date_of_birth = b3_`i' if child_index==`i'
			capture replace mult_birth = b0_`i' if child_index==`i'
			
			forval k=1/19 { // `k' is number of IV (the difference in birth order between "dependent" and "independent" sibs). Eg, if k=1 and i=1, then independent variable is iv1 - the sex of sib with child_index==2 (that is, previous child).
				local j`k' = `i' + `k' // number of preceeding ("indep var") child (if any). "+" because higher child_index corresponds to earlier birth.
				capture replace iv`k' = var`j`k'' if child_index==`i' // record value of independent var: it would be value of var* that differes from `i' by `k' units.
				capture replace date_of_birth_iv`k' = b3_`j`k'' if child_index==`i' // data of birth of this "indep" sib
				capture replace interval_iv`k' = date_of_birth - date_of_birth_iv`k' if child_index==`i' // interval between births of "dependent" i'th sib, and independent `j`k'' 'th sib.
				capture replace prev_mult_birth_iv`k' = b0_`j`k'' if child_index==`i' 
			}
		}

		gen mothers_age = date_of_birth - v011
		drop b0_* b1_* b3_* b4_* b11_* bidx_* bord_* // drop unnecessary vars 
		order v000 case*id woman sequence length child_number child_index  mothers_age v012 dv iv* interval_iv* var* prev_mult_birth_iv* date_of_birth   , first
		sort woman child_number
	} // end of qui
end

*Prepare the datasets
foreach path in $path_list_20150922 { // loop over datasets
	local dataset = substr("`path'", 115, 7)
	di "`dataset'"
	qui use "`path'.dta", clear  // open original dataset file
	capture noisily keep v000 case*id v011 v102 b0_* b1_* b3_* b4_* b11_* bidx_* bord_* v201 v218 v008 v011 v012
	capture noisily preparation `dataset'
	capture recast byte woman length child_number child_index mothers_age dv iv* interval_iv* var* *mult_birth*  // reduce file sizes by recasting
	qui saveold "`path'_processed_151019.dta", replace 
}	

timer off 41




*	4.2	Merge processed files for logit
* based on "2015-10-19 merge datasets for logit.do"
*list of datasets was defined earlier: step 1.1
timer on 42

*Merge the files
local i=1
foreach path in  $path_list_20150922 {
	if `i'==1 { 
		qui use "`path'_processed_151019.dta", clear 
		qui keep v000-interval_iv20 prev_mult_birth_iv1- v102 v201-dataset 
		qui saveold "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-10-19 merged DHS data for logit.dta", replace
	}
	else {
		qui append using "`path'_processed_151019.dta", nolabel ///
			keep(v000-interval_iv20 prev_mult_birth_iv1- v102 v201-dataset)
	}
	local dataset = substr("`path'",115,7) // the second argument (positition in the path where country code starts) depends on where the file is located. 
	di "`dataset'" 
	local i=`i'+1
}
capture gen time_since_birth = (v008 - v011) - mothers_age  // the interval between last birth and the interview ("mother's age" is the age at last birth). Need it for step 4.6	Effect of the interval between last birth and the interview.
qui saveold "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-10-19 merged DHS data for logit.dta", replace

timer off 42




*	4.3	Logit in combined sample
timer on 43

*assuming that the file "2015-10-19 merged DHS data for logit.dta" is already open.

* All subjects
* based on "2015-10-19 logit in merged file.do"
logit dv iv1   /// 
	if child_index!=.  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)
esttab
tempname m
mat `m' = r(coefs)
local percent_change = invlogit(`m'[2,1] + `m'[1,1])  - invlogit(`m'[2,1])
di "Percent change = `percent_change'"


* Excluding last children
logit dv iv1   /// 
	if child_index!=1  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)
esttab
tempname m
mat `m' = r(coefs)
local percent_change = invlogit(`m'[2,1] + `m'[1,1])  - invlogit(`m'[2,1])
di "Percent change = `percent_change'"


* Only last children
logit dv iv1   /// 
	if child_index==1  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)
esttab
tempname m
mat `m' = r(coefs)
local percent_change = invlogit(`m'[2,1] + `m'[1,1])  - invlogit(`m'[2,1])
di "Percent change = `percent_change'"

timer off 43




*	4.4	Logit by n and i
* based on "2015-09-23 logit by child_number and offspring size.do"
timer on 44

*Define the program for logit
capture program drop logit_regression
program define logit_regression, rclass
	args i_arg n_arg // i - child_number; n - sibship size (length)
	qui {
		logit dv iv1   /// 
			if child_number==`i_arg' & length==`n_arg'  ///
			& v201==length /// reported number of children is consistent with value of v201
			& mult_birth==0  /// not from plural birth
			& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not from plural birth
			& interval_iv1>9 ///
			, technique(bfgs)
		esttab, se
		tempname b
		mat `b' = r(coefs)
	} // end of -qui- 
	di  `n_arg' char(9) `i_arg' char(9) `b'[1,1] char(9) `b'[1,2] char(9) `b'[1,3] char(9) e(N)   //      char(9) `b'[2,1] char(9) `b'[2,2] char(9) `b'[2,3]
end

*Loop over n and i
di "Header: n, i, coef, se, p-value, N "
forval n = 2/10 { // loop over offspring sizes
	forval i = 2/`n' { // loop over child numbers (including last child)
		logit_regression `i' `n'
	}
}

timer off 44




*	4.5 Meta-analysis
* based on "2015-09-22 logit.do"
timer on 45

*Define a program for logit
capture program drop logit_regression
program define logit_regression, rclass
	syntax [anything (name=path_arg)] [if] 
	qui {
		logit dv iv1   /// 
			`if'  ///
			& v201==length /// reported number of children is consistent with value of v201
			& mult_birth==0  /// not from plural birth
			& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not from plural birth
			& interval_iv1>9 ///
			, technique(bfgs)
	esttab, se
	tempname b
	mat `b' = r(coefs)
	*order of display: coef, se, p-value, N (then, optionally, same for second independent variable)
	} // end of -qui-
	*di "`path_arg'" char(9) `b'[1,1] char(9) `b'[1,2] char(9) `b'[1,3] char(9) e(N)     //    char(9) `b'[2,1] char(9) `b'[2,2] char(9) `b'[2,3]
	
	return scalar coef = `b'[1,1]
	return scalar se = `b'[1,2]
	return scalar coef_cov1 = `b'[2,1]
	return scalar se_cov1 = `b'[2,2]
	return scalar coef_cov2 = `b'[3,1]
	return scalar se_cov2 = `b'[3,2]
	return scalar n = e(N)
end

*list of datasets was defined at step 1.1

*Define a program for meta-analysis
capture program drop meta_analysis
program define meta_analysis
	syntax [anything (name=condition)]
	
	*Make a file for metan data
	clear
	qui {
		set obs 500
		gen dataset = ""
		gen coef = .
		gen se = .
		gen coef_cov1 = .
		gen se_cov1 = .
		gen coef_cov2 = .
		gen se_cov2 = .
		gen n = .
		tempfile metan_file
		save `metan_file'.dta, replace
		local l = 1
	} // end of qui
	
	*Loop over datasets
	*di "Header: coef, se, p-value, N " // In case we display results of regression in each dataset
	foreach path in  $path_list_20150922 {
		local dataset = substr("`path'",115,7) // the second argument (positition in the path where country code starts) depends on where the file is located. 
		use "`path'_processed_151019.dta", clear  // using processed file
		logit_regression `dataset' if `condition'  // the condition determined which children will be included into the model (all, i!=n or i==n)
		qui {
			use `metan_file'.dta, clear
				replace dataset = "`dataset'" in `l'
				replace coef = r(coef) in `l'
				replace se = r(se) in `l'
				replace coef_cov1 = r(coef_cov1)  in `l'
				replace se_cov1 = r(se_cov1) in `l'
				replace coef_cov2 = r(coef_cov2)  in `l'
				replace se_cov2 = r(se_cov2) in `l'
				replace n = r(n) in `l'
			save `metan_file'.dta, replace
		} // end of -qui-
		return clear
		ereturn clear
		local l=`l'+1
	}

	*Meta-analysis
	use `metan_file'.dta, clear
		qui tabstat n, stat(sum) save
		qui tempname m
		qui mat `m' = r(StatTotal)
	metan coef se, random lcols(dataset) nograph
		di "p-value = " r(p_z)
		di "Sample size (number of pairs) = " `m'[1,1]
	
end	

*Run the meta-analyses
di "All children: "
	meta_analysis child_number!=.
di "Excluding last child: "
	meta_analysis child_number!=length
di "Only last child:"
	meta_analysis child_number==length

timer off 45



	
*	4.6	Effect of the interval between last birth and the interview
timer on 46

use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-10-19 merged DHS data for logit.dta", clear

logit dv iv1   /// 1st model: only sex of preceding sibling
	if child_index==1  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)

logit dv iv1 time_since_birth   /// 2nd model: sex of preceding sibling and the interval
	if child_index==1  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)

logit dv c.iv1##c.time_since_birth   /// 3rd model: same as 2nd model, with interaction term
	if child_index==1  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)	

*check the distribution of time_since_birth 
su time_since_birth if child_index==1 & mult_birth==0 & (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. ) & interval_iv1>9, detail
 
logit dv iv1   ///  logit for bottom 10% of interval values
	if child_index==1  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	& time_since_birth < 6 ///
	, technique(bfgs)
	
logit dv iv1   /// logit for top 10% of interval values
	if child_index==1  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	& time_since_birth > 167 ///
	, technique(bfgs)	
 
timer off 46




*	4.7 	Correlations between sexes of siblings separated by various numbers of births
* based on "2015-10-17 logit for various iv_i.do"
timer on 47

di "Header: i, coef, p, N"
foreach cond in  "child_number!=." "child_number!=length" "child_number==length"   {
	di "Condition: IF `cond'"
	forval i=1/10 { // loop over various numbers of births separating the two births of interest
		qui {
			logit dv iv`i'   /// 
				if `cond'  /// not last / last child
				& v201==length /// reported number of children is consistent with value of v201
				& mult_birth==0  /// not twin
				& (prev_mult_birth_iv`i'==0 | prev_mult_birth_iv`i'==. )  /// previous sib is not twin
				& interval_iv`i' > 9 //
			esttab
			tempname m
			mat `m' = r(coefs)
		} // end of qui
		di "i = `i'" char(9) `m'[1,1] char(9) `m'[1,3] char(9) e(N)
	}	
}

timer off 47
timer off 40




* 5.	Modelling with MLE
timer on 50

*	5.1	Prepare data for the use with Astolfi's code
* based on "2015-11-16 convert DHS data for Astolfi code.do"
timer on 51

use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-10-14 merged DHS data for tabulation.dta", clear
drop if plural_birth==1 & v201!=length 
keep sequence
gen n = _n
collapse (count) n, by(sequence)
gen length = length(sequence)
save "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-11-16 DHS data for Astolfi code.dta", replace

timer off 51




*	5.2	The MLE
* based on "2015-11-30 DHS with Astolfi _all sibships _first 4 sibs.do"
timer on 52

use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-11-16 DHS data for Astolfi code.dta", clear // this file is small, it doesn't take much time to load it again (unlike "2015-10-14 merged DHS data for tabulation" and the large file for logit)
preserve
	gen sequence_first4 = substr(sequence,1,4) // full sequence for sibships with up to 4 sibs, or first 4 sibs in sipships with more than 4 sibs
	gen incomplete = 0 // an index of family completness: 0 for sibships with 4 or less sibs...
		replace incomplete = 1 if length>4 // ... and 1 for sibships with more than 4 sibs.
	collapse (sum) n, by(sequence_first4 incomplete) // collapse, so each observation will indicate N(S) if incomplete=0, or N(larger sequences,>4sibs, that start with S) if incomplete=1.

*Define a program to display actual estimates after -ml- (not the arguments)
capture program drop display_estimates
program define display_estimates
	tempname m
	mat `m' = e(b)
	di "k_20 = " 2*invlogit(`m'[1,1])
	di "k_21 = " 2*invlogit(`m'[1,2])
	di "k_30 = " 2*invlogit(`m'[1,3])
	di "k_31 = " 2*invlogit(`m'[1,4])
	di "k_40 = " 2*invlogit(`m'[1,5])
	di "k_41 = " 2*invlogit(`m'[1,6])
	di "mu1 = " invlogit(`m'[1,7])
	di "mu2 = " invlogit(`m'[1,8])
	di "mu3 = " invlogit(`m'[1,9])
	di "mu4 = " invlogit(`m'[1,10])

end


*MLE
capture program drop astolfi
program define astolfi
	args lnf ///
		l_k_20 l_k_21 l_k_30 l_k_31 l_k_40 l_k_41  ///
		l_mu1 l_mu2 l_mu3 l_mu4  
		
	tempname count
	gen `count' = $ML_y1
	
	qui {
		*replace arguments with actual parameters
		local k_20 = 2*invlogit(`l_k_20')
		local k_21 = 2*invlogit(`l_k_21')
		local k_30 = 2*invlogit(`l_k_30')
		local k_31 = 2*invlogit(`l_k_31')
		local k_40 = 2*invlogit(`l_k_40')
		local k_41 = 2*invlogit(`l_k_41')
		local mu1 = invlogit(`l_mu1')
		local mu2 = invlogit(`l_mu2')
		local mu3 = invlogit(`l_mu3')
		local mu4 = invlogit(`l_mu4')
		
		*Determine the Q-term of LF for each sequence
		
		*Generate a list of all possible sequences (up to selected length)
		local l1 "B G" // start with a list of two one-sib "sequences": the B and the G.
		local length = 4 // <---------------------------------------------- select max sequence length here
		local seq_list `l1' // record the list of two one-sib "sequences" as a macro l1
		forval i=2/`length' { // for each value of length (excluding length=1, because one-sib "sequences" are already recorded in l1)...
			local j = `i'-1 // take a length of shorter sequence
			local l`i' "" // define a macro for list of sequences with length=i (e.g., l2 for a list of BB,BG,GB and GG)
			foreach e in `l`j'' { // take each element of existing list (e.g., the l1)
				local p1 "`e'B" // and add to it either B...
				local p2 "`e'G" // or G.
				local l`i' "`l`i'' `p1' `p2'" // construct the list l`i': each element of l`j' with added B, and same element with added G.
			}
			local seq_list "`seq_list' `l`i''" // add the list we just constructed to the "result" (a list of all sequences, with all lengths)
		}
		local n : word count `seq_list' // optional: check numer of sequence types in the final list

		*Loop over these sequences
		foreach s in `seq_list' { // for each sequence S from the list
			qui su n if sequence_first4=="`s'" & incomplete==0 // count number of occurenes (of complete sequence S)
			local N_`s' = r(sum)
			local N_star_`s' = 0 // create macro N*(S), it will be number of occurences of all sequences that start with S
			foreach t in `seq_list' { // find those sequences in the list...
				if "`s'" == substr("`t'",1,length("`s'")) { // ... which start with S
					qui su n if sequence_first4=="`t'" & incomplete==0 // count number of occurences of each such sequence (including the S itself)
					local N_star_`s' = `N_star_`s'' + r(sum) // add this number to macro N*(S)
					if length("`t'")==4 { // take into account the sequences longer than 4
						qui su n if sequence_first4=="`t'" & incomplete==1 // count number of occurences of each such sequence that start with S
						local N_star_`s' = `N_star_`s'' + r(sum) // add this number to N*(S)
					}
				}
			}
			local q_`s' = `N_`s''/`N_star_`s'' // calculates q(S)
			
			*calculate Q(S)
			local Q_`s' = `q_`s'' // start with last factor, q(S)
			local Q_inc_`s' = 1 - `q_`s	'' // if I'm dealing with incomplete family, the last factor q(S) is replaced with 1-q(S)
			local subseq_length = `length' - 1 // maximum length of subsequence of S
			forval i = 1/`subseq_length' { // loop over possible lengths of subsequences
				local subseq = substr("`s'",1,`i') // record the subsequence with given length
				local Q_`s' = `Q_`s'' * (1 - `q_`subseq'') // update Q(S) by multiplying on 1-q(subsequence)
				local Q_inc_`s' = `Q_inc_`s'' * (1 - `q_`subseq'') // update Q_incomplete(S) by multiplying on 1-q(subsequence)
			}
		}
		
	*LL function

	* for complete families the formulas are same as in Astolfi
	replace `lnf' = `count'*(ln(0+`mu1') + ln(`Q_B')) if sequence_first4=="B" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`mu1') + ln(`Q_G')) if sequence_first4=="G" & incomplete==0
	replace `lnf' = `count'*(ln(0+`k_20'*`mu2') + ln(`Q_BB')) if sequence_first4=="BB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_20'*`mu2') + ln(`Q_BG')) if sequence_first4=="BG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`mu2') + ln(`Q_GB')) if sequence_first4=="GB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_21'*`mu1'+(-1)*`mu1'+1*`k_21'*`mu2') + ln(`Q_GG')) if sequence_first4=="GG" & incomplete==0
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`mu3') + ln(`Q_BBB')) if sequence_first4=="BBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_30'*`mu3') + ln(`Q_BBG')) if sequence_first4=="BBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_20'*`k_31'*`mu3') + ln(`Q_BGB')) if sequence_first4=="BGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_31'*`mu2'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_31'*`mu3') + ln(`Q_BGG')) if sequence_first4=="BGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`mu3') + ln(`Q_GBB')) if sequence_first4=="GBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_30'*`mu3') + ln(`Q_GBG')) if sequence_first4=="GBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_21'*`k_31'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_21'*`k_31'*`mu3') + ln(`Q_GGB')) if sequence_first4=="GGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_31'*`mu1'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_31'*`mu2'+(-1)*`mu1'+1*`k_31'*`mu2'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_31'*`mu3') + ln(`Q_GGG')) if sequence_first4=="GGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_BBBB')) if sequence_first4=="BBBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_30'*`mu3'+(-1)*`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_BBBG')) if sequence_first4=="BBBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_BBGB')) if sequence_first4=="BBGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`mu3'+1*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_BBGG')) if sequence_first4=="BBGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_BGBB')) if sequence_first4=="BGBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`mu3'+1*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_BGBG')) if sequence_first4=="BGBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_BGGB')) if sequence_first4=="BGGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_41'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`mu3'+(-1)*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_BGGG')) if sequence_first4=="BGGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_GBBB')) if sequence_first4=="GBBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`mu3'+1*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_GBBG')) if sequence_first4=="GBBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_GBGB')) if sequence_first4=="GBGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`mu2'+1*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`mu3'+(-1)*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_GBGG')) if sequence_first4=="GBGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_GGBB')) if sequence_first4=="GGBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`mu2'+1*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`mu3'+(-1)*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_GGBG')) if sequence_first4=="GGBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu1'+(-1)*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`k_41'*`mu2'+1*`k_31'*`k_41'*`mu3'+1*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_GGGB')) if sequence_first4=="GGGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_41'*`mu1'+(-1)*`k_31'*`mu1'+1*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`mu2'+(-1)*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`mu1'+1*`k_41'*`mu2'+1*`k_31'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`mu3'+1*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_GGGG')) if sequence_first4=="GGGG" & incomplete==0


	* for incomplete families consider only first 4 sibs, and use factor Q_incomplete(S) instead of Q(S)
	replace `lnf' = `count'*(ln(0+`mu1') + ln(`Q_inc_B')) if sequence_first4=="B" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`mu1') + ln(`Q_inc_G')) if sequence_first4=="G" & incomplete==1
	replace `lnf' = `count'*(ln(0+`k_20'*`mu2') + ln(`Q_inc_BB')) if sequence_first4=="BB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_20'*`mu2') + ln(`Q_inc_BG')) if sequence_first4=="BG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`mu2') + ln(`Q_inc_GB')) if sequence_first4=="GB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_21'*`mu1'+(-1)*`mu1'+1*`k_21'*`mu2') + ln(`Q_inc_GG')) if sequence_first4=="GG" & incomplete==1
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`mu3') + ln(`Q_inc_BBB')) if sequence_first4=="BBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_30'*`mu3') + ln(`Q_inc_BBG')) if sequence_first4=="BBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_20'*`k_31'*`mu3') + ln(`Q_inc_BGB')) if sequence_first4=="BGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_31'*`mu2'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_31'*`mu3') + ln(`Q_inc_BGG')) if sequence_first4=="BGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`mu3') + ln(`Q_inc_GBB')) if sequence_first4=="GBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_30'*`mu3') + ln(`Q_inc_GBG')) if sequence_first4=="GBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_21'*`k_31'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_21'*`k_31'*`mu3') + ln(`Q_inc_GGB')) if sequence_first4=="GGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_31'*`mu1'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_31'*`mu2'+(-1)*`mu1'+1*`k_31'*`mu2'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_31'*`mu3') + ln(`Q_inc_GGG')) if sequence_first4=="GGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_BBBB')) if sequence_first4=="BBBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_30'*`mu3'+(-1)*`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_BBBG')) if sequence_first4=="BBBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_BBGB')) if sequence_first4=="BBGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`mu3'+1*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_BBGG')) if sequence_first4=="BBGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_BGBB')) if sequence_first4=="BGBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`mu3'+1*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_BGBG')) if sequence_first4=="BGBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_BGGB')) if sequence_first4=="BGGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_41'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`mu3'+(-1)*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_BGGG')) if sequence_first4=="BGGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_GBBB')) if sequence_first4=="GBBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`mu3'+1*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_GBBG')) if sequence_first4=="GBBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_GBGB')) if sequence_first4=="GBGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`mu2'+1*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`mu3'+(-1)*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_GBGG')) if sequence_first4=="GBGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_GGBB')) if sequence_first4=="GGBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`mu2'+1*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`mu3'+(-1)*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_GGBG')) if sequence_first4=="GGBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu1'+(-1)*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`k_41'*`mu2'+1*`k_31'*`k_41'*`mu3'+1*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_GGGB')) if sequence_first4=="GGGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_41'*`mu1'+(-1)*`k_31'*`mu1'+1*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`mu2'+(-1)*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`mu1'+1*`k_41'*`mu2'+1*`k_31'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`mu3'+1*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_GGGG')) if sequence_first4=="GGGG" & incomplete==1
	} // end of qui
end



*MLE: Modified program to exclude Lexian variation (by assuming that 2nd, 3rd and 4th central moments are zeros)
capture program drop astolfi2
program define astolfi2
	args lnf ///
		l_k_20 l_k_21 l_k_30 l_k_31 l_k_40 l_k_41  ///
		l_mu1 // <-----------------------------------------only one moment  
		
	tempname count
	gen `count' = $ML_y1
	
	qui {
		*replace arguments with actual parameters
		local k_20 = 2*invlogit(`l_k_20')
		local k_21 = 2*invlogit(`l_k_21')
		local k_30 = 2*invlogit(`l_k_30')
		local k_31 = 2*invlogit(`l_k_31')
		local k_40 = 2*invlogit(`l_k_40')
		local k_41 = 2*invlogit(`l_k_41')
		local mu1 = invlogit(`l_mu1')
			local mu2 = `mu1'^2 // <-- this is the key difference from -astolfi-
			local mu3 = `mu1'^3
			local mu4 = `mu1'^4
		
		*Determine the Q-term of LF for each sequence
		
		*Generate a list of all possible sequences (up to selected length)
		local l1 "B G" // start with a list of two one-sib "sequences": the B and the G.
		local length = 4 // <---------------------------------------------- select max sequence length here
		local seq_list `l1' // record the list of two one-sib "sequences" as a macro l1
		forval i=2/`length' { // for each value of length (excluding length=1, because one-sib "sequences" are already recorded in l1)...
			local j = `i'-1 // take a length of shorter sequence
			local l`i' "" // define a macro for list of sequences with length=i (e.g., l2 for a list of BB,BG,GB and GG)
			foreach e in `l`j'' { // take each element of existing list (e.g., the l1)
				local p1 "`e'B" // and add to it either B...
				local p2 "`e'G" // or G.
				local l`i' "`l`i'' `p1' `p2'" // construct the list l`i': each element of l`j' with added B, and same element with added G.
			}
			local seq_list "`seq_list' `l`i''" // add the list we just constructed to the "result" (a list of all sequences, with all lengths)
		}
		local n : word count `seq_list' // optional: check numer of sequence types in the final list

		*Loop over these sequences
		foreach s in `seq_list' { // for each sequence S from the list
			qui su n if sequence_first4=="`s'" & incomplete==0 // count number of occurenes (of complete sequence S)
			local N_`s' = r(sum)
			local N_star_`s' = 0 // create macro N*(S), it will be number of occurences of all sequences that start with S
			foreach t in `seq_list' { // find those sequences in the list...
				if "`s'" == substr("`t'",1,length("`s'")) { // ... which start with S
					qui su n if sequence_first4=="`t'" & incomplete==0 // count number of occurences of each such sequence (including the S itself)
					local N_star_`s' = `N_star_`s'' + r(sum) // add this number to macro N*(S)
					if length("`t'")==4 { // take into account the sequences longer than 4
						qui su n if sequence_first4=="`t'" & incomplete==1 // count number of occurences of each such sequence that start with S
						local N_star_`s' = `N_star_`s'' + r(sum) // add this number to N*(S)
					}
				}
			}
			local q_`s' = `N_`s''/`N_star_`s'' // calculates q(S)
			
			*calculate Q(S)
			local Q_`s' = `q_`s'' // start with last factor, q(S)
			local Q_inc_`s' = 1 - `q_`s	'' // if I'm dealing with incomplete family, the last factor q(S) is replaced with 1-q(S)
			local subseq_length = `length' - 1 // maximum length of subsequence of S
			forval i = 1/`subseq_length' { // loop over possible lengths of subsequences
				local subseq = substr("`s'",1,`i') // record the subsequence with given length
				local Q_`s' = `Q_`s'' * (1 - `q_`subseq'') // update Q(S) by multiplying on 1-q(subsequence)
				local Q_inc_`s' = `Q_inc_`s'' * (1 - `q_`subseq'') // update Q_incomplete(S) by multiplying on 1-q(subsequence)
			}
		}
		
	*LL function

	* for complete families the formulas are same as in Astolfi
	replace `lnf' = `count'*(ln(0+`mu1') + ln(`Q_B')) if sequence_first4=="B" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`mu1') + ln(`Q_G')) if sequence_first4=="G" & incomplete==0
	replace `lnf' = `count'*(ln(0+`k_20'*`mu2') + ln(`Q_BB')) if sequence_first4=="BB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_20'*`mu2') + ln(`Q_BG')) if sequence_first4=="BG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`mu2') + ln(`Q_GB')) if sequence_first4=="GB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_21'*`mu1'+(-1)*`mu1'+1*`k_21'*`mu2') + ln(`Q_GG')) if sequence_first4=="GG" & incomplete==0
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`mu3') + ln(`Q_BBB')) if sequence_first4=="BBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_30'*`mu3') + ln(`Q_BBG')) if sequence_first4=="BBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_20'*`k_31'*`mu3') + ln(`Q_BGB')) if sequence_first4=="BGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_31'*`mu2'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_31'*`mu3') + ln(`Q_BGG')) if sequence_first4=="BGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`mu3') + ln(`Q_GBB')) if sequence_first4=="GBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_30'*`mu3') + ln(`Q_GBG')) if sequence_first4=="GBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_21'*`k_31'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_21'*`k_31'*`mu3') + ln(`Q_GGB')) if sequence_first4=="GGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_31'*`mu1'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_31'*`mu2'+(-1)*`mu1'+1*`k_31'*`mu2'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_31'*`mu3') + ln(`Q_GGG')) if sequence_first4=="GGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_BBBB')) if sequence_first4=="BBBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_30'*`mu3'+(-1)*`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_BBBG')) if sequence_first4=="BBBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_BBGB')) if sequence_first4=="BBGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`mu3'+1*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_BBGG')) if sequence_first4=="BBGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_BGBB')) if sequence_first4=="BGBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`mu3'+1*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_BGBG')) if sequence_first4=="BGBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_BGGB')) if sequence_first4=="BGGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_41'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`mu3'+(-1)*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_BGGG')) if sequence_first4=="BGGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_GBBB')) if sequence_first4=="GBBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`mu3'+1*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_GBBG')) if sequence_first4=="GBBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_GBGB')) if sequence_first4=="GBGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`mu2'+1*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`mu3'+(-1)*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_GBGG')) if sequence_first4=="GBGG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_GGBB')) if sequence_first4=="GGBB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`mu2'+1*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`mu3'+(-1)*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_GGBG')) if sequence_first4=="GGBG" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu1'+(-1)*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`k_41'*`mu2'+1*`k_31'*`k_41'*`mu3'+1*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_GGGB')) if sequence_first4=="GGGB" & incomplete==0
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_41'*`mu1'+(-1)*`k_31'*`mu1'+1*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`mu2'+(-1)*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`mu1'+1*`k_41'*`mu2'+1*`k_31'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`mu3'+1*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_GGGG')) if sequence_first4=="GGGG" & incomplete==0


	* for incomplete families consider only first 4 sibs, and use factor Q_incomplete(S) instead of Q(S)
	replace `lnf' = `count'*(ln(0+`mu1') + ln(`Q_inc_B')) if sequence_first4=="B" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`mu1') + ln(`Q_inc_G')) if sequence_first4=="G" & incomplete==1
	replace `lnf' = `count'*(ln(0+`k_20'*`mu2') + ln(`Q_inc_BB')) if sequence_first4=="BB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_20'*`mu2') + ln(`Q_inc_BG')) if sequence_first4=="BG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`mu2') + ln(`Q_inc_GB')) if sequence_first4=="GB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_21'*`mu1'+(-1)*`mu1'+1*`k_21'*`mu2') + ln(`Q_inc_GG')) if sequence_first4=="GG" & incomplete==1
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`mu3') + ln(`Q_inc_BBB')) if sequence_first4=="BBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_30'*`mu3') + ln(`Q_inc_BBG')) if sequence_first4=="BBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_20'*`k_31'*`mu3') + ln(`Q_inc_BGB')) if sequence_first4=="BGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_31'*`mu2'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_31'*`mu3') + ln(`Q_inc_BGG')) if sequence_first4=="BGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`mu3') + ln(`Q_inc_GBB')) if sequence_first4=="GBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_30'*`mu3') + ln(`Q_inc_GBG')) if sequence_first4=="GBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_21'*`k_31'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_21'*`k_31'*`mu3') + ln(`Q_inc_GGB')) if sequence_first4=="GGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_31'*`mu1'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_31'*`mu2'+(-1)*`mu1'+1*`k_31'*`mu2'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_31'*`mu3') + ln(`Q_inc_GGG')) if sequence_first4=="GGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_BBBB')) if sequence_first4=="BBBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_30'*`mu3'+(-1)*`k_20'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_BBBG')) if sequence_first4=="BBBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_BBGB')) if sequence_first4=="BBGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_20'*`mu2'+(-1)*`k_20'*`k_41'*`mu3'+(-1)*`k_20'*`k_30'*`mu3'+1*`k_20'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_BBGG')) if sequence_first4=="BBGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_BGBB')) if sequence_first4=="BGBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu2'+(-1)*`k_31'*`k_40'*`mu3'+(-1)*`k_20'*`k_31'*`mu3'+1*`k_20'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_BGBG')) if sequence_first4=="BGBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_BGGB')) if sequence_first4=="BGGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`mu1'+(-1)*`k_41'*`mu2'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_41'*`mu3'+(-1)*`k_20'*`mu2'+1*`k_20'*`k_41'*`mu3'+1*`k_20'*`k_31'*`mu3'+(-1)*`k_20'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_BGGG')) if sequence_first4=="BGGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_GBBB')) if sequence_first4=="GBBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_30'*`mu2'+(-1)*`k_21'*`k_30'*`k_40'*`mu3'+(-1)*`k_21'*`k_30'*`mu3'+1*`k_21'*`k_30'*`k_40'*`mu4') + ln(`Q_inc_GBBG')) if sequence_first4=="GBBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_GBGB')) if sequence_first4=="GBGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_21'*`mu1'+(-1)*`k_21'*`k_41'*`mu2'+(-1)*`k_21'*`k_30'*`mu2'+1*`k_21'*`k_30'*`k_41'*`mu3'+(-1)*`k_21'*`mu2'+1*`k_21'*`k_41'*`mu3'+1*`k_21'*`k_30'*`mu3'+(-1)*`k_21'*`k_30'*`k_41'*`mu4') + ln(`Q_inc_GBGG')) if sequence_first4=="GBGG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_GGBB')) if sequence_first4=="GGBB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_31'*`mu1'+(-1)*`k_31'*`k_40'*`mu2'+(-1)*`k_21'*`k_31'*`mu2'+1*`k_21'*`k_31'*`k_40'*`mu3'+(-1)*`k_31'*`mu2'+1*`k_31'*`k_40'*`mu3'+1*`k_21'*`k_31'*`mu3'+(-1)*`k_21'*`k_31'*`k_40'*`mu4') + ln(`Q_inc_GGBG')) if sequence_first4=="GGBG" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*`k_41'*`mu1'+(-1)*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`k_41'*`mu2'+1*`k_31'*`k_41'*`mu3'+1*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_GGGB')) if sequence_first4=="GGGB" & incomplete==1
	replace `lnf' = `count'*(ln(0+1*1+(-1)*`k_41'*`mu1'+(-1)*`k_31'*`mu1'+1*`k_31'*`k_41'*`mu2'+(-1)*`k_21'*`mu1'+1*`k_21'*`k_41'*`mu2'+1*`k_21'*`k_31'*`mu2'+(-1)*`k_21'*`k_31'*`k_41'*`mu3'+(-1)*`mu1'+1*`k_41'*`mu2'+1*`k_31'*`mu2'+(-1)*`k_31'*`k_41'*`mu3'+1*`k_21'*`mu2'+(-1)*`k_21'*`k_41'*`mu3'+(-1)*`k_21'*`k_31'*`mu3'+1*`k_21'*`k_31'*`k_41'*`mu4') + ln(`Q_inc_GGGG')) if sequence_first4=="GGGG" & incomplete==1
	} // end of qui
end




*Constraints
*Constraints for Astolfi model 1 (exclude Markovian)
constraint 1  [l_k_20]_cons=[l_k_21]_cons
constraint 2  [l_k_30]_cons=[l_k_31]_cons
constraint 3  [l_k_40]_cons=[l_k_41]_cons
*Constraints for Astolfi model 2 (exclude Poisson)
constraint 11  [l_k_20]_cons=[l_k_30]_cons
constraint 12  [l_k_30]_cons=[l_k_40]_cons
constraint 13  [l_k_21]_cons=[l_k_31]_cons
constraint 14  [l_k_31]_cons=[l_k_41]_cons
*To implement model 3 use program -astolfi2- (excludes Lexian) with constraints 1-3 (exclude Markovian)


	
*Full model
ml model lf astolfi ///
	(l_k_20: n =  ) (l_k_21: )	(l_k_30: ) 	(l_k_31: ) 	(l_k_40: ) 	(l_k_41: ) ///
	(l_mu1: ) 	(l_mu2: ) 	(l_mu3: ) 	(l_mu4: ) ///
	, technique(bfgs  )  init(0 0 /**/ 0 0 /**/ 0 0  /**/ 0 -1.0986123 -1.9459101 -2.7080502 ,  copy) ///
	constraints()
ml maximize 
est sto full
display_estimates


*Model 1 (no Markovian)
ml model lf astolfi ///
	(l_k_20: n =  ) (l_k_21: )	(l_k_30: ) 	(l_k_31: ) 	(l_k_40: ) 	(l_k_41: ) ///
	(l_mu1: ) 	(l_mu2: ) 	(l_mu3: ) 	(l_mu4: ) ///
	, technique(bfgs  )  init(0 0 /**/ 0 0 /**/ 0 0  /**/ 0 -1.0986123 -1.9459101 -2.7080502 ,  copy) ///
	constraints(1-3)
ml maximize 
est sto model_1
display_estimates


*Model 2 (no Poisson)
ml model lf astolfi ///
	(l_k_20: n =  ) (l_k_21: )	(l_k_30: ) 	(l_k_31: ) 	(l_k_40: ) 	(l_k_41: ) ///
	(l_mu1: ) 	(l_mu2: ) 	(l_mu3: ) 	(l_mu4: ) ///
	, technique(bfgs  )  init(0 0 /**/ 0 0 /**/ 0 0  /**/ 0 -1.0986123 -1.9459101 -2.7080502 ,  copy) ///
	constraints(11-14)
ml maximize 
est sto model_2
display_estimates


*Model 3 (no Markovian, no Lexian)
ml model lf astolfi2 /// ! notice that the program is -astolfi2-
	(l_k_20: n =  ) (l_k_21: )	(l_k_30: ) 	(l_k_31: ) 	(l_k_40: ) 	(l_k_41: ) ///
	(l_mu1: ) 	///
	, technique(bfgs  )  init(0 0 /**/ 0 0 /**/ 0 0 /**/  0 ,  copy) ///
	constraints(1-3)
ml maximize 
est sto model_3
display_estimates


*Test restricted models against the full one
lrtest model_1 full // to test influence of Markovian	
lrtest model_2 full  // to test influence of Poisson
lrtest model_3 full // to test influence of Markovian and Lexian	
lrtest model_3 model_1 // to test influence of Lexian	

restore


*Calculate parameters of beta-distribution
* based on "2015-11-16 evaluation of beta-density parameters in DHS.do"
* Manually enter estimates of the moments from full model into new file "2015-11-16 evaluation of beta-density parameters in DHS.dta"
* var "moment" is the number of moment, from 1 to 4, "mu" is the estimate of that moment
use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-11-30 evaluation of beta-density parameters in DHS.dta", clear
nl (mu = (exp(lngamma({a}+1+moment)) * exp(lngamma({a}+1+{b}+1)) )/( exp(lngamma({a}+1+moment+{b}+1))  * exp(lngamma({a}+1)) ))
esttab
tempname m
mat `m' = r(coefs)
local a = `m'[1,1]
local b = `m'[2,1]
local alpha = `a'+1
local beta = `b'+1
local variance = `alpha'*`beta'/((`alpha'+`beta')^2 * (`alpha'+`beta'+1))
di "variance = " `variance'

timer off 52
timer off 50
 
  
 
 
*	6.	Effects of birth-to-birth interval on the correlation between sexes
timer on 60

*	6.1 Interaction between preceding sib's sex and BTB
timer on 61

use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\2015-10-19 merged DHS data for logit.dta", clear

logit dv iv1   /// 
	if child_number!=length  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)
	
logit dv iv1 interval_iv1  /// 
	if child_number!=length  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)	
	
logit dv c.iv1##c.interval_iv1  /// 
	if child_number!=length  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)		
	
logit dv iv1   /// 
	if child_number==length  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)
	
logit dv iv1 interval_iv1  /// 
	if child_number==length  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)	
	
logit dv c.iv1##c.interval_iv1  /// 
	if child_number==length  ///
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
	& interval_iv1>9 ///
	, technique(bfgs)		

*Estimate the size of effect of BTB interval in percents
di invlogit(-.072913+0.0004)- invlogit(-.072913) // see the models above. coef(BTB)=0.0004

timer off 61




*	6.2	Logit by BTB, excluding last child
* based on "2015-10-10 logit by interval _merged file.do"
timer on 62

*Define a program for logit
capture program drop logit_regression
program define logit_regression, rclass
	args interval_arg // interval_arg is value of BTB interval (months)
	qui {
		logit dv iv1 ///
			if child_number!=length  /// exclude last children
			& v201==length /// reported number of children is consistent with value of v201
			& mult_birth==0  /// not twin
			& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
			& interval_iv1>9 ///
			& interval_iv1==`interval_arg' ///
			, technique(bfgs)		
		esttab, ci
		tempname b
		mat `b' = r(coefs)
		*order of display: coef, lowci, highci, p-value, N 
	} // end of -qui-
	di "`interval_arg'" char(9) `b'[1,1] char(9) `b'[1,2] char(9) `b'[1,3] char(9) e(N)
	return scalar coef = `b'[1,1]
	return scalar lowci = `b'[1,2]
	return scalar highci = `b'[1,3]
	return scalar n = e(N)
end

*Prepare temp vars for results by interval
tempname interval coef lowci highci n 
gen `interval' = .
gen `coef' = .
gen `lowci' = .
gen `highci' = .
gen `n' = .

*Loop over values of interval
local interval_start = 10
local interval_end = 70
local interval_range = `interval_end' - `interval_start'
di "Header: coef, -95% CI, +95% CI, p, N"
forval interval_i = `interval_start'/`interval_end' { 
	logit_regression `interval_i' 
	qui {
			local row = `interval_i' - `interval_start' + 1
			replace `interval' = `interval_i' in `row'
			replace `coef' = r(coef) in `row'
			replace `lowci' = r(lowci) in `row'
			replace `highci' = r(highci) in `row'
			replace `n' = r(n) in `row'
	} // end of -qui-
}

*Plot results 
tw ///
	(bar `n' `interval', fcolor(blue*0.2) lcolor(blue*0.2) base(0) yaxis(2)) ///
	(line `lowci' `interval', lcolor(red)) ///
	(line `highci' `interval', lcolor(red)) ///
	(line `coef' `interval', lcolor(red) lwidth(thick)) ///
	(function zero=0, range(`interval_start' `interval_end') lcolor(black)) ///
	in 1/`interval_range' ///
	, legend(order(3 2 1) label(1 "Distribution of sample sizes") label(2 "95%CI") label(3 "Coefficient") rows(2) region(lcolor(white))) /// 
	graphregion(color(white)) ///
	xlabel(`interval_start'(5)`interval_end') ///
	ylabel(-0.2(0.1)0.3) ///
	xtitle("Birth-to-birth interval, months") ///
	ytitle("Sample size", axis(2)) ///
	ytitle("Coefficient") ///
	ylabel(,nogrid) 
graph export "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\Figure 1.pdf", replace
timer off 62




*	6.3	Logit by BTB, only last children
* based on "2015-10-10 logit by interval _merged file.do"
timer on 63

*Define a program for logit
capture program drop logit_regression
program define logit_regression, rclass
	args interval_arg // interval_arg is value of BTB interval (months)
	qui {
		logit dv iv1 ///
			if child_number==length  /// LIMIT TO last children <-- !!!!!!!!!!!!!!!!!!!!
			& v201==length /// reported number of children is consistent with value of v201
			& mult_birth==0  /// not twin
			& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. )  /// previous sib is not twin
			& interval_iv1>9 ///
			& interval_iv1==`interval_arg' ///
			, technique(bfgs)		
		esttab, ci
		tempname b
		mat `b' = r(coefs)
		*order of display: coef, lowci, highci, p-value, N 
	} // end of -qui-
	di "`interval_arg'" char(9) `b'[1,1] char(9) `b'[1,2] char(9) `b'[1,3] char(9) e(N)
	return scalar coef = `b'[1,1]
	return scalar lowci = `b'[1,2]
	return scalar highci = `b'[1,3]
	return scalar n = e(N)
end

*Prepare temp vars for results by interval
tempname interval coef lowci highci n 
gen `interval' = .
gen `coef' = .
gen `lowci' = .
gen `highci' = .
gen `n' = .

*Loop over values of interval
local interval_start = 10
local interval_end = 70
local interval_range = `interval_end' - `interval_start'
di "Header: coef, -95% CI, +95% CI, p, N"
forval interval_i = `interval_start'/`interval_end' { 
	logit_regression `interval_i' 
	qui {
			local row = `interval_i' - `interval_start' + 1
			replace `interval' = `interval_i' in `row'
			replace `coef' = r(coef) in `row'
			replace `lowci' = r(lowci) in `row'
			replace `highci' = r(highci) in `row'
			replace `n' = r(n) in `row'
	} // end of -qui-
}

*Plot results 
tw ///
	(bar `n' `interval', fcolor(blue*0.2) lcolor(blue*0.2) base(0) yaxis(2)) ///
	(line `lowci' `interval', lcolor(red)) ///
	(line `highci' `interval', lcolor(red)) ///
	(line `coef' `interval', lcolor(red) lwidth(thick)) ///
	(function zero=0, range(`interval_start' `interval_end') lcolor(black)) ///
	in 1/`interval_range' ///
	, legend(order(3 2 1) label(1 "Distribution of sample sizes") label(2 "95%CI") label(3 "Coefficient") rows(2) region(lcolor(white))) /// 
	graphregion(color(white)) ///
	xlabel(`interval_start'(5)`interval_end') ///
	ylabel(-0.3(0.1)0.1) /// here the range of coef values is different from the range for the previous graph (where last children were excluded)
	xtitle("Birth-to-birth interval, months") ///
	ytitle("Sample size", axis(2)) ///
	ytitle("Coefficient") ///
	ylabel(,nogrid) 
graph export "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\Figure 2.pdf", replace

timer off 63




*	6.4	BTB between same-sex and opposite sex pairs
* based on "2015-10-23 regression of btb-intervals _by n and i.do"
*assuming that the file "2015-10-19 merged DHS data for logit.dta" is already open.
timer on 64

tempname p
gen `p' = .
	replace `p' = 1 if dv == iv1 & dv!=.
	replace `p' = 0 if dv != iv1 & dv!=. & iv1!=.
	
reg interval_iv1 `p' /// 
	if child_number!=length  /// not last / last child
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. ) /// previous sib is not twin
	& interval_iv1>9  


* Results of nonparametric rank sum test 
* (based on "2015-10-18 compare BTB intervals for like and unlike sex successions.do")

*Define groups with like and unlike sex succession
local condition "child_number!=."
tempname group
gen byte `group' = .
replace `group' = 0 if dv!=iv1   /// opposite sex succession
	& `condition'  /// not last / last child
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. ) ///
	& interval_iv1>9
replace `group' = 1 if dv==iv1   /// same-sex succession
	& `condition'  /// not last / last child
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. ) ///
	& interval_iv1>9

ranksum interval_iv1, by(`group') // non-parameric test




 *BTB interval between same sex births and between opposite sex births, controlling for sibship size and birth order
* based on "2015-10-23 regression of btb-intervals _by n and i.do"

tempname p
gen `p' = .
	replace `p' = 1 if dv == iv1 & dv!=.
	replace `p' = 0 if dv != iv1 & dv!=. & iv1!=.
*tab `p' dv
*tab `p' iv1
	
reg interval_iv1 `p' length child_number /// 
	if child_number!=length  /// not last / last child
	& v201==length /// reported number of children is consistent with value of v201
	& mult_birth==0  /// not twin
	& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. ) /// previous sib is not twin
	& interval_iv1>9  

timer off 64




*	6.5	BTB between same-sex and opposite sex pairs, repeat by n and i
* based on "2015-10-23 regression of btb-intervals _by n and i.do"
timer on 65

tempname p
gen `p' = .
	replace `p' = 1 if dv == iv1 & dv!=.
	replace `p' = 0 if dv != iv1 & dv!=. & iv1!=.
	
*repeat for different values of length and birth order	
di "Header: n, i, coef, p, N"
forval n=1/10 {
	forval i=2/`=`n'-1' {
		qui {
			reg interval_iv1 `p' /// 
				if child_number!=length  /// not last / last child
				& v201==length /// reported number of children is consistent with value of v201
				& mult_birth==0  /// not twin
				& (prev_mult_birth_iv1==0 | prev_mult_birth_iv1==. ) /// previous sib is not twin
				& interval_iv1>9 ///
				& length==`n' & child_number==`i'
			esttab
			tempname m
			mat `m'=r(coefs)
		} // end of qui		
		di "`n'" char(9) "`i'" char(9) `m'[1,1] char(9) `m'[1,3] char(9) e(N)
	}
}	

timer off 65
timer off 60




*	7.	Additional datasets  
* Logistic regressions of child's sex on preceding siblings¡¯ sex in datasets from published papers
timer on 70

/* 7.1	Renkonen
1. Locate source data in Edwards 1962, Table 3
2. Create new table in excel:
	sequence	n	var1	var2	var3	var4	var5
	BB	4400	0	0	-1	-1	-1
	BG	4270	0	1	-1	-1	-1
	GB	4633	1	0	-1	-1	-1
	...
	GGGBG	461	1	1	1	0	1
	GGGGB	488	1	1	1	1	0
	GGGGG	518	1	1	1	1	1
var1 equals 0 if first letter in the sequence is "B", and 1 if it is "G", and so on.
3. Save as Stata file
"E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Renkonen _as in Edwards 1962.dta"
4. Process using the code below
*/

* based on "2015-10-17 prepare Renkonen-Edwards data for logit.do"
use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Renkonen _as in Edwards 1962.dta", clear

qui {
	rename sequence sequence_original

	*gen new vars - should be 20 in total
	forval i=6/20 { // starting number depends on how many vars are already present in the file. In Renkonen/Edwards file there are five.
		gen var`i' =.
	}

	forval i=1/20 {
		replace var`i' = . if var`i' ==-1 // change missing values to . 
		gen iv`i' = . // independent variables for logit (sexes of previous sibs, if any)
	}
	
	gen dv = . // Dependent varirable for logit
	gen sequence = "" // generate birth sequences (BBGG etc)
	expand n // should be one obs per offspring
	gen woman = _n // give serial number to each woman
			
	*Copy sibs' sexes from variables b4* to variables var1-var20; create birth sequence as BGBB...
	forval i=1/20 { // some datasets have less than 20 b4* variables. 
		gen seq`i' = ""
		replace seq`i' = "B" if var`i' == 0
		replace seq`i' = "G" if var`i' == 1
		replace sequence = sequence + seq`i'
		drop seq`i'
	}
	drop if sequence == ""
	gen length = length(sequence) // record offspring size
	
	*Expand dataset (each offspring is represented by N rows, where N is the size of this offspring)
	expand length 
	sort woman
	by woman: gen child_number = _n // count number of children of each woman. This var will correspond to birth order.
	gen child_index = length - child_number + 1 // this var will correspond to birth index (reverse of birth order)
	

	*Record values of dependent, independent variables and covariates
	forval i = 1/20 { // `i' would be child_index of "dep var" child. Counting in forward order (unlike in DHS data where I count in reverse order, because higher child_index in DHS corresponds to earlier birth).
		capture replace dv = var`i' if child_number==`i' // here I used "child_number", unlike in DHS data where "child_index" should be used (due to reversal of order)
		
		forval k=1/19 { // `k' is number of IV (the difference in birth order between "dependent" and "independent" sibs). 
		*Eg, if k=1 and i=2, then independent variable is iv1 - the sex of sib with child_number==1 (that is, previous child).
			local j`k' = `i' - `k' // number of preceeding ("indep var") child (if any). 
			capture replace iv`k' = var`j`k'' if child_number==`i' /* record value of independent var: it would be value of var* that 
																	differs from `i' by `k' units.*/
		}
	}

	order woman sequence length child_number child_index  dv iv* var* , first
	sort woman child_number
} // end of qui

save "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Renkonen _as in Edwards 1962 _converted 2015-10-17.dta", replace

*Logit in Renkonen's data
logit dv iv1
logit dv iv1 if child_number!=length
logit dv iv1 if child_number==length
logit dv iv1 if  length<5
logit dv iv1 if child_number!=length & length<5
logit dv iv1 if child_number==length & length<5





/* 7.2	Greenberg and White 
1. Locate source data in Greenberg and White 1967, Tables 2 and 3 in the Appendix
2. Create new table in excel:
		sequence	n
		BB	4862
		BG	4854
		GB	5133
		...
		GGBGGGG	250
		GGGBGGG	220
		GGGGGGG	247
3. Save as Stata file
"E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Greenberg.dta"
4. Process using the code below
*/

*based on "2015-10-23 prepare Greenberg data for logit.do"
use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Greenberg.dta", clear

qui {
	rename sequence sequence_original

	*gen new vars - should be 20 in total
	forval i=1/20 { // 
		gen var`i' =.
		replace var`i'=0 if substr(sequence_original,`i',1)=="B"
		replace var`i'=1 if substr(sequence_original,`i',1)=="G"
		gen iv`i' = . // independent variables for logit (sexes of previous sibs, if any)

	}

	gen dv = . // Dependent varirable for logit
	gen sequence = "" // generate birth sequences (BBGG etc)
	expand n // should be one obs per offspring
	gen woman = _n // give serial number to each woman
			
	*Copy sibs' sexes from variables b4* to variables var1-var20; create birth sequence as BGBB...
	forval i=1/20 { // some datasets have less than 20 b4* variables. 
		gen seq`i' = ""
		replace seq`i' = "B" if var`i' == 0
		replace seq`i' = "G" if var`i' == 1
		replace sequence = sequence + seq`i'
		drop seq`i'
	}
	drop if sequence == ""
	gen length = length(sequence) // record offspring size
	
	*Expand dataset (each offspring is represented by N rows, where N is the size of this offspring)
	expand length 
	sort woman
	by woman: gen child_number = _n // count number of children of each woman. This var will correspond to birth order.
	gen child_index = length - child_number + 1 // this var will correspond to birth index (reverse of birth order)
	

	*Record values of dependent, independent variables and covariates
	forval i = 1/20 { // `i' would be child_index of "dep var" child. Counting in forward order (unlike in DHS data where I count in reverse order, because higher child_index in DHS corresponds to earlier birth).
		capture replace dv = var`i' if child_number==`i' // here I used "child_number", unlike in DHS data where "child_index" should be used (due to reversal of order)
		
		forval k=1/19 { // `k' is number of IV (the difference in birth order between "dependent" and "independent" sibs). 
		*Eg, if k=1 and i=2, then independent variable is iv1 - the sex of sib with child_number==1 (that is, previous child).
			local j`k' = `i' - `k' // number of preceeding ("indep var") child (if any). 
			capture replace iv`k' = var`j`k'' if child_number==`i' /* record value of independent var: it would be value of var* that 
																	differs from `i' by `k' units.*/
		}
	}

	order woman sequence length child_number child_index  dv iv* var* , first
	sort woman child_number
} // end of qui

save "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Greenberg _converted.dta", replace

*Logit
logit dv iv1 if child_index!=.
logit dv iv1 if child_index!=1 // not last
logit dv iv1 if child_index==1 // last or 7th

logit dv iv1 if child_index!=. & length<7
logit dv iv1 if child_index!=1 & length<7 // not last
logit dv iv1 if child_index==1 & length<7 // last or 7th




/* 7.3	Maconochie and Roman 1997 
1. Locate source data in Maconochie and Roman 1997, Figure 1
2. Create new table in excel:
	sequence	n
	B	81016
	G	77203
	BB	33354
	...
	GGBG	341
	GGGB	514
	GGGG	434
3. Save as Stata file
"E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Maconochie _short.dta"
4. Process using the code below
*/

use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Maconochie _short.dta", clear

qui {
	rename sequence sequence_original
	capture drop var* length
	
	*gen new vars - should be 20 in total
	forval i=1/20 { // 
		gen var`i' =.
		replace var`i'=0 if substr(sequence_original,`i',1)=="B"
		replace var`i'=1 if substr(sequence_original,`i',1)=="G"
		gen iv`i' = . // independent variables for logit (sexes of previous sibs, if any)
	}

	gen dv = . // Dependent varirable for logit
	gen sequence = "" // generate birth sequences (BBGG etc)
	expand n // should be one obs per offspring
	gen woman = _n // give serial number to each woman
			
	*Copy sibs' sexes from variables b4* to variables var1-var20; create birth sequence as BGBB...
	forval i=1/20 { // some datasets have less than 20 b4* variables. 
		gen seq`i' = ""
		replace seq`i' = "B" if var`i' == 0
		replace seq`i' = "G" if var`i' == 1
		replace sequence = sequence + seq`i'
		drop seq`i'
	}
	drop if sequence == ""
	gen length = length(sequence) // record offspring size
	
	*Expand dataset (each offspring is represented by N rows, where N is the size of this offspring)
	expand length 
	sort woman
	by woman: gen child_number = _n // count number of children of each woman. This var will correspond to birth order.
	gen child_index = length - child_number + 1 // this var will correspond to birth index (reverse of birth order)
	

	*Record values of dependent, independent variables and covariates
	forval i = 1/20 { // `i' would be child_index of "dep var" child. Counting in forward order (unlike in DHS data where I count in reverse order, because higher child_index in DHS corresponds to earlier birth).
		capture replace dv = var`i' if child_number==`i' // here I used "child_number", unlike in DHS data where "child_index" should be used (due to reversal of order)
		
		forval k=1/19 { // `k' is number of IV (the difference in birth order between "dependent" and "independent" sibs). 
		*Eg, if k=1 and i=2, then independent variable is iv1 - the sex of sib with child_number==1 (that is, previous child).
			local j`k' = `i' - `k' // number of preceeding ("indep var") child (if any). 
			capture replace iv`k' = var`j`k'' if child_number==`i' /* record value of independent var: it would be value of var* that 
																	differs from `i' by `k' units.*/
		}
	}

	order woman sequence length child_number child_index  dv iv* var* , first
	sort woman child_number
} // end of qui

save "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Maconochie _converted 2015-11-21.dta", replace

*Logit
logit dv iv1 if child_index!=.
logit dv iv1 if child_index!=1 // 
logit dv iv1 if child_index==1 // 







/* 7.4	Jacobsen, Moller et al. 1999
1. Locate source data in Jacobsen, Moller et al. 1999, Table V. Notice that the sequences are not families, they are succession within the families
For example, The numbers shown next to BBB and BBG must be summed up and subtracted from the number for BB, then we got real number of Boy-Boy-X sibships).
2. Create new table in excel:
sequence	length	n
sequence	n
	BB	10415
	BG	8117
	GB	8026
	GG	8641
	BBB	842
	BBG	619
	BGB	622
	BGG	598
	GBB	628
	GBG	604
	GGB	604
	GGG	762
3. Save as Stata file
"E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Jacobsen 1999 _short 2015-11-21.dta"
4. Process using the code below
*/

use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Jacobsen 1999 _short 2015-11-21.dta", clear

qui {
	rename sequence sequence_original
	capture drop var* length
	
	*gen new vars - should be 20 in total
	forval i=1/20 { // 
		gen var`i' =.
		replace var`i'=0 if substr(sequence_original,`i',1)=="B"
		replace var`i'=1 if substr(sequence_original,`i',1)=="G"
		gen iv`i' = . // independent variables for logit (sexes of previous sibs, if any)
	}

	gen dv = . // Dependent varirable for logit
	gen sequence = "" // generate birth sequences (BBGG etc)
	expand n // should be one obs per offspring
	gen woman = _n // give serial number to each woman
			
	*Copy sibs' sexes from variables b4* to variables var1-var20; create birth sequence as BGBB...
	forval i=1/20 { // some datasets have less than 20 b4* variables. 
		gen seq`i' = ""
		replace seq`i' = "B" if var`i' == 0
		replace seq`i' = "G" if var`i' == 1
		replace sequence = sequence + seq`i'
		drop seq`i'
	}
	drop if sequence == ""
	gen length = length(sequence) // record offspring size
	
	*Expand dataset (each offspring is represented by N rows, where N is the size of this offspring)
	expand length 
	sort woman
	by woman: gen child_number = _n // count number of children of each woman. This var will correspond to birth order.
	gen child_index = length - child_number + 1 // this var will correspond to birth index (reverse of birth order)
	

	*Record values of dependent, independent variables and covariates
	forval i = 1/20 { // `i' would be child_index of "dep var" child. Counting in forward order (unlike in DHS data where I count in reverse order, because higher child_index in DHS corresponds to earlier birth).
		capture replace dv = var`i' if child_number==`i' // here I used "child_number", unlike in DHS data where "child_index" should be used (due to reversal of order)
		
		forval k=1/19 { // `k' is number of IV (the difference in birth order between "dependent" and "independent" sibs). 
		*Eg, if k=1 and i=2, then independent variable is iv1 - the sex of sib with child_number==1 (that is, previous child).
			local j`k' = `i' - `k' // number of preceeding ("indep var") child (if any). 
			capture replace iv`k' = var`j`k'' if child_number==`i' /* record value of independent var: it would be value of var* that 
																	differs from `i' by `k' units.*/
		}
	}

	order woman sequence length child_number child_index  dv iv* var* , first
	sort woman child_number
} // end of qui

save "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Jacobsen 1999 _short _converted 2015-11-21.dta", replace

*Logit
logit dv iv1  /* only the model excluding last children, because the Table V from Jacobsen already excludes last children*/




/* 7.5	(Rodgers and Doughty 2001)
1. Locate source data in (Rodgers and Doughty 2001), Table 2.
2. Create new table in excel:
	sequence	n
	B	930
	G	951
	BB	582
	...
	GGBG	28
	GGGG	26
3. Save as Stata file
"E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Rodgers 2001 Table 2 _short.dta"
4. Process using the code below
*/


use "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Rodgers 2001 Table 2 _short.dta", clear

qui {
	rename sequence sequence_original
	capture drop var* length
	
	*gen new vars - should be 20 in total
	forval i=1/20 { // 
		gen var`i' =.
		replace var`i'=0 if substr(sequence_original,`i',1)=="B"
		replace var`i'=1 if substr(sequence_original,`i',1)=="G"
		gen iv`i' = . // independent variables for logit (sexes of previous sibs, if any)
	}

	gen dv = . // Dependent varirable for logit
	gen sequence = "" // generate birth sequences (BBGG etc)
	expand n // should be one obs per offspring
	gen woman = _n // give serial number to each woman
			
	*Copy sibs' sexes from variables b4* to variables var1-var20; create birth sequence as BGBB...
	forval i=1/20 { // some datasets have less than 20 b4* variables. 
		gen seq`i' = ""
		replace seq`i' = "B" if var`i' == 0
		replace seq`i' = "G" if var`i' == 1
		replace sequence = sequence + seq`i'
		drop seq`i'
	}
	drop if sequence == ""
	gen length = length(sequence) // record offspring size
	
	*Expand dataset (each offspring is represented by N rows, where N is the size of this offspring)
	expand length 
	sort woman
	by woman: gen child_number = _n // count number of children of each woman. This var will correspond to birth order.
	gen child_index = length - child_number + 1 // this var will correspond to birth index (reverse of birth order)
	

	*Record values of dependent, independent variables and covariates
	forval i = 1/20 { // `i' would be child_index of "dep var" child. Counting in forward order (unlike in DHS data where I count in reverse order, because higher child_index in DHS corresponds to earlier birth).
		capture replace dv = var`i' if child_number==`i' // here I used "child_number", unlike in DHS data where "child_index" should be used (due to reversal of order)
		
		forval k=1/19 { // `k' is number of IV (the difference in birth order between "dependent" and "independent" sibs). 
		*Eg, if k=1 and i=2, then independent variable is iv1 - the sex of sib with child_number==1 (that is, previous child).
			local j`k' = `i' - `k' // number of preceeding ("indep var") child (if any). 
			capture replace iv`k' = var`j`k'' if child_number==`i' /* record value of independent var: it would be value of var* that 
																	differs from `i' by `k' units.*/
		}
	}

	order woman sequence length child_number child_index  dv iv* var* , first
	sort woman child_number
} // end of qui

save "E:\! review and public data projects\heritability of sex ratio and other influences on sex ratio\data from Rodgers 2001 Table 2 _converted 2015-11-21.dta", replace

*Logit
logit dv iv1  
logit dv iv1 if child_number!=length
logit dv iv1 if child_number==length

logit dv iv1  if length<4
logit dv iv1 if child_number!=length & length<4
logit dv iv1 if child_number==length & length<4

timer off 70
timer off 1

*Show time spent on each step
timer list 1
timer list 10
timer list 11
timer list 12
timer list 20
timer list 30
timer list 31
timer list 32
timer list 40
timer list 41
timer list 42
timer list 43
timer list 44
timer list 45
timer list 46
timer list 47
timer list 50
timer list 51
timer list 52
timer list 60
timer list 61
timer list 62
timer list 63
timer list 64
timer list 65
timer list 70

log close
