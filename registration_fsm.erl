-module(registration_fsm).
-behavior(gen_fsm).

-export([start_link / 0,
		 stop / 0, 
	     create_order / 0,
	     edit_order / 0,
	     submit_order /0,
	     review_order / 0,
	     accept_order / 0,
	     reject_order / 0]).

-export([init / 1,
	     create / 2,
	     edit / 2,
	     submit / 2,
	     review / 2,
	     accept / 2,
	     reject / 2,
	     handle_event / 3,
	     handle_sync_event / 4,
	     terminate / 3,
	     code_change / 4]).

%% Public API

start_link() -> gen_fsm:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() -> gen_fsm:send_all_state_event(?MODULE, stop).

create_order() -> gen_fsm:send_event(?MODULE, create).

edit_order() -> gen_fsm:send_event(?MODULE, edit).

submit_order() -> gen_fsm:send_event(?MODULE, submit).

review_order() -> gen_fsm:send_event(?MODULE, review).

accept_order() -> gen_fsm:send_event(?MODULE, accept).

reject_order() -> gen_fsm:send_event(?MODULE, reject).

%% FSM Callbacks

init([]) -> {ok, create, [], 0}.

create(Event, State) ->
	case Event of
		edit ->
			order_edit(),
			{next_state, edit, State, 60000};
		_ ->
			io:format("Please edit the order~n"),
			{next_state, create, [], 60000}
	end.

edit(Event, State) ->
	case Event of
		submit ->
			order_submit(),
			{next_state, submit, State, 60000};
		_ ->
			order_recreate(),
			{next_state, create, [], 60000}
	end.

submit(Event, State) ->
	case Event of
		review ->
			order_review(),
			{next_state, review, State, 60000};
		_ ->
			order_recreate(),
			{next_state, create, [], 60000}
	end.


review(Event, State) ->
	case Event of
		accept ->
			order_accept(),
			{next_state, accept, State, 60000};
		reject ->
			order_reject(),
			{next_state, reject, State, 60000};
		_ ->
			order_recreate(),
			{next_state, create, [], 60000}
	end.

accept(Event, _) ->
	case Event of
		_ ->
			order_recreate(),
			{next_state, create, [], 60000}
	end.

reject(Event, _) ->
	case Event of
		_ ->
			order_recreate(),
			{next_state, create, [], 60000}
	end.

handle_event(stop, _, State) ->
	{stop, normal, State};
handle_event(_, StateName, State) ->
	{next_state, StateName, State}.

handle_sync_event(_, _, StateName, State) ->
	Reply = ok,
	{reply, Reply, StateName, State}.

terminate(_, _, _) -> ok.

code_change(_, StateName, State, _) -> {ok, StateName, State}.


%% internal functions

order_recreate() ->
	io:format("Order recreated, please edit the order again~n").

order_edit() ->
	io:format("Order edited!~n").

order_submit() ->
	io:format("Order submitted!~n").

order_review() ->
	io:format("Order reviewed!~n").

order_accept() ->
	io:format("Order accepted!~n").

order_reject() ->
	io:format("Order rejected!~n").
