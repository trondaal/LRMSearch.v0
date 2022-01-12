import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import reportWebVitals from './reportWebVitals';
import '@fontsource/roboto/300.css';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/500.css';
import '@fontsource/roboto/700.css';
import { ApolloProvider, ApolloClient, } from '@apollo/client';
import {FilterContextProvider} from "./FilterContext";
import {Cache} from "./Cache"

const client = new ApolloClient({
    uri: 'http://localhost:8080/graphql',
    cache: Cache
});

ReactDOM.render(
  <React.StrictMode>
      <FilterContextProvider>
          <ApolloProvider client={client}>
              <App />
          </ApolloProvider>
      </FilterContextProvider>
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
