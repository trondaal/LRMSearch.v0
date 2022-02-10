import CssBaseline from '@mui/material/CssBaseline';
import React, {useState} from 'react';
import Grid from '@mui/material/Grid';
import ResultView from "./Results/ResultView";
import { useLazyQuery} from '@apollo/client';
import {GET_RESULTS} from "./api/Queries";
import Checkbox from '@mui/material/Checkbox';
import SearchBar from "./Search/SearchBar";
import CircularProgress from '@mui/material/CircularProgress';
import FilterList from "./Filters/FilterList";
import {useParams} from "react-router-dom";

export default function MyApp() {
    const params = useParams();
    console.log(params);

    const [checkboxes, setCheckboxes] = useState(false);
    const [filters, setFilters] = useState(true);

    const handleCheckboxesChange = (event) => {
        setCheckboxes(event.target.checked);
    };

    const handleFiltersChange = (event) => {
        setFilters(event.target.checked);
    };

    const [search, { loading, data, error, called }] = useLazyQuery(GET_RESULTS);

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
                    <Checkbox
                        checked={filters}
                        onChange={handleFiltersChange}>
                    </Checkbox>
                </Grid>
                <Grid item xs={1}>
                        <div>Checkboxes:</div>
                        <Checkbox
                            checked={checkboxes}
                            onChange={handleCheckboxesChange}>
                        </Checkbox>
                </Grid>
                <Grid item xs={2}>
                    <div>Styled:</div>
                        <Checkbox  defaultChecked />
                </Grid>
                <Grid item xs={filters ? 8 : 12}>
                    {called && loading ? <Grid item xs={12}><CircularProgress /></Grid> : <ResultView checkboxes={checkboxes} results={data ? data.expressions : []}/>}
                </Grid>
                {filters ? <Grid item xs={4}>
                    <FilterList results={data ? data.expressions : []}/>
                </Grid> : ""}
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