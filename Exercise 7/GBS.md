**Grundlagen Betriebssysteme und System Software**
===
### Mathias Quintero, Markus Sellmaier

## Aufgabe 10.3 - Speicheralloziierung

Wir schreiben alle Freie Speicherplätze Tablerarisch auf. Jedes Zeitpunkt ist nach dem man eine Menge Speicher Alloziieren wollte. Falls ein Speicherplatzt komplett gefüllt wurde, wird der nicht mehr mitgeschrieben.

### a) First Fit

Wir gehen alle Plätze durch, bis wir einen finden, wo es passt.

| Zeitpunkt n| | | | | |
| :------------- | :------------- | :------------- | :------------- | :------------- | :------------- |
| 0 | 100 kB | 400 kB | 250 kB | 200 kB | 50 kB |
| 1 | 70 kB | 400 kB | 250 kB | 200 kB | 50 kB |
| 2 | 10 kB | 400 kB | 250 kB | 200 kB | 50 kB |
| 3 | 10 kB | 280 kB | 250 kB | 200 kB | 50 kB |
| 4 | 10 kB | 260 kB | 250 kB | 200 kB | 50 kB |
| 5 | 10 kB | 160 kB | 250 kB | 200 kB | 50 kB |
| 6 | 10 kB | 160 kB | 200 kB | 50 kB | |

### b) Next Fit

Wir gehen alle Plätze seit dem Lezten zugriff durch, bis wir einen finden, wo es passt. Das heißt, wir fangen nicht immer mit den ersten.

| Zeitpunkt n||||||
| :------------- | :------------- | :------------- | :------------- | :------------- | :------------- |
| 0 |100 kB|400 kB|250 kB|200 kB|50 kB|
| 1 |70 kB|400 kB|250 kB|200 kB|50 kB|
| 2 |10 kB|400 kB|250 kB|200 kB|50 kB|
| 3 |10 kB|280 kB|250 kB|200 kB|50 kB|
| 4 |10 kB|260 kB|250 kB|200 kB|50 kB|
| 5 |10 kB|160 kB|250 kB|200 kB|50 kB|
| 6 |10 kB|160 kB|200 kB|50 kB||

### c) Best Fit

Wir gehen alle Plätze durch und suchen den kleinsten wo es passt.

| Zeitpunkt n||||||
| :------------- | :------------- | :------------- | :------------- | :------------- | :------------- |
| 0 |100 kB|400 kB|250 kB|200 kB|50 kB|
| 1 |100 kB|400 kB|250 kB|200 kB|20 kB|
| 2 |30 kB|400 kB|250 kB|200 kB|20 kB|
| 3 |30 kB|400 kB|250 kB|80 kB|20 kB|
| 4 |30 kB|400 kB|250 kB|80 kB|
| 5 |30 kB|400 kB|150 kB|80 kB|
| 6 |30 kB|150 kB|150 kB|80 kB|

### d) Worst Fit

Wir gehen alle Plätze durch und suchen den Größten.

| Zeitpunkt n||||||
| :------------- | :------------- | :------------- | :------------- | :------------- | :------------- |
| 0 |100 kB|400 kB|250 kB|200 kB|50 kB|
| 1 |100 kB|370 kB|250 kB|200 kB|50 kB|
| 2 |100 kB|310 kB|250 kB|200 kB|50 kB|
| 3 |100 kB|190 kB|250 kB|200 kB|50 kB|
| 4 |100 kB|190 kB|230 kB|200 kB|50 kB|
| 5 |100 kB|190 kB|130 kB|200 kB|50 kB|

### **!!! Fault !!!**

Es gab keinen Platz für die 250 kB.

## Aufgabe 10.4 - Paging
