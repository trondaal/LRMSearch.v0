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
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import {filterState, showFiltersState, selectableState, itemSelectedState} from './state/state';
import {useRecoilState, useSetRecoilState} from 'recoil';
import {selectedVar} from "./api/Cache";


export default function MyApp() {
    const [selectable, setSelectable] = useRecoilState(selectableState);
    const [showFilters, setShowFilters] = useRecoilState(showFiltersState);
    const setChecked = useSetRecoilState(filterState);
    const setItemsSelected = useSetRecoilState(itemSelectedState);

    const handleSelectableChange = (event) => {
        setSelectable(event.target.checked);
        setItemsSelected([]);
    };

    const handleShowFiltersChange = (event) => {
        setShowFilters(event.target.checked);
    };

    const handleClearFilters = (event) => {
        setChecked([]);
        selectedVar(new Set([]));
    }

    const handleClearSelection = (event) => {
        setItemsSelected([]);
    }


    const [search, { loading, data, error, called }] = useLazyQuery(GET_RESULTS);

    if (error)
        console.log(error);

    return (
        <React.Fragment>
            <CssBaseline/>
            <Grid container spacing={3} marginTop={1}  marginLeft={1} marginRight={1}>
                <Grid item xs={4}>
                        <SearchBar search={search}/>
                </Grid>
                <Grid item xs={2}>
                    F:
                    <Checkbox
                        checked={showFilters}
                        onChange={handleShowFiltersChange}>
                    </Checkbox>
                    S:
                    <Checkbox
                        checked={selectable}
                        onChange={handleSelectableChange}>
                    </Checkbox>
                    P:
                        <Checkbox  defaultChecked />
                </Grid>
                <Grid item xs={2}>
                        <Button variant="contained" onClick={handleClearSelection}>Clear selection</Button>
                </Grid>
                <Grid item xs={4}>
                    {showFilters ? <Button variant="contained" onClick={handleClearFilters}>Clear filters</Button> : ""}

                </Grid>
                <Grid item xs={showFilters ? 8 : 8}>
                    {called && loading ? <Grid item xs={8}><CircularProgress /></Grid> : <ResultView results={data ? data.expressions : []}/>}
                </Grid>
                {showFilters ? <Grid item xs={4}>
                    <FilterList results={data ? data.expressions : []}/>
                </Grid> : ""}
            </Grid>
        </React.Fragment>
    );
}