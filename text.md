
# Building a Scalable Invoice-to-Delivery Matching Service: Combining Data Structures, PostgreSQL, and Fuzzy Logic

When I set out to build a matching algorithm that links invoice line items to delivery line items, I immediately identified the core challenge: efficiently filtering delivery lines associated with a specific invoice. This filtering step was crucial because it drastically reduces the search space from potentially thousands of delivery lines to just those relevant for the invoice, ideally down to a constant number per invoice.

## Understanding Data Structures — and Knowing When to Use Them

I have a solid understanding of the data structures involved here. Intuitively, the best approach is to group delivery line items by their delivery ID, clustering them together in memory or storage so that all relevant lines can be retrieved with a single, efficient memory or disk access.

Maintaining such a clustering in memory would require some overhead — but importantly, the natural order of creation for delivery lines usually corresponds closely to the order in which they need to be accessed, making the clustering low-maintenance.

However, implementing and maintaining such complex data structures myself would have been reinventing the wheel. Well-known relational databases like PostgreSQL already offer highly optimized, battle-tested solutions such as indexes and clustering mechanisms — designed and maintained by experts over decades and available for free.

Therefore, I made the pragmatic choice to offload this heavy lifting to PostgreSQL, trusting it to efficiently cluster and index delivery line items by delivery ID. This allowed me to focus my development effort where it really mattered: designing the matching algorithm.

## Generating Realistic Mock Data

A major hurdle was the lack of real data due to confidentiality. To proceed, I developed a comprehensive script that generates realistic mock data simulating delivery lines and invoice lines. This data includes plausible titles (with typos), amounts, units, and the necessary relationships between invoice lines and delivery lines.

This realistic dataset was critical for building, testing, and benchmarking my algorithm in conditions close to real-world use.

## The Matching Algorithm

### First Approach: Fuzzy Title Matching

I began with matching by title similarity because it avoids the complexities of the subset sum problem. Using the `rapidfuzz` library, which efficiently calculates Levenshtein distances, I compared invoice and delivery line titles.

This library is well-suited because it handles:

-   Levenshtein distance between words,
    
-   Word reordering without excessive penalty,
    
-   Substring similarities.
    

This first approach successfully matched a large portion of line items with reasonable accuracy.


### Improving Accuracy: Adding Approximate Subset Sum Checks

Extensive testing soon revealed scenarios where fuzzy title matching failed — cases where the titles were heavily butchered or ambiguous.

I decided to incorporate subset sum checks as a backup for these tricky cases. While the **trivial brute-force solution to subset sum is exponential**, there are more efficient algorithms available that perform well in practice. However, standard subset sum algorithms are usually designed around integers, not floating-point numbers, which posed a challenge.

To address this, I adapted the approach by rounding float amounts to integers after scaling by a precision factor, allowing for an approximate matching with configurable tolerance. This made the subset sum step practical and effective despite the floating-point nature of the data.

The approximate subset sum solver was only invoked on ambiguous titles and when there were few invoice lines involved, minimizing computational cost and floating-point error propagation.

### Testing and Monitoring

With both fuzzy matching and approximate subset sum integrated, I passed my own rigorous tests. I also added extensive logging, enabling monitoring of the matching process and capturing hints for future improvements.

## Conclusion
    
-   Rather than building custom, complex in-memory clustering, I leveraged PostgreSQL’s **native indexing and clustering** — a wise, practical choice to reduce maintenance and improve performance.
    
-   The **matching algorithm** smartly combines fuzzy string matching and an approximate subset sum solver tailored for floating point amounts.
    
-   A **realistic mock data generator** enabled robust testing.
    
-   The system is well-instrumented with **logging** for future diagnostics and improvement.
    
