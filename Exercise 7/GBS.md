Grundlagen Betriebssysteme und System Software
===

### Mathias Quintero, Markus Sellmaier
---
## Aufgabe 10.3 - Speicheralloziierung

| Header One     | Header Two     |
| :------------- | :------------- |
| Item One       | Item Two       |

### a) First Fit

| Zeitpunkt n||||||
| :------------- | :------------- |
| 0 |100 kB|400 kB|250 kB|200 kB|50 kB|
| 1 |70 kB|400 kB|250 kB|200 kB|50 kB|
| 2 |10 kB|400 kB|250 kB|200 kB|50 kB|
| 3 |10 kB|280 kB|250 kB|200 kB|50 kB|
| 4 |10 kB|260 kB|250 kB|200 kB|50 kB|
| 5 |10 kB|160 kB|250 kB|200 kB|50 kB|
| 6 |10 kB|160 kB|200 kB|50 kB||

### b) Next Fit

| Zeitpunkt n||||||
| :------------- | :------------- |
| 0 |100 kB|400 kB|250 kB|200 kB|50 kB|
| 1 |70 kB|400 kB|250 kB|200 kB|50 kB|
| 2 |10 kB|400 kB|250 kB|200 kB|50 kB|
| 3 |10 kB|280 kB|250 kB|200 kB|50 kB|
| 4 |10 kB|260 kB|250 kB|200 kB|50 kB|
| 5 |10 kB|160 kB|250 kB|200 kB|50 kB|
| 6 |10 kB|160 kB|200 kB|50 kB||

### c) Best Fit

| Zeitpunkt n||||||
| :------------- | :------------- |
| 0 |100 kB|400 kB|250 kB|200 kB|50 kB|
| 1 |100 kB|400 kB|250 kB|200 kB|20 kB|
| 2 |30 kB|400 kB|250 kB|200 kB|20 kB|
| 3 |30 kB|400 kB|250 kB|80 kB|20 kB|
| 4 |30 kB|400 kB|250 kB|80 kB|
| 5 |30 kB|400 kB|150 kB|80 kB|
| 6 |30 kB|150 kB|150 kB|80 kB|

### d) Worst Fit

| Zeitpunkt n||||||
| :------------- | :------------- |
| 0 |100 kB|400 kB|250 kB|200 kB|50 kB|
| 1 |100 kB|370 kB|250 kB|200 kB|50 kB|
| 2 |100 kB|310 kB|250 kB|200 kB|50 kB|
| 3 |100 kB|190 kB|250 kB|200 kB|50 kB|
| 4 |100 kB|190 kB|230 kB|200 kB|50 kB|
| 5 |100 kB|190 kB|130 kB|200 kB|50 kB|

### **!!! Fault !!!**

Es gab keinen Platz für die 250 kB.

|||||||
| :------------- | :------------- |
| 6 |100 kB|190 kB|130 kB|200 kB|50 kB|

## Aufgabe 10.4 - Paging
