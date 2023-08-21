import React from 'react';
import { createRoot } from 'react-dom/client';
//import ReactDOM from 'react-dom';
import App from './App';
import '@fontsource/roboto/300.css';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/500.css';
import '@fontsource/roboto/700.css';
import { ApolloProvider, ApolloClient, } from '@apollo/client';
import {Cache} from "./api/Cache"
//import {HashRouter as Router, Routes, Route} from "react-router-dom";
import { ThemeProvider } from '@mui/material/styles';
import {theme} from "./theme";
import {
    RecoilRoot,
} from 'recoil';

require('dotenv').config()

console.log("URI = " + process.env.REACT_APP_BACKEND);

const client = new ApolloClient({
    //uri: 'http://localhost:4444/graphql',
    uri: process.env.REACT_APP_BACKEND,
    cache: Cache
});

const container = document.getElementById('root');
const root = createRoot(container);

root.render(
  <React.StrictMode>
      <RecoilRoot>
          <ApolloProvider client={client}>
              <ThemeProvider theme={theme}>
                  <App/>
              </ThemeProvider>
          </ApolloProvider>
      </RecoilRoot>
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
//reportWebVitals();
