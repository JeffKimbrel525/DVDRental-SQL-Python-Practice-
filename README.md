## DVD Rental Inventory Analysis: SQL vs. Python

I recently completed a Data Analytics bootcamp through UT Dallas/Fullstack Academy. Early in 2026, while learning SQL, I took the DVD Rental database we had been working with between classes to get some additional practice on my own. My focus was looking into slow-moving/dead inventory from the standpoint of what should be replaced. This was really the first time I took a dataset to SQL without a specific list of instructions to follow, it was just me exploring the data. This was the first time I had fun with SQL, as my findings were genuinely interesting.

After finishing the bootcamp, I decided to analyze the same database with Python as well. I wanted to compare how to explore the same data with the same goal but a different language. I found it interesting how different the process was between SQL and Python/Pandas, some findings like a never rented copy, were a lot quicker to spot in Python. Though by that point I already knew what I was looking for, which makes for an easier comparison than a first-time exploration.

### Files
- `dvd_rental_analysis.sql` — SQL exploration and queries
- `dvd_rental_analysis.ipynb` — Python/Pandas exploration of the same dataset

### Key Findings
- **Data integrity issue caught:** Identified 42 films with zero physical inventory copies before running further analysis, to avoid mistaking "no stock" for "no demand."
- **Never-rented copy detected:** Found an individual inventory copy of an otherwise popular film that had never been rented — distinct from a slow-moving title, and a good reminder to analyze at the copy level, not just the title level.
- **Genre-ranked underperformers:** Used SQL window functions to rank films by rental count within each genre, surfacing weak performers per category rather than a single global list.
- **Dead stock identification:** Calculated shelf idle-time between rentals for each inventory copy. Identified 168 films with at least one copy sitting idle 187+ days, with average idle time per film ranging from ~23 to ~62 days — a clear, consistent group of genuine dead-stock candidates for replacement.
- **Cross-validation:** Independently reproduced the same 168-film dead-stock list using both SQL (window functions) and Python/Pandas (`groupby` + `shift`), reinforcing confidence in the result.

Database: **[DVDRental sample database](https://neon.com/postgresql/getting-started/sample-database)**
