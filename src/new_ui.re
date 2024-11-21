open Tyxml;

module Page = {
  open Tyxml;

  let createElement = (~children: list('a), ()): Html.doc => {
    <html>
      <head>
        <title> {Html.txt("Payments")} </title>
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

let actionBox =
  <div className="col-span-1 p-6 bg-gray-200 flex flex-col items-start">
    <div className="p-4 bg-gray-100">
      /* TODO: change to icon later */
       <div className="h-8 w-8 bg-black" /> </div>
    <span className="pt-4 text-2xl"> "Enviar dinheiro" </span>
    <span className="text-base"> "Enviar dinheiro" </span>
  </div>;

let infoBox =
  <div className="col-span-2 p-6 bg-gray-200 flex flex-col gap-6">
    <div className="flex justify-between items-center">
      <span className="text-2xl"> "Recebidos" </span>
      <select
        className="py-2 px-5 bg-green-300 flex flex-row justify-between items-center w-[45%] text-xl home-select outline-none">
        <option> "Esse mês" </option>
        <option> "Último mês" </option>
      </select>
    </div>
    // TODO: font-size 40px
    <div className="text-4xl"> "$ 20.000,00" </div>
  </div>;

let transactionRow =
  <div className="bg-red-400 flex flex-row justify-between items-center">
    <div className="flex flex-row gap-8">
      <div className="bg-gray-200 p-4">
        <div className="h-8 w-8 bg-black"> {Tyxml.Html.txt("")} </div>
      </div>
      <div className="flex flex-col bg-green-100">
        // TODO: font-size: 22px

          <span className="text-2xl"> "Dinheiro recebido" </span>
          <div className="flex flex-row gap-4">
            <span className="text-lg"> "José Silva" </span>
            <div className="bg-black w-px h-full"> " " </div>
            <span className="text-lg">
              {Tyxml.Html.txt("12:32:15 27 OUT")}
            </span>
          </div>
        </div>
    </div>
    // TODO: font-size: 22px
    <div className="text-2xl py-1 px-4 bg-gray-200"> "R$ 500,00" </div>
  </div>;

let navButton = (~btnText, ~icon, ~selected) =>
  <li className="bg-white">
    <button
      className=[
        "px-5 py-4 text-xl w-full flex justify-start items-center gap-2 rounded-full"
        ++ (if (selected) {" bg-primary-50"} else {""}),
      ]>
      <span className="w-5 h-5 text-grey-100"> icon </span>
      <span className="text-grey-100"> {Tyxml.Html.txt(btnText)} </span>
    </button>
  </li>;

let home =
  <Page>
    <div className="h-screen grid grid-cols-5 gap-6 pt-6 bg-grey-15">
      <nav className="col-span-1 pb-6 pl-8">
        <div
          className="h-full rounded-3xl bg-grey-10 py-10 px-5 flex flex-col gap-14">
          // TODO: font-size: 40px

            <h1 className="text-4xl text-center"> "Camlet" </h1>
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
        className="col-span-4 bg-blue-400 grid grid-cols-4 gap-y-8 gap-x-6 content-start overflow-y-auto pr-8">
        <header
          className="col-span-4 bg-grey-10 p-3 flex flex-row justify-between items-center rounded-3xl">
          // TODO: font-size: 28px

            <h2 className="text-3xl px-2.5 text-grey-100"> "Home" </h2>
            <div className="flex flex-row items-center gap-6">
              <div className="w-6 h-6 text-grey-100">
                {Icons.questionMark(~width=24.0, ~height=24.0)}
              </div>
              <div className="p-3 bg-gray-100 rounded-full text-grey-100">
                {Icons.notifications(~width=24.0, ~height=24.0)}
              </div>
            </div>
          </header>
        <div className="col-span-4">
          // TODO: 3xl doesn't match 100%

            <div className="text-3xl mb-1"> "Saldo" </div>
            <div className="text-5xl"> "$ 20.000,00" </div>
          </div>
        actionBox
        actionBox
        actionBox
        actionBox
        infoBox
        infoBox
        // TODO: font-size: 32px
        <h2 className="col-span-4 text-4xl"> "Transações" </h2>
        <div className="col-span-4 bg-yellow-400 p-6 flex flex-col gap-16">
          transactionRow
          transactionRow
          transactionRow
        </div>
      </main>
    </div>
  </Page>;
