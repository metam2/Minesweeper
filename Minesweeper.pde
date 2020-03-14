import de.bezier.guido.*;
//Declare and initialize constants NUM_ROWS and NUM_COLS = 20
private int NUM_ROWS = 20;
private int NUM_COLS = 20;
private int MIN_GRID = 5;
private int MAX_GRID = 25;
private float MINES_PERCENT = 0.08; //MINES_PERCENT is the percentage of all the buttons that are mines
private float LABEL_RATIO = 3.0 / 5.0; //ratio of button label to button side length
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines; //ArrayList of just the minesweeper buttons that are mined
private boolean running;
private float f = 0;
void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    background(0);
    running = true;
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    mines = new ArrayList <MSButton>();
    
    // make the manager
    Interactive.make( this );

    //your code to initialize buttons goes here
    for(int r = 0; r < NUM_ROWS; r++){
        for(int c = 0; c < NUM_COLS; c++){
            buttons[r][c] = new MSButton(r, c);
        }
    }

    Interactive.setActive(this, running);
    setMines();
}
public void setMines()
{
    for(int r = 0; r < NUM_ROWS; r++){
        for(int c = 0; c < NUM_COLS; c++){
            if(Math.random() < MINES_PERCENT)
                mines.add(buttons[r][c]);
        }
    }
    if(mines.size() == 0)
        setMines();
}

public void draw ()
{
    if(isWon() == true)
        displayWinningMessage();
    if(!running)
    {
        fill(200);
        rect(100, 270, 150, 25);
        displayResetMessage();
    }
}
public boolean isWon()
{
    for (MSButton mine : mines){
        if(!mine.isFlagged())
            return false;
    }
    for (MSButton[] row : buttons){
        for(MSButton button : row){
            if(!mines.contains(button) && !button.isClicked())
                return false;
        }
    }
    return true;
}
public void stopGame()
{
    for(MSButton[] rows : buttons)
        {
            for(MSButton but : rows)
                but.stop();
        }
    running = false;
    Interactive.setActive(this, running);
}
public void keyPressed(){
    if(!running)
    {
        if( key == 'r')
            setup();
        if(key == 'a' && NUM_ROWS > MIN_GRID)
        {
            NUM_ROWS--;
            NUM_COLS--;
        }
        if(key == 's' && NUM_ROWS < MAX_GRID)
        {
            NUM_ROWS++;
            NUM_COLS++;
        }
    }
}
public void displayResetMessage()
{

    fill(0, 50, 100);
    textSize(30);
    textAlign(CENTER,CENTER);
    text("Press R to reset", 200, 250);
    textSize(22);
    textAlign(LEFT, TOP);
    text("Grid Size: " + NUM_ROWS, 100, 270);
}
public void displayLosingMessage()
{
    stopGame();

    for (MSButton mine : mines){
        mine.drawRed();
    }

    fill(255, 0, 0);
    textSize(50);
    text("GAME OVER", 200, 150);
    
}
public void displayWinningMessage()
{
    stopGame();
    fill(0, 255, 0);
    textSize(50);
    textAlign(CENTER,CENTER);
    text("YOU WIN", 200, 150);
}
public boolean isValid(int r, int c)
{
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}
public int countMines(int row, int col)
{
    int numMines = 0;
    for(int r = row - 1; r <= row + 1; r++){
        for(int c = col - 1; c <= col + 1; c++){
            if(isValid(r, c)){
                if( mines.contains(buttons[r][c]) ){
                    numMines++;
                }
            }
        }
    }
    return numMines;
}
public class MSButton
{
    private int myRow, myCol;
    private float x,y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton ( int row, int col )
    {
        width = 400/NUM_COLS;
        height = 400/NUM_ROWS;
        myRow = row;
        myCol = col; 
        x = myCol*width;
        y = myRow*height;
        myLabel = "";
        flagged = clicked = false;

        Interactive.add( this ); // register it with the manager
    }

    // called by manager
    public void mousePressed () 
    {
        if(mouseButton == LEFT)
        {
            if(!flagged)
                clicked = true;
        }
        else
        {
            flagged = !flagged;
        }
    }
    public void draw () 
    {    
        if (flagged)
            fill(0);
        else if( clicked && mines.contains(this) ){
            fill(255,0,0);
            displayLosingMessage();
            return;
        }
        else if(clicked && countMines(myRow, myCol) > 0){
            fill( 200 );
            setLabel( countMines(myRow, myCol) );
        }
        else if(clicked){
            fill(200);
            for(int r = myRow - 1; r <= myRow + 1; r+=2){
                if(isValid(r, myCol)){ 

                    mouseButton = LEFT;
                    buttons[r][myCol].mousePressed();
                }
            }
            for(int c = myCol - 1; c <= myCol + 1; c+=2){
                if(isValid(myRow, c)){
                    mouseButton = LEFT;
                    buttons[myRow][c].mousePressed();
                }
            }
        }
        else 
            fill( 100 );

        rect(x, y, width, height);
        fill(0);
        textSize(width * LABEL_RATIO);
        text(myLabel,x+width/2,y+height/2);
    }
    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    public void setLabel(int newLabel)
    {
        myLabel = ""+ newLabel;
    }
    public boolean isFlagged()
    {
        return flagged;
    }
    public boolean isClicked()
    {
        return clicked;
    }
    public void stop()
    {
        Interactive.setActive(this, false);
    }
    public void drawRed()
    {
        fill(255, 0, 0);
        rect(x, y, width, height);
    }
}
