$DIM ALL
DEFINT A-Z

%DEFAULTTICKCOUNT = 10000
%FALSE = 0
%TICKCOUNTSTEP = 1000
%TRUE = -1

TYPE BombStr
 Dropped AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE EnemyStr
 Disabled AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE PlayerStr
 BombCount AS INTEGER
 HitCount AS INTEGER
 Level AS INTEGER
 LevelFinished AS INTEGER
 Score AS INTEGER
 x AS INTEGER
END TYPE

DECLARE SUB AskTryAgain ()
DECLARE SUB CreateSubmarines ()
DECLARE SUB DisableEnemy (Enemy)
DECLARE SUB DisplayStartScreen ()
DECLARE SUB DisplayYouHaveLost ()
DECLARE SUB DisplayYouHaveWon ()
DECLARE SUB DropBomb ()
DECLARE SUB GoToNextLevel ()
DECLARE SUB Initialize ()
DECLARE SUB Main ()
DECLARE SUB MoveSubmarines ()
DECLARE SUB Quit ()
DECLARE SUB TickDelay (DelayTickCount AS DOUBLE)

DIM Bomb AS SHARED BombStr
DIM DefaultExplosion AS SHARED STRING
DIM DelayTickCount AS SHARED DOUBLE
DIM Enemy(0 TO 8) AS SHARED EnemyStr
DIM LevelBackgroundColor(0 TO 4) AS SHARED INTEGER
DIM Player AS SHARED PlayerStr
DIM Submarine AS SHARED STRING

CALL Main

SUB AskTryAgain ()
 DO
  PRINT "  Try again (Y/N)?";
  SELECT CASE UCASE$(INPUT$(1))
   CASE "N"
    Quit
   CASE "Y"
    Player.LevelFinished = %TRUE
    Initialize
    DisplayStartScreen
    EXIT DO
  END SELECT
 LOOP
END SUB

SUB CreateSubmarines ()
DIM EnemyIndex AS LOCAL INTEGER

 FOR EnemyIndex = 0 TO Player.Level + 4
  Enemy(EnemyIndex).x = INT(RND * 20) + 3
  Enemy(EnemyIndex).y = INT(RND * 79) + 1
  IF Enemy(EnemyIndex).y + LEN(Submarine) > 79 THEN Enemy(EnemyIndex).y = 79 - LEN(Submarine)
  Enemy(EnemyIndex).Disabled = %FALSE
 NEXT EnemyIndex
END SUB

SUB DisableEnemy (EnemyIndex AS INTEGER)
DIM Explosion AS LOCAL STRING
DIM Flash AS LOCAL INTEGER
DIM x AS LOCAL INTEGER

 IF NOT Enemy(EnemyIndex).Disabled THEN
  IF Bomb.y < 4 THEN
   LOCATE Bomb.x, Bomb.y
   Explosion = MID$(DefaultExplosion$, Bomb.y)
  ELSEIF Bomb.y > 75 THEN
   LOCATE Bomb.x, Bomb.y - 3
   Explosion = MID$(DefaultExplosion$, 1, LEN(DefaultExplosion$) - (80 - Bomb.y))
  ELSE
   LOCATE Bomb.x, Bomb.y - 3
   Explosion = DefaultExplosion$
  END IF

  COLOR 14
  PRINT Explosion;

  COLOR 12
  LOCATE Bomb.x, Bomb.y
  PRINT "BOOM!!!";
  FOR Flash = 0 TO 2
   PALETTE 0, 4
   SOUND 37, .3
   SOUND 100, .3
   PALETTE 0, LevelBackgroundColor(Player.Level)
  NEXT Flash

  DELAY 1

  LOCATE Bomb.x, Bomb.y - 3
  PRINT SPC(LEN(Explosion));

  INCR Player.Score, Enemy(EnemyIndex).x
  COLOR 2
  LOCATE 1, 1
  PRINT USING "Score: ###"; Player.Score;
  Bomb.Dropped = %FALSE
  Enemy(EnemyIndex).Disabled = %TRUE

  FOR x = Enemy(EnemyIndex).x TO 21
   COLOR 9
   LOCATE x, Enemy(EnemyIndex).y
   PRINT "  o  ";
   COLOR 4
   LOCATE x + 1, Enemy(EnemyIndex).y
   PRINT Submarine$;
   TickDelay DelayTickCount
  NEXT x

  FOR x = Enemy(EnemyIndex).x TO 22
   LOCATE x, Enemy(EnemyIndex).y
   PRINT SPC(LEN(Submarine$));
  NEXT x

  INCR Player.HitCount
 END IF
END SUB

SUB DisplayStartScreen ()
 COLOR 14
 PRINT
 PRINT "   Submarine,   By: Peter Swinkels, ***2021***"
 PRINT
 PRINT "      + = go faster"
 PRINT "      - = slow down"
 PRINT "  Space = drop bomb"
 PRINT " Escape = quit"

 DO: LOOP WHILE INKEY$ = ""
END SUB

SUB DisplayYouHaveLost ()
 CLS
 COLOR 4
 PRINT
 PRINT "  Û   Û ÜßßßÜ Û   Û  Û  Û ÜßßÜ Û   Û Ûßßß  Û    ÜßßßÜ Üßßß  ßßÛßß Û"
 PRINT "   ßÜß  Û   Û Û   Û  ÛßßÛ ÛßßÛ  Û Û  Ûßß   Û    Û   Û  ßßßÜ   Û   ß"
 PRINT "    ß    ßßß   ßßß   ß  ß ß  ß   ß   ßßßß  ßßßß  ßßß   ßßß    ß   ß"
