import React from 'react';
import ReactDOM from 'react-dom';
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

const client = new ApolloClient({
    //uri: 'http://localhost:8080/graphql',
    uri: 'http://dijon.idi.ntnu.no:8080/graphql',
    cache: Cache
});

ReactDOM.render(
  <React.StrictMode>
      <RecoilRoot>
          <ApolloProvider client={client}>
              <ThemeProvider theme={theme}>
                  <App/>
              </ThemeProvider>
          </ApolloProvider>
      </RecoilRoot>
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
//reportWebVitals();
