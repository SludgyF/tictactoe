:- use_module(library(pce)).

% Primero definimos los botones de nuestra interfaz
crear_interfaz :-
    new(@main, dialog('Gato')),
    send(@main, size, size(300, 300)),
    
    % Definimos los botones para los espacios
    new(@btn1, button('', message(@prolog, hacer_movimiento, 1))),
    send(@main, display, @btn1, point(50, 50)),

    new(@btn2, button('', message(@prolog, hacer_movimiento, 2))),
    send(@main, display, @btn2, point(125, 50)),

    new(@btn3, button('', message(@prolog, hacer_movimiento, 3))),
    send(@main, display, @btn3, point(200, 50)),

    new(@btn4, button('', message(@prolog, hacer_movimiento, 4))),
    send(@main, display, @btn4, point(50, 125)),

    new(@btn5, button('', message(@prolog, hacer_movimiento, 5))),
    send(@main, display, @btn5, point(125, 125)),

    new(@btn6, button('', message(@prolog, hacer_movimiento, 6))),
    send(@main, display, @btn6, point(200, 125)),

    new(@btn7, button('', message(@prolog, hacer_movimiento, 7))),
    send(@main, display, @btn7, point(50, 200)),

    new(@btn8, button('', message(@prolog, hacer_movimiento, 8))),
    send(@main, display, @btn8, point(125, 200)),

    new(@btn9, button('', message(@prolog, hacer_movimiento, 9))),
    send(@main, display, @btn9, point(200, 200)),
    
    % Definimos un boton para reiniciar el juego
    new(@reset_btn, button('Reiniciar', message(@prolog, reiniciar_juego))),
    send(@main, display, @reset_btn, point(100, 250)),
    
    % Abre la ventana
    send(@main, open),

    reiniciar_juego.

% Se inicia el tablero vacio
:- dynamic(tablero/1).
:- dynamic(turno/1).
tablero([b, b, b, b, b, b, b, b, b]).
turno(x).

% Logica para hacer un movimiento cuando se pica un boton
hacer_movimiento(Casilla) :-
    tablero(Tablero),
    nth1(Casilla, Tablero, b),  % Check if the position is empty
    retract(tablero(Tablero)),
    turno(Jugador),
    actualizar_tablero(Casilla, Tablero, Jugador, NuevoTablero),
    assertz(tablero(NuevoTablero)),
    actualizar_interfaz(NuevoTablero),
    (   victoria(NuevoTablero, Jugador) -> format(atom(Mensaje), '¡Jugador ~w ha ganado!', [Jugador]), send(@main, report, inform, Mensaje), !
    ;   \+ member(b, NuevoTablero) -> send(@main, report, inform, '¡Juego empatado!'), !
    ;   otro(Jugador, SiguienteJugador),
        retract(turno(Jugador)),
        assertz(turno(SiguienteJugador))
    ).

% Logica de reinicio de juego
reiniciar_juego :-
    retractall(tablero(_)),
    assertz(tablero([b, b, b, b, b, b, b, b, b])),
    retractall(turno(_)),
    assertz(turno(x)),
    actualizar_interfaz([b, b, b, b, b, b, b, b, b]).

% Actualizar el tablero
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

% Actualizar interfaz
actualizar_interfaz([A, B, C, D, E, F, G, H, I]) :-
    send(@btn1, label, A), send(@btn2, label, B), send(@btn3, label, C),
    send(@btn4, label, D), send(@btn5, label, E), send(@btn6, label, F),
    send(@btn7, label, G), send(@btn8, label, H), send(@btn9, label, I).

% Se define caracter de jugador siguiente
otro(x, o).
otro(o, x).

% Se crea interfaz
:- crear_interfaz.