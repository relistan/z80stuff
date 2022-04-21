{
       <---> Dungeon Adventure game <--->
         Karl Matthias -- February 2022

       Find the treasure, kill the monsters, explore the dungeon.

       An adventure on CP/M 3.
}
program Adventure;
type
    { MapArray contains the base map/board for the game }
    MapArray = Array[2..24] of String[78];

    { Mobs are the NPCs and mobiles in the game }
    Mob = record
        X        : Byte;
        Y        : Byte;
        OldX     : Byte;
        OldY     : Byte;
        Speed    : Byte;
        HP       : Byte;
        MaxHP    : Byte;
        Hit      : Boolean;
        LastMove : Byte;
        Gold     : Integer;
    end;

var
   Board     : MapArray;
   GameTicks : Byte;
   Mobs      : Array[1..4] of Mob;
   Player    : Mob;
   i         : Byte;

procedure FadeOut;
var
   i : Byte;
begin
     gotoXY(30, 19);
     for i := 1 to 21 do
     begin
          write('-');
          Delay(40);
     end;

     gotoXY(30, 19);
     for i := 1 to 21 do
     begin
          write(' ');
          Delay(40);
     end;
end;

procedure SetColor(color : Integer);
begin
    write(#27,'[38;5;',color,'m');
end;

procedure SetBackground(color : byte);
begin
    write(#27,'[48;5;',color,'m');    { Black background }
end;

procedure ResetScr;
begin
     write(#27,'[?25h'); { Make the cursor visible }
     write(#27,'[0m');   { Reset all modes }
     write(#27,'(B');    { Set back to normal mode }
end;

procedure ClearScreen;
begin
     write(#27,'[2J'); { Clear Screen }
end;

procedure GraphicsMode;
begin
     write(#27,'(0');
end;

procedure gotoXY(x, y : Byte);
begin
     write(#27,'[',y,';',x,'H');
end;

function keyPressed : Boolean;
begin
     keyPressed := (BDos(6, $FE) <> 0); { Is there a keypress waiting? }
end;

function readChar : Char;
begin
     readChar := chr(BDos(6, $FF)); { Read a single character from console }
end;

procedure WriteCharAt(x,y : Integer; c : Char);
begin
    gotoXY(x, y);
    write(c);
end;

function ValidMove(x, y : Byte) : Boolean;
begin
     ValidMove := False;
     case Board[y][x] of
          ' ': ValidMove := True;
          '$': ValidMove := True;
     end;
end;

function Right(x, y : Byte) : Byte;
begin
     Right := x + 1;
     if (x > 79) or not ValidMove(x, y) then Right := x;
end;

function Left(x : Byte; y : Byte) : Byte;
begin
     Left := x - 1;
     if (x <= 2) or not ValidMove(x-2, y) then Left := x;
end;

function Up(x : Byte; y : Byte) : Byte;
begin
     Up := y - 1;
     if (y <= 2) or not ValidMove(x-1, y-1) then Up := y;
end;

function Down(x : Byte; y : Byte) : Byte;
begin
     Down := y + 1;
     if (y >= 24) or not ValidMove(x-1, y+1) then Down := y;
end;

procedure Hello;
var
   x, y : Byte;
begin
     Write(#27,'[?25l;'); { Turn off the cursor }
     SetBackground(0);    { Black background }
     ClearScreen;

     gotoXY(1, 4);
     SetColor(172);
     Write(
        '        _____',#13#10,
        '       |     \.--.--.-----.-----.-----.-----.-----.',#13#10,
        '       |  --  |  |  |     |  _  |  -__|  _  |     |',#13#10,
        '       |_____/|_____|__|__|___  |_____|_____|__|__|',#13#10,
        '                          |_____|',#13#10
     );
     SetColor(214);
     Write(
        '            _______     __                     __',#13#10,
        '           |   _   |.--|  |.--.--.-----.-----.|  |_.--.--.----.-----.',#13#10,
        '           |       ||  _  ||  |  |  -__|     ||   _|  |  |   _|  -__|',#13#10,
        '           |___|___||_____| \___/|_____|__|__||____|_____|__| |_____|',#13#10
     );
     Writeln('');
     Writeln('');

     SetColor(184);
     Writeln('           Design and Code -- Karl Matthias -- Copyright (c) 2022 ');

     GraphicsMode;

     { draw the horizontal bars }
     gotoXY(7, 3);
     for x := 7 to 72 do
     begin
          write('q');
     end;

     gotoXY(7, 13);
     for x := 7 to 72 do
     begin
          write('q');
     end;

     { draw the vertical bars }
     for y := 4 to 13 do
     begin
          WriteCharAt(6, y, 'x');
          WriteCharAt(73, y, 'x');
     end;

     { Draw the corners }
     WriteCharAt(6, 3, 'l');
     WriteCharAt(73, 3, 'k');
     WriteCharAt(6, 13, 'm');
     WriteCharAt(73, 13, 'j');

     gotoXY(30, 19);
     Delay(100);
     SetColor(208);

     Delay(750);

     write(#27,'(B');    { Set back to normal mode }
     Writeln('Begin the Adventure!');
End;

procedure DrawHealth;
var
   i : Byte;
begin
     { Draw Player health }
     gotoXY(10, 25);
     SetColor(220);
     write('HP ');
     for i := 1 to Player.MaxHP do
         if i <= Player.HP then
         begin
              { Hit points are green spaces }
              SetBackground(28);
              write(' ');
              SetBackground(0);
         end
         else begin
             SetBackground(0);
             write(' ');
         end;
     SetColor(208);
end;

procedure DrawGold;
begin
     { Draw Player health }
     gotoXY(50, 25);
     SetColor(142);
     write('GOLD ', Player.Gold, ' ');
end;

procedure Map;
var
   x,y  : Byte;

begin

     Board[2]  := '     a     (           kkklkkk    ********    aaasdddddd';
     Board[3]  := '     aaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[4]  := '***)    aaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[5]  := '                a aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[6]  := '   *  (aaa aaa                $(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[7]  := '     aaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaasdfgaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[8]  := 'aaa) (aaaaa    aaaaaaaaaaaaaaa  aaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaa';
     Board[9]  := '***  *aasdfa *aaaaaaaaaaaaa aaa aaaaaa**aaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaa';
     Board[10] := '***)                  $*aaaaaaaaa************aaaaaaa******************aaaaaaa';
     Board[11] := 'aaa*aaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[12] := 'aaa*aaaaaaaa aaa)$$                aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[13] := 'aaa*aaaaaaaa aaa)                                           aaaaaaaaaaaaaaaaa';
     Board[14] := 'aaa*aaaaaa   aaa)                  aaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaa';
     Board[15] := 'aaa*aaaaaaa aaaa)                  aaaaaaaaaaaaaaaaaaaaaaa  aaaaaaaaaaaaaaaaa';
     Board[16] := 'aaa*aaaaaaa aaaa)                  aaaaaaaaaaaaaaaaaaa          aaaaaaaaaaaaa';
     Board[17] := 'aaaa$       aaaaa                  aaaaaaaaaaaaaaaaaaa  aaaaaaaaaaaaaaaaaaaaa';
     Board[18] := 'aaaaaaaaaaa aaaaa                  aaaaaaaaaaaaa$       aaaaaaaaaaaaaaaaaaaaa';
     Board[19] := 'aaaaaaaaaaa aaaaa                  aaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaa';
     Board[20] := 'aaaaaaaaaa  aaaaaaaaa)  aaaaaaaaaaaaaaaaaaaaaaaaaaaaa  aaaaa****aaaaaaaaaaaaa';
     Board[21] := 'aaaaaaaaaa              (aaaaaaaaaaaaaaa$             aaaaaaa**aaaaaaaaaaaaaa';
     Board[22] := 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     Board[23] := 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  aaa********aaaaaaaaaaaaaaaaa';
     Board[24] := 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$aaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

     GraphicsMode;
     SetColor(220); { Gold borders }

     { draw the horizontal bars }
     gotoXY(2, 1);
     for x := 2 to 79 do
     begin
          write('q');
     end;

     gotoXY(2, 25);
     for x := 2 to 79 do
     begin
          write('q');
     end;

     { draw the vertical bars }
     for y := 2 to 24 do
     begin
          WriteCharAt(1, y, 'x');
          WriteCharAt(80, y, 'x');
     end;

     { Draw the corners }
     WriteCharAt(1, 1, 'l');
     WriteCharAt(80, 1, 'k');
     WriteCharAt(1, 25, 'm');
     WriteCharAt(80, 25, 'j');

     { Draw the title }
     gotoXY(45, 1);
     Write(' <--> DUNGEON ADVENTURE <--> ');
end;

procedure DrawViewport;
var
   x,y : Byte;
   Xmin,Xmax,Ymin,Ymax : Byte;
const
     BlockColors: Array[1..9] of byte =
        (100, 101, 102, 106, 107, 108, 142, 143, 144);

begin
     { I tried to make a data table here instead, but seems slower }

     { Viewport window is 5x5 box around the player }
     case Player.LastMove of
          1: begin { Left }
                  Ymin := Player.Y - 2; Ymax := Player.Y + 2;
                  Xmin := Player.X - 2; Xmax := Player.X - 2;
             end;
          2: begin { Right }
                  Ymin := Player.Y - 2; Ymax := Player.Y +2;
                  Xmin := Player.X + 2; Xmax := Player.X + 2;
             end;
          3: begin { Up }
                  Ymin := Player.Y - 2; Ymax := Player.Y - 2;
                  Xmin := Player.X - 2; Xmax := Player.X + 2;
             end;
          4: begin { Down }
                  Ymin := Player.Y + 2; Ymax := Player.Y + 2;
                  Xmin := Player.X - 2; Xmax := Player.X + 2;
             end;
          0: Exit; { No move, shouldn't have gotten here }
     end;

     { Clamp max/min }
     if Xmin < 2 then Xmin := 2;
     if Xmax > 79 then Xmax := 79;
     if Ymin < 2 then Ymin := 2;
     if Ymax > 24 then Ymax := 24;

     { Draw the board }
     SetColor(100);  { Green board }
     for y := Ymin to Ymax do
     begin
          for x := Xmin to Xmax do
          begin
               gotoXY(x, y);
               case (Board[y][x-1]) of
                    '*' : begin
                               SetColor(197);
                               write('*');
                               SetColor(100);
                          end;
                    '(', ')' : begin
                               SetColor(40);
                               write(Board[y][x-1]);
                          end;
                    'a' : begin
                               SetColor(BlockColors[Random(9) + 1]);
                               write('a');
                          end;
                    '$' : begin
                               SetColor(142);
                               write('$');
                          end;
                    ' ' : begin
                               write(' ');
                          end;
               else begin
                     SetColor(100);
                     write(Board[y][x-1]);
                   end;
               end;
          end;
     end;

     SetColor(208);  { Orange text }
     write(#27,'[1m');
end;

function Moved(mob : Mob) : Boolean;
begin
     Moved := (mob.X <> mob.OldX) or (mob.Y <> mob.OldY)
end;

{ Moves that are returned from this function are as follows:
       0 -> No move
       1 -> Move left
       2 -> Move right
       3 -> Move up
       4 -> Move down
}
function MoveFollow(mob : Mob; opponent : Mob) : Integer;
var
   XDist, YDist, absXDist : Integer;
begin
     XDist := mob.X - opponent.X;
     YDist := mob.Y - opponent.Y;

     { If we are on top of the enemy, no move }
     if (XDist = 0) and (YDist = 0) then
     begin
          MoveFollow := 0;
          Exit;
     end;

     { If x distance >= y distance }
     if (abs(XDist) ShR 2) >= abs(YDist) then
     begin
          { Is the difference positive? }
          if XDist > 0 then
          begin
               MoveFollow := 1;
               Exit;
          end;

          { Nope, negative }
          MoveFollow := 2;
          Exit;
     end

     { y distance > x distance }
     else begin
          { Is the difference positive? }
          if YDist > 0 then
          begin
               MoveFollow := 3;
               Exit;
          end;

          { Nope, negative }
          MoveFollow := 4;
          Exit;
     end;

end;

procedure CalculateTurn;
var
   i : Byte;

begin
     for i := 1 to 2 do
     begin
          { Don't activate any dead Mobs }
          if Mobs[i].HP > 0 then
          begin
               Mobs[i].OldX := Mobs[i].X; Mobs[i].OldY := Mobs[i].Y;

               { Move the mobs }
               if (GameTicks and $1F) <= Mobs[i].Speed then
               begin
                    if abs(Mobs[i].X + Mobs[i].Y - 10) <= abs(Player.X + Player.Y) then
                    begin
                         case (MoveFollow(Mobs[i], Player)) of
                              0: begin
                              Player.Hit := true;
                              Player.HP := Player.HP - 1;
                              end;
                              1: Mobs[i].X := Left(Mobs[i].X, Mobs[i].Y);
                              2: Mobs[i].X := Right(Mobs[i].X, Mobs[i].Y);
                              3: Mobs[i].Y := Up(Mobs[i].X, Mobs[i].Y);
                              4: Mobs[i].Y := Down(Mobs[i].X, Mobs[i].Y);
                         end;
                    end;
               end;
          end;
     end;
end;

procedure Attack;
var
   i : byte;

begin
     { Find a Mob that overlaps the player and attack the first one }
     for i := 1 to 2 do
     begin
          if (Mobs[i].HP > 0) and
              (Player.X = Mobs[i].X) and (Player.Y = Mobs[i].Y) then
          begin
               Mobs[i].HP := Mobs[i].HP - 1;
               WriteCharAt(Player.X, Player.Y, '@');
               gotoXY(50, 25);
               write('-',Mobs[i].HP,'-');
               Exit;
          end;
     end;
end;

Procedure Render;
var
    figure : Char;
    i      : Byte;

const
     figures     : Array[1..2] of Char = ('X', 'Y');
     mobFigures  : Array[1..2] of Char = ('P', 'R');

begin
     if Moved(Player) then
     begin
          DrawViewPort;
          { Rotate the figure, write it }
          figure := figures[((Player.X + Player.Y) and 1) + 1];
          WriteCharAt(Player.X, Player.Y, figure);

          { Overwrite old position }
          WriteCharAt(Player.OldX, Player.OldY, ' ');
     end;

     for i := 1 to 2 do
     begin
          { Draw the mob if they moved, or every so often }
          if Moved(Mobs[i]) or (GameTicks = 100) or (GameTicks = 200) then
          begin
               { Overwrite old position }
               WriteCharAt(Mobs[i].OldX, Mobs[i].OldY, ' ');

               { Rotate the mob figure, write it }
               if Mobs[i].HP = 0 then
               begin
                    SetColor(245);
                    WriteCharAt(Mobs[i].X, Mobs[i].Y, '&');
                    SetColor(208);
               end
               else begin
                    figure := mobFigures[((Mobs[i].X + Mobs[i].Y) and 1) + 1];
                    WriteCharAt(Mobs[i].X, Mobs[i].Y, figure);
               end;
          end;
     end;

end;

procedure SetupMobs;
begin
     with Mobs[1] do
     begin
          X := 20; Y := 19; Speed := 2; HP := 10;
     end;

     with Mobs[2] do
     begin
          X := 48; Y := 23; Speed := 2; HP := 12;
     end;
end;

procedure CheckGold;
begin
     if Board[Player.Y-1][Player.X-1] = '$' then
     begin
          Player.Gold := Player.Gold + 1;
          DrawGold;
          Board[Player.Y-1][Player.X-1] := ' ';
     end;
end;

procedure MovePlayer(cmd : Char);
begin
     Player.OldX := Player.X;
     Player.OldY := Player.Y;

     case (cmd) of
          'h' : begin
                     Player.X := Left(Player.X, Player.Y);
                     Player.LastMove := 1;
                end;
          'l' : begin
                     Player.X := Right(Player.X, Player.Y);
                     Player.LastMove := 2;
                end;
          'k' : begin
                     Player.Y := Up(Player.X, Player.Y);
                     Player.LastMove := 3;
                end;
          'j' : begin
                     Player.Y := Down(Player.X, Player.Y);
                     Player.LastMove := 4;
                end;
          'x' : Attack;
     end;

     CheckGold;
end;


procedure GameLoop;
var
   cmd : Char;

begin

     while True do
     begin
          Delay(5);
          GameTicks := GameTicks + 1;

          { Oh, noes, somebody dead }
          if Player.HP <= 0 then
             Exit;

          { Main Activity }
          cmd := readChar;
          if cmd = 'q' then Exit;
          MovePlayer(cmd);
          
          CalculateTurn;
          Render;

          { Deal with player health }
          if Player.Hit = true then
          begin
               DrawHealth;
               Player.Hit := false;
          end
          else if (GameTicks = 100) and (Player.HP < Player.MaxHP) then
          begin
               Player.HP := Player.HP + 1;
               DrawHealth;
          end;
     end;
end;

procedure SetupPlayer;
begin
     { Start off the character inside the screen }
     Player.X := 5; Player.Y := 5;

     { Initial Health Setup }
     Player.HP := 20; Player.MaxHP := 20;

     { Gold Setup }
     Player.Gold := 0;
end;

begin
     { Setup }
     Hello;
     Delay(1000);
     FadeOut;
     Delay(500);
     ClearScreen;
     SetupPlayer;
     SetupMobs;
     Map;
     DrawViewport;
     DrawHealth;
     WriteCharAt(Player.X, Player.Y, 'X');

     { Play }
     GameLoop;

     { Clean up }
     gotoXY(1, 25);
     for i := 1 to 25 do
     begin
          Writeln;
          Delay(60);
     end;
     gotoXY(34, 10);
     write(#27,'(B');    { Set back to normal mode }
     write('Game Over');
     Delay(1000);
     ResetScr;
     ClearScreen;
end.