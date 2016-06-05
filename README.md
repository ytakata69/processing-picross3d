# processing-picross3d

<img src="https://raw.github.com/wiki/ytakata69/processing-picross3d/picross3d-screen.png" width="320" alt="" />

A program for illustrating [Picross-3D](https://www.nintendo.co.jp/ds/c6pj/) instances.

Though this is mainly for demonstration, you can play the puzzle more or less.
If you have installed a SAT solver such as [MiniSat](http://minisat.se),
you can also solve puzzle instances using the solver.

## Install & Run
You need [Processing](https://processing.org/) Development Environment to compile and run this program.

1. Clone the repository.
1. Rename the folder containing the .pde files "picross3d"
   instead of "processing-picross3d".
1. Open picross3d.pde in the Processing Development Environment and run it.

### Solving with a SAT solver

If you have installed a SAT solver such as [MiniSat](http://minisat.se),
you can use it for solving puzzle instances by pressing 'S' key.

When you press 'S' key, the Processing program writes out
a [DIMACS CNF file](http://www.satcompetition.org/2009/format-benchmarks2009.html)
for solving the given instance
and invokes `sat/solve.sh`.

Please modify `sat/solve.sh` according to your environment.


## Usage
* Drag: Rotate the model.
* Shift + Drag up/down: Zoom in/out.
* Ctrl + Click: Erase a cube.
* Alt  + Click: Mark a cube.
* Press 'u': Undo.
* Press 'r': Reset the model.
* Press 'a': Show the answer.
* Press '0': Make the cubes transparent in the rows with hint "0".
* Press ')': Erase the cubes in the rows with hint "0".
* Press 'S': Solve the puzzle instance using a SAT solver.
* Press 'F' or 'B': Move to another puzzle instance.



## References
* Nintendo. "Rittai-Picross," <https://www.nintendo.co.jp/ds/c6pj/>.
* Kusano, et al. "Picross 3D is NP-complete,"
  15th Game Programming Workshop, 108--113, 2010.  
  <https://ipsj.ixsq.nii.ac.jp/ej/?action=repository_uri&item_id=71326&file_id=1&file_no=1>
* Kougaku-navi. "Compute the world-coordinates corresponding to
  the screen-coordinates,"
  <http://d.hatena.ne.jp/kougaku-navi/20160102/p1>
* Processing.org. <https://processing.org/>
