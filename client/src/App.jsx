import CssBaseline from '@mui/material/CssBaseline';
import React, {useState, useMemo, useEffect} from 'react';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import ResultView from "./ResultView";
import Item from './Item';
import { useQuery } from '@apollo/client';
import {GET_RESULTS} from "./queries";
import debounce from 'lodash.debounce';
import {filtersVar} from './Cache';

export default function MyApp() {
    const [query, setQuery] = useState("rowling");

    const { loading, error, data } = useQuery(GET_RESULTS, {
        variables: { query:query, offset: 0 }
    });

    //const [search, { loading, data, error }] = useLazyQuery(GET_RESULTS);
    //const debouncer = useCallback(_.debounce(search, 700), []);

    const changeHandler = (event) => {
        filtersVar([]);
        setQuery(event.target.value);
    };

    const debouncedChangeHandler = useMemo(
        () => debounce(changeHandler, 800)
        , []);

    useEffect(() => {
        return () => {
            debouncedChangeHandler.cancel();
        }
    });

    const isSelected = (exp) => {
        let content = true;
        if (filtersVar().findIndex(f => f.includes("Content")) > -1) {
            content = exp.content.some(e => e.checked)
        }
        let language = true;
        if (filtersVar().findIndex(f => f.includes("Language")) > -1) {
            language = exp.language.some(e => e.checked)
        }
        return content && language
    }

    if (error)
        console.log(error);

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
                            onChange={debouncedChangeHandler}
                        /></Item>
                </Grid>
                {filtersVar().length === 0 ? <ResultView results={data ? data.expressions : []}/> :
                    <ResultView results={data ? data.expressions.filter(exp => isSelected(exp)) : []}/>
                }
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