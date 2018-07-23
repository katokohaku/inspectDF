# inspectDF
Satoshi Kato (@katokohaku)


## Overview

R package for getting inspected rules as data.frame.

#### How to use

Just use `inspectDF()` instead of `arules::inspect()` after doing `arules::apriori()`.


```r
require(dplyr)
require(arules)
require(inspectDF)

data(Groceries)
params <- list(confidence=0.001, support=0.001, maxlen=7, minlen=2)
glo.apriori <- apriori(Groceries, parameter = params, control = list(verbose=FALSE))
print(glo.apriori)
#> set of 40943 rules

glo.inspectDF  <- inspectDF(glo.apriori)
glo.inspectDF %>% str
#> 'data.frame':	40943 obs. of  8 variables:
#>  $ rule      : chr  "Rule 1" "Rule 2" "Rule 3" "Rule 4" ...
#>  $ LHS       : chr  "whole milk" "other vegetables" "other vegetables" "rolls/buns" ...
#>  $ RHS       : chr  "sparkling wine" "artif. sweetener" "bathroom cleaner" "nuts/prunes" ...
#>  $ n         : num  1 1 1 1 1 1 1 1 1 1 ...
#>  $ support   : num  0.00102 0.00102 0.00102 0.00102 0.00102 ...
#>  $ confidence: num  0.00398 0.00525 0.00525 0.00553 0.00583 ...
#>  $ lift      : num  0.712 1.615 1.914 1.647 1.024 ...
#>  $ count     : num  10 10 10 10 10 10 10 10 10 10 ...
```

**InspectDF** also provides a plot.igraph wrapper utility.


```r
set.seed(0)
glo.inspectDF %>% 
  arrange(support, confidence) %>%
  head(60) %>% 
  plotRuleGraph()
```

![](README_files/figure-html/example.plot-1.png)<!-- -->

***

### Detail

#### Installation

