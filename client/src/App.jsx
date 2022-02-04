import CssBaseline from '@mui/material/CssBaseline';
import React, {useState, useMemo, useEffect} from 'react';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import ResultView from "./Results/ResultView";
import Item from './Item';
import { useQuery , useLazyQuery} from '@apollo/client';
import {GET_RESULTS} from "./api/Queries";
import debounce from 'lodash.debounce';
import {selectedVar} from './api/Cache';
import Checkbox from '@mui/material/Checkbox';
import FormGroup from '@mui/material/FormGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormControl from '@mui/material/FormControl';
import FormLabel from '@mui/material/FormLabel';
import Box from '@mui/material/Box';
import SearchBar from "./SearchBar";
import CircularProgress from '@mui/material/CircularProgress';
import ResultList from "./Results/ResultList";
import FilterList from "./Filters/FilterList";

export default function MyApp() {
    //const [searchExpression, setSearchExpression] = useState("Rowling");
    const [query, setQuery] = useState("Harry Potter");
    const [checkboxes, setCheckboxes] = useState(false);

    const handleChange = (event) => {
        //console.log(event.target.checked);
        setCheckboxes(event.target.checked);
    };

    /*const { loading, error, data } = useQuery(GET_RESULTS, {
        variables: { query:query, offset: 0 }
    });*/

    const [search, { loading, data, error, called }] = useLazyQuery(GET_RESULTS);
    //const debouncer = useCallback(_.debounce(search, 700), []);

    /*const changeHandler = (event) => {
        if (event.key === 'Enter') {
            selectedVar(new Set());
            //console.log("Enter")
            search({ variables: { query: query } })
        }
    };*/

    /*const debouncedChangeHandler = useMemo(
        () => debounce(changeHandler, 800)
        , []);

    useEffect(() => {
        return () => {
            debouncedChangeHandler.cancel();
        }
    });*/

    if (error)
        console.log(error);


    return (
        <React.Fragment>
            <CssBaseline/>
            <Grid container spacing={3} marginTop={1}  marginLeft={1} marginRight={1}>
                <Grid item xs={8}>
                        <SearchBar search={search}/>
                </Grid>
                <Grid item xs={1}>
                    <div>Filters:</div>
                    <Checkbox  defaultChecked />
                </Grid>
                <Grid item xs={1}>
                        <div>Checkboxes:</div>
                        <Checkbox
                            checked={checkboxes}
                            onChange={handleChange}>
                        </Checkbox>
                </Grid>
                <Grid item xs={2}>
                    <div>Styled:</div>
                        <Checkbox  defaultChecked />
                </Grid>
                <Grid item xs={8}>
                    {called && loading ? <Grid item xs={12}><CircularProgress /></Grid> : <ResultView checkboxes={checkboxes} results={data ? data.expressions : []}/>}
                </Grid>
                <Grid item xs={4} visibility={false}>
                    <FilterList results={data ? data.expressions : []}/>
                </Grid>
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