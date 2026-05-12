# Cookie Cats A/B Test - Experiment Plan

**Author:** [your name]
**Date:** [date]


## What this test is about

Cookie Cats is a mobile puzzle game where you connect colored tiles to clear levels. As players go through levels, the game has "gates" - points where you have to wait a few hours or pay a small amount to keep playing. The first gate is at level 30 right now.

The team running the game wanted to test what happens if they push that first gate to level 40 instead. The idea is that level 30 might be too early to hit a wall - players haven't really gotten into the game yet, so when the friction shows up they just leave. By level 40, hopefully they're more invested in the game and willing to wait or pay.

The dataset has about 90,000 users. Each user was randomly assigned to either the original setup (gate at 30) or the test version (gate at 40). For each user we know how many rounds they played and whether they came back on day 1 and on day 7.


## Why I'm doing this project

I want to learn how A/B testing actually works from start to finish. Most tutorials I've seen jump straight to running a t-test on data, but I've read that in real jobs the part before the analysis - picking metrics, choosing sample size, deciding what counts as a win - is where most of the thinking happens.

I picked Cookie Cats because the data is real, the question is easy to explain to anyone, and it lets me practice SQL, statistics, Bayesian methods, and machine learning on one connected problem. If it works out, I'll have one project that shows the full skillset instead of five disconnected small ones.


## The hypothesis

I think moving the gate to level 40 will improve 7-day retention, because players will have spent more time getting into the game before they hit the wall.

I'll consider it a real win if 7-day retention goes up by at least 1 percentage point, with a p-value below 0.05.


## The two groups

- **gate_30**: control. First gate stays at level 30.
- **gate_40**: treatment. First gate moved to level 40.

Users were randomly assigned at install. Once a user is in a group, they stay in that group.


## What metrics I'm tracking

I'm splitting metrics into three types because if you treat all metrics the same, you can almost always find one that improved and convince yourself the test worked. Picking one deciding metric in advance prevents that.

**Primary metric (the one that decides the test):**
- 7-day retention rate

I picked 7-day retention because in mobile games it's a better signal of long-term value than 1-day retention. Day 1 includes a lot of people who installed by accident or got bored in the first session. Day 7 is more about whether the game actually stuck.

**Secondary metrics (supporting evidence, not deciding):**
- 1-day retention
- Total game rounds played

**Guardrail metrics (these can't get worse):**
- 1-day retention shouldn't drop more than 1 percentage point
- Total rounds played shouldn't drop noticeably

Guardrails are there so I don't accidentally celebrate a win that came at the cost of something else important. If 7-day retention goes up but 1-day retention crashes, it probably means a lot of users had a worse early experience, and that's not a real win.

> **Interview cheat sheet:** A real A/B test has ONE primary metric, plus secondary and guardrail metrics. Multiple primaries means the test was set up to be hacked.


## Sample size check

Quick power calculation to make sure the dataset is big enough:

- Baseline 7-day retention: about 18-19%
- Smallest effect I want to detect: 1 percentage point
- Significance level: 0.05
- Power: 0.80

That comes out to needing about 26,000 users per group. The dataset has roughly 45,000 per group, so we're comfortably above the minimum.

> **Interview cheat sheet:** Sample size is calculated from baseline rate, minimum detectable effect, alpha, and power. Not guessed.


## Analysis plan

I'm writing this section before looking at any data on purpose. The point is to commit to my analysis steps in advance, so I can't change the rules after seeing results that don't match what I hoped for. (This is called p-hacking, and from what I've read it's one of the most common ways A/B tests get misread.)

Steps in order:

**Data quality first**
1. Check the split - is it actually close to 50/50?
2. Check for duplicate user IDs
3. Look at the distribution of game rounds for outliers
4. Confirm no user is in both groups

**Classical statistics**
5. Two-proportion z-test on 7-day retention (the main test)
6. Same test on 1-day retention
7. T-test on game rounds played
8. 95% confidence intervals on the differences

**Bayesian**
9. Beta-Binomial model to compute the probability that gate_40 is better than gate_30
10. I want to do this because Bayesian gives a more intuitive answer than a p-value. A p-value tells "if there were no difference, how unlikely would this data be?" A Bayesian probability tells you "what's the chance gate_40 is actually better?" The second one is what stakeholders actually want to know.

**Segments**
11. Slice retention by player engagement (light/medium/heavy players)
12. Check if the gate move helps everyone equally or only some players

**Machine learning**
13. Build a model to predict 7-day retention from player features
14. Try uplift modeling to estimate per-user treatment effect

I'm adding the ML part to push myself further than a basic A/B test. I want to learn uplift modeling because it's one of the more practical ways ML actually gets used in product decisions.


## What I'd recommend based on results

I'm deciding the recommendations in advance so I can't talk myself into a bad call later.

| Result | What I'd recommend |
|---|---|
| gate_40 wins on 7-day retention, no guardrail issues | Roll out gate_40 to all users |
| gate_40 wins but 1-day retention dropped meaningfully | Don't roll out yet, investigate further |
| gate_40 wins overall but loses for some segments | Roll out only to the segments where it works |
| No significant difference | Stay with gate_30, document what we learned |
| gate_40 loses | Stay with gate_30, maybe try other gate levels next |


## Limitations I want to be honest about

A few things this dataset and analysis can't tell me:

- **No revenue data.** Gates are a monetization tool. Even if gate_40 helps retention, it might hurt in-app purchases. I can't measure that here, so my recommendations will be retention-only.
- **Only 1-day and 7-day retention.** No 30-day or 90-day. A 7-day win could fade.
- **Possible novelty effect.** New things sometimes get a temporary boost that disappears. I'll try to check this by comparing earlier vs later parts of the test window.
- **One test only.** Real product decisions usually need a couple of tests to be confident in.


## What I'm hoping to learn

This is a self-directed learning project. The goals for me personally:

- Practice doing an A/B test analysis the way it's done at companies, not the way it's done in tutorials
- Get comfortable writing SQL against a real database instead of just CSVs
- Understand frequentist vs Bayesian in practice, not just in theory
- Learn what uplift modeling is and when it makes sense to use
- Practice communicating analytical results through a dashboard and a written report

If all the phases come together, this one project will show SQL, statistical inference, Bayesian methods, ML, dashboarding, and written communication. That's the goal.


---

*Note to self: come back and update the baseline retention number after looking at the data. Also add the actual test date range if it's documented anywhere in the dataset.*

