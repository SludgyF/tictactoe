:- use_module(library(pce)).

% Primero definimos los botones de nuestra interfaz
crear_interfaz :-
    new(@main, dialog('Gato')),
    send(@main, size, size(300, 300)),
    
    % Define buttons for the board cells
    new(@btn1, button(1, message(@prolog, hacer_movimiento, 1))),
    send(@main, display, @btn1, point(50, 50)),

    new(@btn2, button(2, message(@prolog, hacer_movimiento, 2))),
    send(@main, display, @btn2, point(125, 50)),

    new(@btn3, button(3, message(@prolog, hacer_movimiento, 3))),
    send(@main, display, @btn3, point(200, 50)),

    new(@btn4, button(4, message(@prolog, hacer_movimiento, 4))),
    send(@main, display, @btn4, point(50, 125)),

    new(@btn5, button(5, message(@prolog, hacer_movimiento, 5))),
    send(@main, display, @btn5, point(125, 125)),

    new(@btn6, button(6, message(@prolog, hacer_movimiento, 6))),
    send(@main, display, @btn6, point(200, 125)),

    new(@btn7, button(7, message(@prolog, hacer_movimiento, 7))),
    send(@main, display, @btn7, point(50, 200)),

    new(@btn8, button(8, message(@prolog, hacer_movimiento, 8))),
    send(@main, display, @btn8, point(125, 200)),

    new(@btn9, button(9, message(@prolog, hacer_movimiento, 9))),
    send(@main, display, @btn9, point(200, 200)),
    
    % Define a button to restart the game
    new(@reset_btn, button('Reiniciar', message(@prolog, reiniciar_juego))),
    send(@main, display, @reset_btn, point(100, 250)),
    
    % Open the window
    send(@main, open).

% Se inicia el tablero vacio
:- dynamic(tablero/1).
tablero([b, b, b, b, b, b, b, b, b]).

% Logica para hacer un movimiento cuando se pica un boton
hacer_movimiento(Casilla) :-
    tablero(Tablero),
    nth1(Casilla, Tablero, b),  % Check if the position is empty
    retract(tablero(Tablero)),
    actualizar_tablero(Casilla, Tablero, x, NuevoTablero),
    assertz(tablero(NuevoTablero)),
    mostrar(NuevoTablero),
    (   victoria(NuevoTablero, x) -> send(@main, report, inform, '¡Has ganado!'), !
    ;   \+ member(b, NuevoTablero) -> send(@main, report, inform, '¡Juego empatado!'), !
    ;   hacer_movimiento_computadora(NuevoTablero)
    ).

% Logica para el movimiento de la computadora
hacer_movimiento_computadora(Tablero) :-
    movimiento_computadora(Tablero, o, NuevaPosicion),
    actualizar_tablero(NuevaPosicion, Tablero, o, NuevoTablero),
    retract(tablero(Tablero)),
    assertz(tablero(NuevoTablero)),
    mostrar(NuevoTablero),
    (   victoria(NuevoTablero, o) -> send(@main, report, inform, '¡La computadora ha ganado!'), !
    ;   \+ member(b, NuevoTablero) -> send(@main, report, inform, '¡Juego empatado!'), !
    ;   true
    ).

% Logica de reinicio de juego
reiniciar_juego :-
    retractall(tablero(_)),
    assertz(tablero([b, b, b, b, b, b, b, b, b])),
    send(@main, report, inform, 'El juego ha sido reiniciado.'),
    mostrar([b, b, b, b, b, b, b, b, b]).

% Pre
actualizar_tablero(Posicion, [b|Resto], Jugador, [Jugador|Resto]) :-
    Posicion =:= 1.
actualizar_tablero(Posicion, [Cabeza|Resto], Jugador, [Cabeza|NuevoResto]) :-
    Posicion > 1,
    Pos1 is Posicion - 1,
    actualizar_tablero(Pos1, Resto, Jugador, NuevoResto).

% Logica de victoria
victoria(Tablero, Jugador) :-
    victoria_fila(Tablero, Jugador);
    victoria_columna(Tablero, Jugador);
    victoria_diagonal(Tablero, Jugador).

% Predicado de victoria
victoria_fila(Tablero, Jugador) :-
    Tablero = [Jugador, Jugador, Jugador, _, _, _, _, _, _];
    Tablero = [_, _, _, Jugador, Jugador, Jugador, _, _, _];
    Tablero = [_, _, _, _, _, _, Jugador, Jugador, Jugador].
% Verifica si hay victoria en las columnas
victoria_columna(Tablero, Jugador) :-
    Tablero = [Jugador, _, _, Jugador, _, _, Jugador, _, _];
    Tablero = [_, Jugador, _, _, Jugador, _, _, Jugador, _];
    Tablero = [_, _, Jugador, _, _, Jugador, _, _, Jugador].

victoria_diagonal(Tablero, Jugador) :-
    Tablero = [Jugador, _, _, _, Jugador, _, _, _, Jugador];
    Tablero = [_, _, Jugador, _, Jugador, _, Jugador, _, _].

% Mostrar tablero
mostrar([A, B, C, D, E, F, G, H, I]) :-
    format('~w | ~w | ~w~n', [A, B, C]),
    format('---------~n'),
    format('~w | ~w | ~w~n', [D, E, F]),
    format('---------~n'),
    format('~w | ~w | ~w~n', [G, H, I]), nl.

% Se define caracter de jugador siguiente
otro(x, o).
otro(o, x).

% Logica de movimiento de computadora
movimiento_computadora(Tablero, Jugador, NuevaPosicion) :-
    findall(Pos, (between(1, 9, Pos), nth1(Pos, Tablero, b)), PosicionesLibres),
    random_member(NuevaPosicion, PosicionesLibres).

% Se crea interfaz
:- crear_interfaz.
