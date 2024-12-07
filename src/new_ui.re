open Tyxml;

module Page = {
  open Tyxml;

  let createElement = (~children: list('a), ()): Html.doc => {
    <html>
      <head>
        <title> {Html.txt("Camlet")} </title>
        <script
          src="https://unpkg.com/htmx.org@2.0.3"
          integrity="sha384-0895/pl2MU10Hqc6jd4RvrthNlDiE9U1tWmX7WRESftEDRosgxNsQG/Ze9YMRzHq"
          crossorigin="anonymous"
        />
        <script src="https://unpkg.com/htmx-ext-sse@2.2.2/sse.js" />
        <link href="/static/output.css" rel="stylesheet" />
      </head>
      <body> ...children </body>
    </html>;
  };
};

let actionBox = (~action, ~icon) =>
  <div
    className="col-span-1 p-6 bg-grey-10 flex flex-col items-start rounded-3xl shadow-md">
    <div
      className="p-4 bg-grey-20 flex justify-center items-center rounded-full">
      icon
    </div>
    <span className="pt-4 text-2xl text-grey-100"> {Html.txt(action)} </span>
    <span className="text-base text-grey-50"> {Html.txt(action)} </span>
  </div>;

let infoBox = (~title, ~value) =>
  <div
    className="col-span-2 p-6 bg-grey-10 flex flex-col gap-6 rounded-3xl shadow-md">
    <div className="flex justify-between items-center">
      <span className="text-2xl text-grey-100"> {Html.txt(title)} </span>
      <select
        className="py-2 px-5 bg-primary-50 rounded-full flex flex-row justify-between items-center w-[45%] text-xl home-select outline-none text-grey-100">
        <option> "Esse mês" </option>
        <option> "Último mês" </option>
      </select>
    </div>
    <div className="text-[2.5rem] text-grey-100"> {Html.txt(value)} </div>
  </div>;

// TODO: create transaction type just for this component
// TODO: refactor: remove all this logic from this component, this is horrible
let transactionRow = (transaction, ~wallet_id) => {
  open Storage.Transaction;
  module Relation = Storage.Relation;
  open Tyxml.Html;

  // TODO: we should have an _actual_ formatter for humans here :)
  let dateFormatted =
    transaction.timestamp |> Format.asprintf("%a", Ptime.pp_human()) |> txt;

  let (title, nameOpt) =
    switch (transaction.kind) {
    | Transfer(transfer) =>
      if (Uuid.equal(Relation.key(transfer.sender_wallet), wallet_id)) {
        (txt("Transferência enviada"), Some(txt("José da Silva")));
      } else {
        (txt("Transferência recebida"), Some(txt("José da Silva")));
      }
    | Deposit(_) => (txt("Dinheiro sacado"), None)
    | Withdrawal(_) => (txt("Dinheiro sacado"), None)
    };

  let amount = transaction.amount |> Amount.to_string_pretty |> txt;

  let name =
    switch (nameOpt) {
    | Some(name) =>
      <>
        <span className="text-lg text-grey-50"> name </span>
        <div className="bg-grey-50 w-px h-full"> " " </div>
        <span className="text-lg text-grey-50"> dateFormatted </span>
      </>
    | None =>
      <> <span className="text-lg text-grey-50"> dateFormatted </span> </>
    };

  <div
    className="flex flex-row justify-between items-center py-8 first:pt-0 last:pb-0">
    <div className="flex flex-row gap-8">
      <div className="bg-grey-20 p-4 rounded-full">
        {Icons.bank(~width=32., ~height=32.)}
      </div>
      <div className="flex flex-col">
        <span className="text-[1.375rem] text-grey-100"> title </span>
        <div className="flex flex-row gap-4"> ...name </div>
      </div>
    </div>
    <div
      className="text-[1.375rem] py-1 px-4 bg-grey-20 text-grey-100 rounded-full">
      amount
    </div>
  </div>;
};

let navButton = (~btnText, ~icon, ~selected) =>
  <li>
    <button
      className=[
        "px-5 py-4 text-xl w-full flex justify-start items-center gap-2 rounded-full"
        ++ (if (selected) {" bg-primary-50"} else {""}),
      ]>
      <span className="w-5 h-5 text-grey-100"> icon </span>
      <span className="text-grey-100"> {Tyxml.Html.txt(btnText)} </span>
    </button>
  </li>;

let home = (_request, ~transactions, ~wallet_id, ~balance, ~income, ~expenses) => {
  let balance = balance |> Amount.to_string_pretty |> Html.txt;
  let income = income |> Amount.to_string_pretty;
  let expenses = expenses |> Amount.to_string_pretty;

  <Page>
    <div className="h-screen grid grid-cols-5 gap-6 pt-6 bg-grey-15">
      <nav className="col-span-1 pb-6 pl-8">
        <div
          className="h-full rounded-3xl bg-grey-10 py-10 px-5 flex flex-col gap-14">
          <h1 className="text-[2.5rem] text-center"> "Camlet" </h1>
          <ul className="flex-1 flex flex-col gap-6">
            {navButton(
               ~btnText="Home",
               ~icon=Icons.house(~width=20.0, ~height=20.0),
               ~selected=true,
             )}
            {navButton(
               ~btnText="Minha Conta",
               ~icon=Icons.person(~width=20.0, ~height=20.0),
               ~selected=false,
             )}
          </ul>
        </div>
      </nav>
      <main
        className="col-span-4 grid grid-cols-4 gap-y-8 gap-x-6 content-start overflow-y-auto pr-8">
        <header
          className="col-span-4 bg-grey-10 p-3 flex flex-row justify-between items-center rounded-3xl">
          <h2 className="text-[1.75rem] px-2.5 text-grey-100"> "Home" </h2>
          <div className="flex flex-row items-center gap-6">
            <div className="w-6 h-6 text-grey-100">
              {Icons.questionMark(~width=24.0, ~height=24.0)}
            </div>
            <div className="p-3 bg-grey-20 rounded-full text-grey-100">
              {Icons.notifications(~width=24.0, ~height=24.0)}
            </div>
          </div>
        </header>
        <div className="col-span-4">
          <div className="text-[2rem] mb-1 text-grey-100"> "Saldo" </div>
          <div className="text-5xl text-grey-100"> balance </div>
        </div>
        {actionBox(
           ~action="Enviar dinheiro",
           ~icon=Icons.arrowUp(~width=32., ~height=32.),
         )}
        {actionBox(
           ~action="Depositar",
           ~icon=Icons.arrowDown(~width=32., ~height=32.),
         )}
        {actionBox(
           ~action="Sacar dinheiro",
           ~icon=Icons.bank(~width=32., ~height=32.),
         )}
        {actionBox(
           ~action="Transações",
           ~icon=Icons.receipt(~width=32., ~height=32.),
         )}
        {infoBox(~title="Recebidos", ~value=income)}
        {infoBox(~title="Gastos", ~value=expenses)}
        <h2 className="col-span-4 text-[2rem] text-grey-100">
          "Transações"
        </h2>
        <div
          className="col-span-4 bg-grey-10 p-6 grid grid-cols-1 rounded-3xl divide-y divide-grey-25">
          ...{List.map(tx => transactionRow(tx, ~wallet_id), transactions)}
        </div>
      </main>
    </div>
  </Page>;
};
