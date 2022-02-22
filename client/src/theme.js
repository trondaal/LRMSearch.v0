import { createTheme } from '@mui/material/styles';
import { green, purple, blue } from '@mui/material/colors';

export const theme = createTheme({
    palette: {
        primary: {
            main: '#01579b',
            light: '#4f83cc',
            dark: '#002f6c',
        },
        secondary: {
            main: green[500],
        },
    },
    typography: {
        etitle: {
            fontSize: '1.10rem',
            fontWeight: 450,
        },
        wtitle: {
            fontSize: '1.10rem',
            fontWeight: 350,
            fontStyle: 'italic'
        },
        mtitle: {
            fontSize: '1.00rem',
            fontWeight: 450,
        },
        description: {
            fontSize: '0.8rem',
        }
    }
});