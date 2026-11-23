# Unit 6 Finding: Is the Platform Getting Better or Worse?

**To the leadership team**

Four weeks ago, you asked whether a dashboard's failure rate could be trusted. Since then, I have corrected it, broken it down by movie, and identified the movies behind it. This memo answers the last two questions: **is the failure problem getting better or worse, and what should the team do next quarter?**

## The short answer

**The failure problem got better early in 2023 and then held steady. It did not keep improving.** The share of ratings withdrawn fell from about 23% in the first quarter to about 15% in the second, and stayed close to 15% for the rest of the year. Meanwhile, the number of ratings the platform received stayed flat all year and finished 20% below the target.

## The evidence

**1. The withdrawal rate dropped after the first quarter, then levelled off.**

| Quarter | Ratings | Withdrawn | Withdrawal rate |
|---|---|---|---|
| Q1 (Jan–Mar) | 53 | 12 | 22.6% |
| Q2 (Apr–Jun) | 48 | 7 | 14.6% |
| Q3 (Jul–Sep) | 51 | 8 | 15.7% |
| Q4 (Oct–Dec) | 48 | 7 | 14.6% |
| **Full year** | **200** | **34** | **17.0%** |

*Source: the monthly withdrawal query in `queries/unit6/q6_3.sql` (Part B). The quarterly figures are the sums of its monthly rows.*

The improvement is real but limited: the rate fell by about a third between the first and second quarters, then stopped falling. Seen half-year by half-year, the rate went from 18.8% (January to June) to 15.2% (July to December).

**2. Individual months swing too much to read on their own.**
Month to month, the withdrawal rate ranged from **0%** (April) to **27.3%** (March), and June's rate was more than double May's. These swings come from small numbers: each month has only 11 to 21 ratings, so one or two withdrawals move the rate by 5 to 10 percentage points. *Source: the same query, `q6_3.sql` Part B.* A month-by-month report would make the platform look like it is lurching between crisis and recovery. The quarterly view above is the more reliable picture.

**3. Engagement is flat and below target.**
The platform received **200 ratings in 2023**, against a target of 250, so it reached **80%** of the goal. By the end of June it had reached only about 40% of the target, so it was behind from mid-year onward. Quarterly volume barely moved (53, 48, 51, 48), and by December the recent average was about one rating per active day. *Source: the running total and moving average in `queries/unit6/q6_2.sql` (Part B).*

**4. The problems are concentrated in specific movies.**
Earlier reports showed that movies **11, 2, and 9** have withdrawal rates of 25% to 31%, well above the platform's 17% (Unit 4, `queries/unit4/`). They also showed that movies **14 and 15** have never been rated at all (Unit 5, `queries/unit5/q5_2.sql`).

## What the team should do next quarter

**1. Treat about 15% as the current baseline, and focus moderation on the movies that drive it.**
The drop after the first quarter shows the rate can come down, but it stopped improving at around 15%. Rather than spreading effort across the whole catalog, the moderation team should concentrate on movies 11, 2, and 9, reviewing the accounts behind their withdrawn ratings and tightening spam checks on those titles. **Goal for next quarter: bring the overall withdrawal rate below 12%.**

**2. Report the withdrawal rate by quarter, not by month, and always show the rating count beside it.**
With 11 to 21 ratings a month, a single month cannot tell whether the platform is improving. Leadership should judge the trend on quarterly figures (or a rolling three-month rate), so the team does not react to swings caused by one or two ratings.

**3. Grow engagement, starting with the movies no one is finding.**
Ratings volume is flat and the platform finished 20% short of its target. The easiest place to start is movies 14 and 15, which have no genre tags and therefore do not appear when users browse by genre. Tagging and featuring them is a low-cost test. More broadly, the team should set a quarterly ratings target and track the running total against it every month, so a shortfall is visible by mid-quarter rather than at year's end.

## What we know and what we don't

The data shows that the withdrawal rate fell early in the year and then levelled off, that monthly figures are too small to trust individually, and that engagement stayed flat. It does not show **why** the rate fell after the first quarter, whether because of a moderation change, fewer spam accounts, or chance. It also does not show why users stop rating some movies for months at a time. Answering those questions would need information this database does not record: moderation activity over time, account history, and viewing behavior. Collecting that data next quarter would let the next report explain the trend, not just describe it.
