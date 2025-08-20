
% Pour charger l'interface graphique XPCE
:- use_module(library(pce)).   


% Types de crime
crime_type(assassinat).
crime_type(vol).
crime_type(escroquerie).


% Faits : suspects
suspect(john).
suspect(mary).
suspect(alice).
suspect(bruno).
suspect(sophie).


% Faits : indices

% Vol
has_motive(john, vol).
was_near_crime_scene(john, vol).
has_fingerprint_on_weapon(john, vol).

% Assassinat
has_motive(mary, assassinat).
was_near_crime_scene(mary, assassinat).
has_fingerprint_on_weapon(mary, assassinat).

% Escroquerie
has_motive(alice, escroquerie).
has_bank_transaction(alice, escroquerie).

has_bank_transaction(bruno, escroquerie).
owns_fake_identity(sophie, escroquerie).

% Exemple de témoin
eyewitness_identification(mary, assassinat).



% Règles de culpabilité
is_guilty(Suspect, vol) :-
    has_motive(Suspect, vol),
    was_near_crime_scene(Suspect, vol),
    has_fingerprint_on_weapon(Suspect, vol).

is_guilty(Suspect, assassinat) :-
    has_motive(Suspect, assassinat),
    was_near_crime_scene(Suspect, assassinat),
    ( has_fingerprint_on_weapon(Suspect, assassinat)
    ; eyewitness_identification(Suspect, assassinat)
    ).

is_guilty(Suspect, escroquerie) :-
    has_motive(Suspect, escroquerie),
    ( has_bank_transaction(Suspect, escroquerie)
    ; owns_fake_identity(Suspect, escroquerie)
    ).



% Interface graphique XPCE
start_interface :-
    new(Dialog, dialog('Enquête Policière – Détection de culpabilité')),

    % Menu Suspect
    new(SuspectMenu, menu(suspect, cycle)),
    forall(suspect(S), send(SuspectMenu, append, S)),
    send(Dialog, append, SuspectMenu),

    % Menu Crime
    new(CrimeMenu, menu(crime, cycle)),
    forall(crime_type(C), send(CrimeMenu, append, C)),
    send(Dialog, append, CrimeMenu),

    % Zone d'affichage du résultat
    new(Result, text_item('Résultat', '')),
    send(Result, editable, @off),
    send(Dialog, append, Result),

    % Bouton Vérifier
    send(Dialog, append,
        button('Vérifier', message(@prolog,
            verifier, SuspectMenu?selection, CrimeMenu?selection, Result))),

    % Bouton Quitter
    send(Dialog, append,
        button('Quitter', message(Dialog, destroy))),

    % Afficher la fenêtre
    send(Dialog, open).

% Vérification et affichage
verifier(Suspect, Crime, Result) :-
    ( is_guilty(Suspect, Crime) ->
        send(Result, selection, 'Coupable')
    ;   send(Result, selection, 'Non coupable')
    ).
