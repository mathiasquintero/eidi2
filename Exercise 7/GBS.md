**Grundlagen Betriebssysteme und System Software**
===
### Mathias Quintero, Markus Sellmaier

## Aufgabe 3 - Speicheralloziierung

Wir schreiben alle Freie Speicherplätze Tablerarisch auf. Jedes Zeitpunkt ist nach dem man eine Menge Speicher Alloziieren wollte. Falls ein Speicherplatzt komplett gefüllt wurde, wird der nicht mehr mitgeschrieben.

### 3.1 First Fit

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

### 3.2 Next Fit

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

### 3.3 Best Fit

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

### 3.4 Worst Fit

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

## Aufgabe 4 - Paging

### 3.1

Wir schreiben wieder tabelarisch welche Kacheln gehören zu welche Seiten. Und welche Seit steht im swap bereich.

#### 1. FIFO

| Zeitpunkt| w |  f~1~ | f~2~ | f~3~ | f~4~ | Swap | Fault |
| :------------- | :------------- | :------------- | :------------- | :------------- | :------------- | :------------- |
| 0 | | | | | | 1,2,3,4,5,0 | <li>[ ]</li> |
| 1 | 1 | **1** | | | | 2,3,4,5,0 | <li>[x]</li> |
| 2 | 3 | **1** | 3 | | | 2,4,5,0 | <li>[x]</li> |
| 3 | 5 | **1** | 3 | 5 | | 2,4,0 | <li>[x]</li> |
| 4 | 4 | **1** | 3 | 5 | 4 | 2,0 | <li>[x]</li> |
| 5 | 2 | 2 | **3** | 5 | 4 | 1,0 | <li>[x]</li> |
| 6 | 4 | 2 | **3** | 5 | 4 | 1,0 | <li>[ ]</li> |
| 7 | 3 | 2 | **3** | 5 | 4 | 1,0 | <li>[ ]</li> |
| 8 | 2 | 2 | **3** | 5 | 4 | 1,0 | <li>[ ]</li> |
| 9 | 1 | 2 | 1 | **5** | 4 | 3,0 | <li>[x]</li> |
| 10 | 0 |2 | 1 | 0 | **4** | 3,5 | <li>[x]</li> |
| 11 | 5 | **2** | 1 | 0 | 5 | 3,4 | <li>[x]</li> |
| 12 | 3 | 3 | **1** | 0 | 5 | 2,4 | <li>[x]</li> |
| 13 | 5 | 3 | **1** | 0 | 5 | 2,4 | <li>[ ]</li> |
| 14 | 0 | 3 | **1** | 0 | 5 | 2,4 | <li>[ ]</li> |
| 15 | 4 | 3 | 4 | **0** | 5 | 1,2 | <li>[x]</li> |
| 16 | 3 | 3 | 4 | **0** | 5 | 1,2 | <li>[ ]</li> |
| 17 | 5 | 3 | 4 | **0** | 5 | 1,2 | <li>[ ]</li> |
| 18 | 4 | 3 | 4 | **0** | 5 | 1,2 | <li>[ ]</li> |
| 19 | 3 | 3 | 4 | **0** | 5 | 1,2 | <li>[ ]</li> |
| 20 | 2 | 3 | 4 | 2 | **5** | 1,0 | <li>[x]</li> |
| 21 | 1 | **3** | 4 | 2 | 1 | 2,5 | <li>[x]</li> |
| 22 | 3 | **3** | 4 | 2 | 1 | 2,5 | <li>[ ]</li> |
| 23 | 4 | **3** | 4 | 2 | 1 | 2,5 | <li>[ ]</li> |
| 24 | 5 | 5 | **4** | 2 | 1 | 2,3 | <li>[x]</li> |