END SUB

SUB DisplayYouHaveWon ()
 CLS
 COLOR 4
 PRINT
 PRINT "  Û   Û ÜßßßÜ Û   Û  Û  Û ÜßßÜ Û   Û Ûßßß  Û  Ü  Û ÜßßßÜ ÛÜ  Û Û"
 PRINT "   ßÜß  Û   Û Û   Û  ÛßßÛ ÛßßÛ  Û Û  Ûßß   Û Û Û Û Û   Û Û ßÜÛ ß"
 PRINT "    ß    ßßß   ßßß   ß  ß ß  ß   ß   ßßßß   ß   ß   ßßß  ß   ß ß"
END SUB

SUB DropBomb ()
 LOCATE Bomb.x, Bomb.y
 PRINT " ";
 IF Bomb.x = 22 THEN
  Bomb.Dropped = %FALSE
 ELSE
  INCR Bomb.x
  COLOR 8
  LOCATE Bomb.x, Bomb.y
  PRINT "o";
 END IF
END SUB

SUB GoToNextLevel ()
DIM EnemyIndex AS LOCAL INTEGER

 IF Player.Level = 4 THEN
  DisplayYouHaveWon
  AskTryAgain
 ELSE
  INCR Player.Level
 END IF

 FOR EnemyIndex = 0 TO Player.Level + 4
  Enemy(EnemyIndex).Disabled = %FALSE
 NEXT EnemyIndex

 Player.BombCount = 25
 Player.HitCount = 0
 Player.LevelFinished = %TRUE
END SUB

SUB Initialize ()
 RANDOMIZE TIMER
 SCREEN 0
 WIDTH 80, 25
 COLOR 7, 0
 CLS
 PALETTE 0, 1

 ERASE Enemy
 ERASE LevelBackgroundColor

 DefaultExplosion = "Ü°ÛÛÛÛÜÛ°Ü"
 DelayTickCount = %DEFAULTTICKCOUNT
 Player.BombCount = 25
 Player.HitCount = 0
 Player.Level = 0
 Player.Score = 0
 Player.x = 1
 LevelBackgroundColor(0) = &H19
 LevelBackgroundColor(1) = &H9
 LevelBackgroundColor(2) = &H11
 LevelBackgroundColor(3) = &H1
 LevelBackgroundColor(4) = &H8
 Submarine = "ÜÜÛÜÜ"
END SUB

SUB Main ()
 Initialize
 DisplayStartScreen

 DO
  CLS
  PALETTE 0, LevelBackgroundColor(Player.Level)
  CreateSubmarines

  DO
   COLOR 2
   LOCATE 1, 1
   PRINT USING "Score: ###   Bombs: ####    Level: #"; Player.Score; Player.BombCount; Player.Level + 1
   DO
    MoveSubmarines
    IF Bomb.Dropped THEN
     DropBomb
    ELSEIF Player.BombCount = 0 THEN
     DisplayYouHaveLost
     AskTryAgain
    END IF
   LOOP UNTIL INSTAT OR Player.LevelFinished
   SELECT CASE INKEY$
    CASE CHR$(27)
     Quit
    CASE " "
     IF NOT Bomb.Dropped THEN
      Bomb.x = 3
      Bomb.y = Player.x
      DECR Player.BombCount
      Bomb.Dropped = %TRUE
     END IF
    CASE "+"
     IF DelayTickCount - %TICKCOUNTSTEP > 0 THEN DECR DelayTickCount, %TICKCOUNTSTEP
    CASE "-"
     IF DelayTickCount + %TICKCOUNTSTEP < 2147483647 THEN INCR DelayTickCount, %TICKCOUNTSTEP
   END SELECT
  LOOP UNTIL Player.LevelFinished
  Player.LevelFinished = %FALSE
 LOOP
END SUB

SUB MoveSubmarines ()
DIM EnemyIndex AS SHARED INTEGER

 LOCATE 2, Player.x
 IF Player.x + LEN(Submarine$) > 79 THEN
  PRINT SPC(LEN(Submarine$));
  Player.x = 1
 ELSE
  COLOR 7
  PRINT " "; Submarine$;
  INCR Player.x
 END IF

 FOR EnemyIndex = 0 TO Player.Level + 4
  IF Bomb.Dropped THEN
   IF Bomb.x = Enemy(EnemyIndex).x AND Bomb.y >= Enemy(EnemyIndex).y AND Bomb.y <= Enemy(EnemyIndex).y + 5 THEN
    DisableEnemy EnemyIndex
    IF Player.HitCount = Player.Level + 5 THEN
     Player.HitCount = 0
     GoToNextLevel
     EXIT SUB
    END IF
   END IF
  END IF
  IF NOT Enemy(EnemyIndex).Disabled THEN
   LOCATE Enemy(EnemyIndex).x, Enemy(EnemyIndex).y
   IF Enemy(EnemyIndex).y = 1 THEN
    PRINT SPC(LEN(Submarine$) + 1);
    Enemy(EnemyIndex).y = 79 - LEN(Submarine$)
   ELSE
    COLOR 4
    PRINT Submarine$; " ";
    DECR Enemy(EnemyIndex).y
   END IF
  END IF
 NEXT EnemyIndex

 TickDelay DelayTickCount
END SUB

SUB Quit ()
 PALETTE
 SCREEN 0
 WIDTH 80, 25
 COLOR 7, 0
 CLS
 END
END SUB

SUB TickDelay (DelayTickCount AS DOUBLE)
DIM Tick AS DOUBLE

 FOR Tick = 0 TO DelayTickCount
 NEXT Tick
END SUB
