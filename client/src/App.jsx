import CssBaseline from '@mui/material/CssBaseline';
import React from 'react';
import Grid from '@mui/material/Grid';
import ResultList from "./Results/ResultView";
import { useLazyQuery} from '@apollo/client';
import {GET_EXPRESSIONS} from "./api/Queries";
import SearchBar from "./Search/SearchBar";
import CircularProgress from '@mui/material/CircularProgress';
import FilterList from "./Filters/FilterList";
import Button from '@mui/material/Button';
import {filterState, showFiltersState, selectedState, configState} from './state/state';
import {useRecoilState, useSetRecoilState, useRecoilValue} from 'recoil';
import {selectedVar} from "./api/Cache";

function compareExpressions(a, b) {
    if (b.ranking === -1 && a.ranking === -1){
        return b.score - a.score;
    }else {
        return b.ranking - a.ranking;
    }
}

export default function MyApp() {
    //const [config, setConfig] = useRecoilState(configState);
    const showFilters = useRecoilValue(showFiltersState);
    const setChecked = useSetRecoilState(filterState);
   // const setSelected = useSetRecoilState(selectedState);
    //const params = new URLSearchParams(window.location.search)

    const handleClearFilters = (event) => {
        setChecked([]);
        selectedVar(new Set([]));
    }

    const [search, { loading, data, error, called }] = useLazyQuery(GET_EXPRESSIONS);

    if (error)
        console.log(error);

    return (
        <React.Fragment>
            <CssBaseline/>
            <Grid container spacing={3} marginTop={1} paddingLeft={5} paddingRight={5} >
                <Grid item xs={9}>
                    <SearchBar search={search}/>
                </Grid>
                <Grid xs={3} item justifyContent="flex-end">
                    {showFilters ? <Button variant="outlined" size="small" onClick={handleClearFilters}>Clear filters</Button> : ""}
                </Grid>
                <Grid item xs={showFilters ? 9 : 9}>
                    {called && loading ? <Grid item xs={9}><CircularProgress /></Grid> : <ResultList results={data ? [...data.expressionsFulltextExpressions].sort(compareExpressions) : []}/>}
                </Grid>
                {showFilters ? <Grid item xs={3}>
                    <FilterList results={data ? data.expressionsFulltextExpressions : []}/>
                </Grid> : ""}
            </Grid>
        </React.Fragment>
    );
}