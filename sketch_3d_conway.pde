final float CELL_SIZE = 10.f;
final float CELL_SIZE_2 = 5.f;
final int   GRID_SIZE = 50;
// see : https://wpmedia.wolfram.com/uploads/sites/13/2018/02/01-3-1.pdf
// for some good 3d conway rules
final int[] RULE = { 10, 21, 10, 21 };

byte [][][] c_grid = new byte[GRID_SIZE][GRID_SIZE][GRID_SIZE]; // contains cell values
byte [][][] n_grid = new byte[GRID_SIZE][GRID_SIZE][GRID_SIZE]; // contains adjacency values
int  [][][] t_grid = new int [GRID_SIZE][GRID_SIZE][GRID_SIZE];

PGraphics canvas;

/**************************
 *   GAME OF LIFE LOGIC   *
 **************************/

// Updates adjacency values for each "on" cell on the grid
void update_ngrid()
{
  for(int z = 0; z < GRID_SIZE; z++){
  for(int y = 0; y < GRID_SIZE; y++){
  for(int x = 0; x < GRID_SIZE; x++)
  {
    byte cell = c_grid[z][y][x];
    switch(cell)
    {
      case 0 : break;
      case 1 : // modulo by grid size to wrap around boundaries
        for(int zi = z > 0 ? z-1 : GRID_SIZE-1; zi != (z+2)%GRID_SIZE; zi=(zi+1)%GRID_SIZE){
        for(int yi = y > 0 ? y-1 : GRID_SIZE-1; yi != (y+2)%GRID_SIZE; yi=(yi+1)%GRID_SIZE){
        for(int xi = x > 0 ? x-1 : GRID_SIZE-1; xi != (x+2)%GRID_SIZE; xi=(xi+1)%GRID_SIZE)
        {
          if(!(zi == xi && zi == yi))
          {
            n_grid[zi][yi][xi] += 1;
          }
        }}} break;
    }
  }}}
}

// Based on how many neighbors each cell has, turn the grid on, off, or don't do anything.
void update_cgrid()
{
  for(int z = 0; z < GRID_SIZE; z++){
  for(int y = 0; y < GRID_SIZE; y++){
  for(int x = 0; x < GRID_SIZE; x++)
  {
    byte cell = n_grid[z][y][x];
    if(cell <= RULE[3] && RULE[2] <= cell)
    {
      t_grid[z][y][x] = c_grid[z][y][x] == 1 ? t_grid[z][y][x] : 0;
      c_grid[z][y][x] = 1;
      
    }
    else if(!(cell <= RULE[1] && RULE[0] <= cell))
    {
      c_grid[z][y][x] = 0;
    }
    t_grid[z][y][x] += 1;
    n_grid[z][y][x] = 0;
  }}}
}

void init_cgrid()
{
  /*
  for(int z = GRID_SIZE/2 - 4; z < GRID_SIZE/2 + 4; z++){
  for(int y = GRID_SIZE/2 - 4; y < GRID_SIZE/2 + 4; y++){
  for(int x = GRID_SIZE/2 - 4; x < GRID_SIZE/2 + 4; x++)*/
  for(int z = 0; z < GRID_SIZE; z++){
  for(int y = 0; y < GRID_SIZE; y++){
  for(int x = 0; x < GRID_SIZE; x++)
  {
    // how dense the grid is populated is a large factor in how interesting the configuration ends up
    // Some interesting ones : 
    // rule{10, 21, 10, 21}, random(1) > 0.75-0.77, creates large structures that have long oscillation periods
    // rule{5, 7, 6, 6}, random(1) > 0.8, supposedly has gliders, has some oscillators and random debris
    c_grid[z][y][x] = random(1) > 0.76 ? (byte)1 : (byte)0;
  }}}
}

void init_ngrid()
{
  for(int z = 0; z < GRID_SIZE; z++){
  for(int y = 0; y < GRID_SIZE; y++){
  for(int x = 0; x < GRID_SIZE; x++)
  {
    n_grid[z][y][x] = 0;
  }}}
}

void init_tgrid()
{
  for(int z = 0; z < GRID_SIZE; z++){
  for(int y = 0; y < GRID_SIZE; y++){
  for(int x = 0; x < GRID_SIZE; x++)
  {
    t_grid[z][y][x] = 0;
  }}}
}

/**************************
 *   GRAPHICS FUNCTIONS   *
 **************************/
 
color c1 = color(40, 15, 80);  // color stage 1
color c2 = color(190, 50, 5);  // color stage 2
color c3 = color(190, 150, 5); // color stage 3
 
void draw_cgrid()
{
  beginShape(QUADS);
  // I only render the inner cube, because wrapping coordinates around is a headache
  for(int z = 1; z < GRID_SIZE-1; z++){
  for(int y = 1; y < GRID_SIZE-1; y++){
  for(int x = 1; x < GRID_SIZE-1; x++)
  {
    if(c_grid[z][y][x] == 1)
    {
      // transitions between colors based on how long the cell has existed
      int time = t_grid[z][y][x];
      fill( lerpColor(
            lerpColor(c2, c1, constrain(time / 45.f, 0, 1)),
            lerpColor(c3, c2, constrain(time / 15.f, 0, 1)), 
            time < 16 ? 1 : 0));
      // perform checks to see if face will be visible before drawing
      if(c_grid[z+1][y][x] == 0 || z+1 == GRID_SIZE)
      {
        normal(1, 0, 0);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
      }
      if(c_grid[z-1][y][x] == 0 || z-1 == 0)
      {
        normal(-1, 0, 0);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
      }
      if(c_grid[z][y+1][x] == 0 || y+1 == GRID_SIZE)
      {
        normal(0, 1, 0);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
      }
      if(c_grid[z][y-1][x] == 0 || y-1 == 0)
      {
        normal(0, -1, 0);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
      }
      if(c_grid[z][y][x+1] == 0 || x+1 == GRID_SIZE)
      {
        normal(0, 0, 1);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE + CELL_SIZE_2);
      }
      if(c_grid[z][y][x-1] == 0 || x-1 == 0)
      {
        normal(0, 0, -1);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE + CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
        vertex(z*CELL_SIZE - CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
        vertex(z*CELL_SIZE + CELL_SIZE_2, y*CELL_SIZE - CELL_SIZE_2, x*CELL_SIZE - CELL_SIZE_2);
      }
    }
  }}}
  endShape();
}

/**************************
 *     SETUP/MAIN LOOP    *
 **************************/

int tick_counter = 0;
float angle = 0.f;
float center = (GRID_SIZE * CELL_SIZE) / 2.f;

void setup()
{
  size(500, 500, P3D);
  init_cgrid();
  init_ngrid();
  init_tgrid();
  noStroke();
  frameRate(30);
}

void draw()
{
  tick_counter++;
  background(0);
  camera(cos(angle)*center*2 + center, 0, sin(angle)*center*2 + center, center, center, center, 0, 1, 0);
  draw_cgrid();
  if(tick_counter % 6 == 0)
  {
    update_ngrid();
    update_cgrid();
  }
  angle += 0.02;
}
