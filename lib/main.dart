import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Search Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Word Search Game'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GridSetupScreen()),
                );
              },
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class GridSetupScreen extends StatefulWidget {
  @override
  _GridSetupScreenState createState() => _GridSetupScreenState();
}

class _GridSetupScreenState extends State<GridSetupScreen> {
  TextEditingController textController = TextEditingController();
  int m = 0;
  int n = 0;
  List<List<String>> grid = [];
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grid Setup'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter grid dimensions:'),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Rows (m)'),
                    onChanged: (value) {
                      setState(() {
                        errorMessage = '';
                        if (value.isNotEmpty && int.tryParse(value) != null) {
                          m = int.parse(value);
                        } else {
                          errorMessage = 'Invalid input for Rows';
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Columns (n)'),
                    onChanged: (value) {
                      setState(() {
                        errorMessage = '';
                        if (value.isNotEmpty && int.tryParse(value) != null) {
                          n = int.parse(value);
                        } else {
                          errorMessage = 'Invalid input for Columns';
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Enter alphabets (m * n):'),
            TextFormField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Alphabets'),
              onChanged: (value) {
                setState(() {
                  errorMessage = '';
                  if (value.length == m * n) {
                    grid = List.generate(
                      m,
                      (i) => List.generate(
                        n,
                        (j) => value[i * n + j],
                      ),
                    );
                  } else {
                    errorMessage = 'Invalid input for Alphabets';
                  }
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (grid.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GridDisplayScreen(grid, _resetSetup),
                    ),
                  );
                }
              },
              child: Text('Display Grid'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Reset setup function
  void _resetSetup() {
    setState(() {
      textController.clear();
      m = 0;
      n = 0;
      grid = [];
      errorMessage = '';
      Navigator.pop(context); // Go back to SplashScreen
    });
  }
}

class GridDisplayScreen extends StatefulWidget {
  final List<List<String>> grid;
  final VoidCallback resetSetup;

  GridDisplayScreen(this.grid, this.resetSetup);

  @override
  _GridDisplayScreenState createState() => _GridDisplayScreenState();
}

class _GridDisplayScreenState extends State<GridDisplayScreen> {
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  List<List<bool>> highlightMatrix = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grid Display'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                searchController.clear();
                searchText = '';
                highlightMatrix = [];
              });
              widget.resetSetup(); // Call the resetSetup function to go back to SplashScreen
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Enter text to search:'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(labelText: 'Search Text'),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                        highlightMatrix = [];
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      highlightMatrix = getHighlightMatrix();
                    });
                  },
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Grid:'),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.grid[0].length,
              ),
              itemCount: widget.grid.length * widget.grid[0].length,
              itemBuilder: (context, index) {
                int i = index ~/ widget.grid[0].length;
                int j = index % widget.grid[0].length;

                bool highlight = highlightMatrix.isNotEmpty && highlightMatrix[i][j];

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: highlight ? Colors.yellow : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      widget.grid[i][j],
                      style: TextStyle(
                        fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<List<bool>> getHighlightMatrix() {
    // Reset the matrix
    List<List<bool>> matrix = List.generate(
      widget.grid.length,
      (i) => List.generate(
        widget.grid[0].length,
        (j) => false,
      ),
    );

    // Check for word in all directions
    checkWord(0, 1, matrix);
    checkWord(1, 0, matrix);
    checkWord(1, 1, matrix);

    return matrix;
  }

  void checkWord(int di, int dj, List<List<bool>> matrix) {
    for (int i = 0; i < widget.grid.length; i++) {
      for (int j = 0; j < widget.grid[0].length; j++) {
        int k = 0; // Reset k for each starting point
        while (k < searchText.length) {
          int ni = i + k * di;
          int nj = j + k * dj;

          if (ni < 0 || ni >= widget.grid.length || nj < 0 || nj >= widget.grid[0].length) {
            break;
          }

          if (widget.grid[ni][nj] != searchText[k]) {
            break;
          }

          matrix[ni][nj] = true; // Update highlight matrix
          k++;
        }
      }
    }
  }
}
