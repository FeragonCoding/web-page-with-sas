
FILENAME pagHtml '/folders/myfolders/FERDAT/index.html';

PROC SORT DATA=UDEMYLIB.VGSALES OUT=YOUTUBE.VGSALES;
    BY PLATFORM descending GLOBAL_SALES;
RUN;

DATA _NULL_;
    FILE pagHtml;
    PUT '<!DOCTYPE html>';
    PUT '<html>';
    PUT '<head>';
    PUT '  <title>Lista de Ventas de Videojuegos</title>';
    PUT '  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.1/css/bootstrap.min.css" integrity="sha384-VCmXjywReHh4PwowAiWNagnWcLhlEJLA5buUprzK8rxFgeH0kww/aWY76TfkUoSX" crossorigin="anonymous">';
    PUT '  <link rel="stylesheet" href="style.css">';
    PUT '</head>';
    PUT '<body>';
    PUT '  <div class="page-header">';
    PUT '    <img class="rounded-circle logo" src="feragon_logo.jpeg">';
    PUT '    <h2>Lista de Ventas por Consolas <small>(Generada desde SAS)</small></h2>';
    PUT '  </div><hr />';
    PUT '  <div class="container">';
RUN;

DATA YOUTUBE.VGSALES_TOP;
    SET YOUTUBE.VGSALES(WHERE=(PLATFORM IN ('3DS','DS','GC','PC','PS2','PS3',
                                            'PS4','Wii','WiiU','NS','X360','XOne')));
    BY PLATFORM; RETAIN COUNT;
    IF FIRST.PLATFORM THEN COUNT = 1;
    ELSE COUNT + 1;
    IF COUNT <= 9;
    DROP COUNT;
RUN;

PROC SQL;
    CREATE TABLE YOUTUBE.VGSALES_TOP_COVER AS (
      SELECT VGT.*, VGC.LINK AS COVER, PL.LINK AS LOGO
        FROM YOUTUBE.VGSALES_TOP VGT
        LEFT JOIN YOUTUBE.VG_COVERS VGC ON (VGT.NAME = VGC.NAME)
        LEFT JOIN YOUTUBE.PLATFORM_LOGO PL ON (PL.PLATFORM = VGT.PLATFORM)
    );
QUIT; 

PROC SORT DATA=YOUTUBE.VGSALES_TOP_COVER;
    BY PLATFORM descending GLOBAL_SALES;
RUN;

DATA _NULL_;
    LENGTH htmlLine $1000;
    FILE pagHtml mod;
    RETAIN PLATFORM_R '' i 0 j 0;
    SET YOUTUBE.VGSALES_TOP_COVER;
    BY PLATFORM;
    
    IF FIRST.PLATFORM THEN DO;
        IF PLATFORM_R NE '' THEN DO;
            PUT '</div> <!--Cierre tercer row de games_container-->';
            PUT '</div> <!--Cierre del games_container-->';
            PUT '</div> <!--Cierre de la consola-->';
        END;
        *PUT i=;
        IF i = 0 THEN
            PUT '<div class="row a1"><!--Apertura primer row de container-->';
        ELSE IF MOD(i,3) = 0 THEN DO;
            PUT '</div> <!--Cierre del row del container-->';
            PUT '<div class="row a2"><!--Apertura otro row de container-->';
        END;
            
        htmlLine = '<div class="col console_col btn btn-outline-light" id="'||lowcase(compress(platform))||'">';
        PUT htmlLine;
        htmlLine = '<img class="console_logo" src="'||LOGO||'">';
        PUT htmlLine; 
        htmlLine = '   <div class="container games_container" id="'||lowcase(compress(platform))||'_games">';
        PUT htmlLine;
        j = 0;
        i = i + 1;
        PLATFORM_R = PLATFORM;
    END;
    
    *PUT j=;
    IF j = 0 THEN
        PUT '       <div class="row"> <!--Apertura primer row de games_container-->';
    ELSE IF MOD(j,3) = 0 THEN DO;
        PUT '       </div> <!--Cierre primer/segundo row de games_container-->';
        PUT '       <div class="row b2"> <!--Apertura segundo/tercer row de games_container-->';
    END;
    
    PUT ' <div class="col card"><!--Apertura de card-->';
    htmlLine = '    <img class="card-img-top" src="'||COVER||'">';
    PUT htmlLine ;
    PUT '       <div class="card-body">';
    htmlLine = '           <h5 class="card-title">'||NAME||'</h5>';
    PUT htmlLine;
    htmlLine = '           <p class="card-text"><b>Genero:</b>'||GENRE||'</p>';
    PUT htmlLine;
    htmlLine = '           <p class="card-text"><b>Desarrolladores:</b>'||DEVELOPER||'</p>';
    PUT htmlLine;
    htmlLine = '           <p class="card-text"><b>Ventas: </b>$'||GLOBAL_SALES||'MM</p>';
    PUT htmlLine;
    PUT '       </div>';
    PUT ' </div><!--Cierre de card-->';
    
    j = j + 1;
RUN;

DATA _NULL_;
    FILE pagHtml mod;
    PUT '</body>';
    PUT '<footer>';
    PUT '   <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity=sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>';
    PUT '   <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js" integrity="sha384-9/reFTGAW83EW2RDu2S0VKaIzap3H66lZH81PoYlFhbGU+6BZp6G7niu735Sk7lN" crossorigin="anonymous"></script>';
    PUT '   <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.1/js/bootstrap.min.js" integrity="sha384-XEerZL0cuoUbHE4nZReLT7nx9gQrQreJekYhJD9WNWhH8nEW+0c5qq7aIo2Wl30J" crossorigin="anonymous"></script>';
    PUT '   <script src="script.js"></script>';
    PUT '</footer>';
    PUT '</html>';
RUN;