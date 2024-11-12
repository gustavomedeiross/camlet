const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./src/**/*.ml"],
    theme: {
        extend: {
            fontFamily: {
                'sans': ['"Kanit"', ...defaultTheme.fontFamily.sans],
            }
        },
    },
    plugins: [],
}

