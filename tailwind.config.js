const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./src/**/*.{ml,re}"],
    theme: {
        extend: {
            fontFamily: {
                'sans': ['"Kanit"', ...defaultTheme.fontFamily.sans],
            },
            // TODO: remove from "extend" so we avoid using colors that are not supposed to be used
            colors: {
                'grey-10': '#FFFFFE',
                'grey-15': '#F1F1F1',
                'grey-20': '#F4F4EF',
                'grey-25': '#EFEFEC',
                'grey-30': '#D7D7D7',
                'grey-50': '#989898',
                'grey-100': '#242521',
                'primary-50': '#DFFF44',
            },

        },
    },
    plugins: [],
}

