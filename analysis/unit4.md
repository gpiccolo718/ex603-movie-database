# Unit 4 Write-up

## Task 4.1

### Who acts on the per-movie breakdown

The person who would act on the per-movie breakdown is the content (catalog) manager: the person who decides which movies to promote, keep, or review with the studio that supplied them. The breakdown tells them which movies get the most ratings and which score best on average, which is the starting point for those decisions.

### What the aggregate hides

An average conceals its distribution. Movie 10 averages 3.31, which looks like a solidly "okay" movie, but nobody actually rated it okay. Of its 19 ratings, 8 are 2.1 or below and 10 are 4.2 or above, with only one in between. People either loved it or disliked it, and the average describes neither group. The averages are also pulled down by withdrawn ratings, which are all stored as 0.5. Movie 11 averages 2.09 across all ratings, but 2.82 once its five withdrawn ratings are left out, so much of its low score reflects withdrawals rather than viewers' opinions.

A count conceals who is counted. The rating counts include withdrawn ratings (spam, duplicates, and policy violations) alongside real ones, and they count ratings, not people. Movie 10's 19 ratings came from only 12 different users, and across the platform, 46 ratings are repeat ratings of a movie the same user had already rated. A high count can therefore mean a few enthusiastic or abusive users rather than broad interest.

### What I would need to see next

Next, I would want the distribution of scores for each movie, for example how many ratings fall into low, middle, and high bands, so a polarized movie isn't mistaken for an average one. I would also want each movie's averages and counts recalculated with withdrawn ratings excluded, and the number of distinct users alongside the rating count, so that volume reflects how many people engaged rather than how many times they clicked.

## Task 4.2

**Part A.** My conditional aggregation answers two questions side by side: how many ratings did each movie receive, and how many of those were withdrawn? Seeing both in one row shows which movies have unusually high failure counts relative to their volume. Movie 11 had 5 of its 16 ratings withdrawn, while movie 10 had none out of 19.

**Part B.** The five rows labelled with a country are the regional subtotals, and the row labelled "All Regions" is the platform grand total. The reader who needs subtotals rather than detail rows is the regional director, who has to compare regions at a glance rather than read through individual ratings. The grand total supports a platform-wide decision, such as whether to release the frozen payout, because it gives the overall withdrawal rate of 17%. The region rows alone cannot answer that, though they show where a region departs from it, such as India at 27.5% compared with the UK at 10%.

**Part C.** The pipeline answers this question: among movies with enough ratings to be reliable (15 or more), what is a typical withdrawal rate and average score? The baseline is about 15.7% withdrawn with an average score of 2.95, so a high-volume movie well above that rate, such as movie 11 at 31.2%, can be flagged for review.

## Reflection

Conditional aggregation calculates several answers in a single pass over the data. In Part A, one query read the ratings table once and, for each row, added it to a movie's total and, if it was withdrawn, to that movie's failure count too. The alternative is two separate queries: one counting all ratings per movie, and another with a WHERE clause counting only withdrawn ratings. That approach reads the table twice and produces two result sets that I would then have to line up by movie myself.

With 200 rows, the difference is invisible, since both approaches finish instantly. At a million rows, it matters. Reading the table is usually the most expensive part of an aggregate query, so two separate queries roughly double that work, and every extra condition I wanted (flagged ratings, spam, user requests) would add yet another full scan. Conditional aggregation adds only a small calculation per row instead of another trip through the whole table. There is also a correctness benefit: both numbers come from the same pass over the same rows, so they are guaranteed to be consistent. Separate queries run at slightly different moments could see different data if new ratings arrive in between, which would make a failure rate calculated from them subtly wrong.
