import CssBaseline from '@mui/material/CssBaseline';
import React, {useState, useEffect, useMemo} from 'react';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import debounce from 'lodash.debounce';
import ResultView from "./ResultView";
import Item from './Item';
import { ApolloProvider, ApolloClient, InMemoryCache, useLazyQuery } from '@apollo/client';
import {GET_RESULTS} from "./queries";
import { useCallback } from 'react';
import _ from 'lodash';

export default function MyApp() {

    const [search, { called, loading, data, error }] = useLazyQuery(GET_RESULTS);
    const debouncer = useCallback(_.debounce(search, 700), []);

    /*const [query, setQuery] = useState("rowling");

    const changeHandler = (event) => {
        setQuery(event.target.value);
    };

    const debouncedChangeHandler = useMemo(
        () => debounce(changeHandler, 800)
        , []);
    useEffect(() => {
        return () => {
            debouncedChangeHandler.cancel();
        }
    }); */

    if (error)
        console.log(error);

    //console.log(data);


    if (loading) return <p>Loading ...</p>;

    //console.log(data);

    return (
        <React.Fragment>
            <CssBaseline/>
            <Grid container spacing={4} marginTop={2}>
                <Grid item xs={12}>
                    <Item>
                        <TextField
                            fullWidth
                            id="filled-search"
                            label="Search field"
                            type="search"
                            variant="filled"
                            onChange={e => debouncer({ variables: { query: e.target.value, offset: 0 } })}
                        /></Item>
                </Grid>
                <ResultView results={data ? data.expressions : []}/>
            </Grid>
        </React.Fragment>

    );
    /*export default function MyApp() {
        const [search, { loading, error, data, }] = useLazyQuery(GET_RESULTS);
        const debouncer = useCallback(_.debounce(search, 500), []);
        const [q, setQuery] = useState("rowling");

        const changeHandler = (event) => {
            setQuery(event.target.value);
            search({variables: {query: q, offset: 0}});
            console.log("change")
            if (loading) return <p>Loading ...</p>;
            if (error) return `Error! ${error}`;
        };

        const debouncedChangeHandler = useMemo(
            () => _.debounce(changeHandler, 800)
            , []);
        useEffect(() => {
            return () => {
                debouncedChangeHandler.cancel();
            }
        });

        return (
          <React.Fragment>
            <CssBaseline />
            <Grid container spacing={4} marginTop={2}>
              <Grid item xs={12}>
                <Item>
                    <TextField
                        fullWidth
                    id="filled-search"
                    label="Search field"
                    type="search"
                    variant="filled"
                    onChange={e => debouncer({ variables: { query: e.target.value } })}
                /></Item>
              </Grid>
              <Grid item xs={8}>
                <Item>
                    ITEM
                    { <ResultList expressions={data?.expressions && data.expressions}></ResultList> }
                </Item>
              </Grid>
              <Grid item xs={4}>
                <Item>Filters go here</Item>
              </Grid>
            </Grid>
          </React.Fragment>
      );*/
}