## Research Question
Did Janani Suraksha Yojana (JSY) high-focus states experience a larger 
increase in institutional delivery rates between NFHS-3 and NFHS-4 
compared to other states?

## Data
Source: Ministry of Health & Family Welfare — All India and State/UT-wise 
Key Indicators, NFHS-3 and NFHS-4  
Outcome: Institutional births (%) — state-level, Total population  
Panel: 28 states × 2 rounds = 56 observations (balanced)

## Treatment Definition
JSY (Janani Suraksha Yojana) designated 10 high-focus states for intensified 
support. Although 10 states were originally designated, only 8 remained in 
the balanced panel after filtering for states present in both NFHS rounds — 
2 states were dropped due to missing NFHS-3 data. All results use this 
8-state treated group.

JSY high-focus states in final sample: Assam, Bihar, Chhattisgarh, 
Jharkhand, Madhya Pradesh, Odisha, Rajasthan, Uttar Pradesh

## Methods
- Descriptive statistics by treatment group
- Basic DiD: outcome ~ treated + post + treated × post
- Two-Way Fixed Effects DiD: state and round fixed effects (preferred spec)
- Standard errors clustered at state level (28 clusters)
- Robustness check: excluding northeastern states (N=40)
- Pre/post group mean comparison plot

## Key Findings
JSY high-focus states experienced an estimated 18.9 percentage point larger 
increase in institutional delivery rates between NFHS-3 and NFHS-4 compared 
to other states (p<0.001). This finding is robust to excluding northeastern 
states (18.2 pp, p<0.01). Results are consistent with JSY's targeted design 
to accelerate facility-based deliveries in lagging states, though causal 
interpretation requires caution (see Limitations).

## Identification Assumption
The DiD estimate assumes that, absent JSY, treated and control states would 
have experienced similar trends in institutional deliveries. This assumption 
cannot be verified with only one pre-treatment period. JSY states may have 
already been catching up faster, receiving more health funding, or 
experiencing broader maternal health reforms before or alongside JSY — 
any of which would bias the estimate upward.

## Limitations
1. Only two time points — parallel trends cannot be formally tested
2. 10-year gap between rounds (NFHS-3 to NFHS-4) — concurrent programmes 
   (NRHM, ASHA scale-up, RCH-II, infrastructure expansion) rolled out 
   simultaneously. The estimate is better interpreted as the combined effect 
   of JSY-era maternal health expansion rather than a clean JSY effect.
3. Treatment non-randomly assigned — JSY targeted states with lowest 
   baseline rates, creating selection concerns
4. State-level data only — cannot account for within-state heterogeneity
5. 28 clusters — clustered SEs may be unstable; wild bootstrap would 
   be more appropriate but is beyond scope here

## Language Note
All findings use associative language ("consistent with", "estimated 
differential increase") rather than causal claims, given the 
quasi-experimental design and data limitations.

## Requirements
R 4.5+  
Packages: readxl, tidyverse, fixest, modelsummary, gtsummary