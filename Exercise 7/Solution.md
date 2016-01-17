
Introduction to Informatics 2
==========
### **11.1** Proving Results
----------
We start with the following functions:
```ocaml
let f = fun x -> x + 1 * 2
let g = fun x -> x + 42
let h = 3
```

We now create the following statements:

$$
\begin{equation}
    \label{simple_equation}
    { \Pi  }_{ f }\quad =\quad \frac { \begin{matrix} \frac { let\quad f\quad =\quad fun\quad x\quad ->\quad x\quad +\quad 1\quad \times \quad 2 }{ f\quad x\quad \Rightarrow \quad x\quad +\quad 1\quad \times \quad 2 }  & 1\quad \times \quad 2\quad \Rightarrow \quad 2\quad  \end{matrix} }{ f\quad x\quad \Rightarrow \quad x\quad +\quad 2\quad  }
\end{equation}
$$

$$
\begin{equation}
    \label{simple_equation}
   { \Pi  }_{ g }=\frac { let\quad g\quad =\quad fun\quad x\quad ->\quad x\quad +\quad 42 }{ g\quad x\quad \Rightarrow \quad x\quad +\quad 42 }
\end{equation}
$$

We now must prove:



```ocaml
match [1;2;3] with [] -> 0|x::xs -> f x
```
Results in 3.
For that we define a function:

```ocaml
let a n = match n with [] -> 0|x::xs -> f x
```