You can install the **inspectDF** package from [GitHub](https://github.com/katokohaku/inspectDF).


```r
install.packages("devtools") # if you have not installed "devtools" package
devtools::install_github("katokohaku/inspectDF")
```

The source code for **inspectDF** package is available at

- https://github.com/katokohaku/inspectDF.

#### Motivation

Usually, we do `inspect()` to enumrate rules after `arules::apriori()`.

Of cource, we could get data.frame object as side effect of `cat()` on the last line in `inspect()`. However, it can't be done quietly (*Always show all on consol*). It is noisy when especially `inspect()` a lot of rules or calling in other function.

(**Don't run following codes with many rules**)

```r
glo.inspect  <- glo.apriori %>% head(10) %>% inspect()
#>      lhs               rhs            support     confidence  lift    
#> [1]  {honey}        => {whole milk}   0.001118454 0.733333333 2.870009
#> [2]  {whole milk}   => {honey}        0.001118454 0.004377238 2.870009
#> [3]  {soap}         => {whole milk}   0.001118454 0.423076923 1.655775
#> [4]  {whole milk}   => {soap}         0.001118454 0.004377238 1.655775
#> [5]  {tidbits}      => {soda}         0.001016777 0.434782609 2.493345
#> [6]  {soda}         => {tidbits}      0.001016777 0.005830904 2.493345
#> [7]  {tidbits}      => {rolls/buns}   0.001220132 0.521739130 2.836542
#> [8]  {rolls/buns}   => {tidbits}      0.001220132 0.006633499 2.836542
#> [9]  {cocoa drinks} => {whole milk}   0.001321810 0.590909091 2.312611
#> [10] {whole milk}   => {cocoa drinks} 0.001321810 0.005173100 2.312611
#>      count
#> [1]  11   
#> [2]  11   
#> [3]  11   
#> [4]  11   
#> [5]  10   
#> [6]  10   
#> [7]  12   
#> [8]  12   
#> [9]  13   
#> [10] 13
glo.inspect %>% str
#> 'data.frame':	10 obs. of  7 variables:
#>  $ lhs       : Factor w/ 7 levels "{cocoa drinks}",..: 2 7 4 7 6 5 6 3 1 7
#>  $           : Factor w/ 1 level "=>": 1 1 1 1 1 1 1 1 1 1
#>  $ rhs       : Factor w/ 7 levels "{cocoa drinks}",..: 7 2 7 4 5 6 3 6 7 1
#>  $ support   : num  0.00112 0.00112 0.00112 0.00112 0.00102 ...
#>  $ confidence: num  0.73333 0.00438 0.42308 0.00438 0.43478 ...
#>  $ lift      : num  2.87 2.87 1.66 1.66 2.49 ...
#>  $ count     : num  11 11 11 11 10 10 12 12 13 13
```

Therefore, this must be done invisibly.

#### Use case

Arules package privides several utilities such as sort(), subset() and etc. But if rules were provided as data.frame, we can explore them as tidy data. **InspectDF** has a good affinity with tidy schemes, such as `dplyr::arrange()` or `dplyr::filter()` because this returns **only** data.frame.

For example, rules with specific item(s) can be extracted using `stringr::str_detect()`


```r
require(stringr)
rules.lhs  <- glo.inspectDF %>% 
  filter(str_detect(LHS, pattern = "yogurt|sausage")) %>%
  arrange(confidence, lift) %>%
  filter(n > 1) %>% 
  head()
rules.lhs %>% knitr::kable()
```



rule        LHS                 RHS                        n     support   confidence        lift   count
----------  ------------------  -----------------------  ---  ----------  -----------  ----------  ------
Rule 97     whole milk,yogurt   UHT-milk                   2   0.0010168    0.0181488   0.5425339      10
Rule 98     whole milk,yogurt   red/blush wine             2   0.0010168    0.0181488   0.9444108      10
Rule 99     whole milk,yogurt   house keeping products     2   0.0010168    0.0181488   2.1767518      10
Rule 100    whole milk,yogurt   liver loaf                 2   0.0010168    0.0181488   3.5698730      10
Rule 7175   whole milk,yogurt   chewing gum                2   0.0011185    0.0199637   0.9485170      11
Rule 7176   whole milk,yogurt   cling film/bags            2   0.0011185    0.0199637   1.7530626      11

By default, rule strings are split by separater `","`. But, items sometimes contain separater characters ***e.g. [IUPAC of DHA](https://pubchem.ncbi.nlm.nih.gov/compound/Docosahexaenoic_acid#section=IUPAC-Name)***. In such case, user can change rule-separater freely `sep = string`.
 

```r
glo.apriori %>% 
  inspectDF(sep = "###") %>% 
  filter(n >3) %>% 
  select(2:3) %>% 
  head()
#>                                                        LHS         RHS
#> 1 root vegetables###other vegetables###whole milk###yogurt     waffles
#> 2 root vegetables###other vegetables###whole milk###yogurt       sugar
#> 3 root vegetables###other vegetables###whole milk###yogurt      onions
#> 4 root vegetables###other vegetables###whole milk###yogurt butter milk
#> 5  tropical fruit###other vegetables###whole milk###yogurt   margarine
#> 6  tropical fruit###other vegetables###whole milk###yogurt      grapes
```

Similar to original `plot.rules` with `igraph` in arules package, each rule size represents **support** value. This size can be adjusted by `adujust.support.size` in plot functions. 


```r
require(stringr)
rules.lhs  <- glo.inspectDF %>% 
  filter(str_detect(RHS, pattern = "yogurt")) %>%
  arrange(confidence, lift) %>%
  filter(n > 1) %>% 
  head(15)

par(mfrow = c(1,2))
set.seed(0)
rules.lhs %>% plotRuleGraph(label = "default")
set.seed(0)
rules.lhs %>% plotRuleGraph(label = "adjusted rule size", 
                            adujust.support.size = 4000)
```

![](README_files/figure-html/usecase.adjust.rule-1.png)<!-- -->

```r
par(mfrow = c(1,1))
```

