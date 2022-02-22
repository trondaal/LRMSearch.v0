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
import {filterState, showFiltersState, selectableState, itemSelectedState, styledState} from './state/state';
import {useRecoilState, useSetRecoilState} from 'recoil';
import {selectedVar} from "./api/Cache";
import OutlinedInput from '@mui/material/OutlinedInput';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import ListItemText from '@mui/material/ListItemText';
import Select from '@mui/material/Select';

// consts for meny item
const ITEM_HEIGHT = 200;
const ITEM_PADDING_TOP = 4;
const MenuProps = {
    PaperProps: {
        style: {
            maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
            width: 200,
        },
    },
};

const choices = [
    'Filters',
    'Selectable',
    'Formatting',
];



export default function MyApp() {
    const [selectable, setSelectable] = useRecoilState(selectableState);
    const [showFilters, setShowFilters] = useRecoilState(showFiltersState);
    const setChecked = useSetRecoilState(filterState);
    const setItemsSelected = useSetRecoilState(itemSelectedState);
    const [styled, setStyled] = useRecoilState(styledState);

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

    const handleSetStyled = (event) => {
        console.log(event.target.checked)
        setStyled(event.target.checked);
    }

    const [config, setConfig] = React.useState([]);

    const handleConfigChange = (event) => {
        const {
            target: { value },
        } = event;
        setConfig(
            // On autofill we get a stringified value.
            typeof value === 'string' ? value.split(',') : value,
        );
    };


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
                    {/*F:
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
                    <Checkbox
                        checked={styled}
                        onChange={handleSetStyled}
                    ></Checkbox>*/}
                    <FormControl sx={{ m: 0, width: 200 }}>
                        <InputLabel id="demo-multiple-checkbox-label">Config</InputLabel>
                        <Select
                            labelId="demo-multiple-checkbox-label"
                            id="demo-multiple-checkbox"
                            multiple
                            value={config}
                            onChange={handleConfigChange}
                            input={<OutlinedInput label="Config" />}
                            renderValue={(selected) => selected.join(', ')}
                            MenuProps={MenuProps}
                        >
                            {choices.map((name) => (
                                <MenuItem key={name} value={name}>
                                    <Checkbox checked={config.indexOf(name) > -1} />
                                    <ListItemText primary={name} />
                                </MenuItem>
                            ))}
                        </Select>
                    </FormControl>
                </Grid>
                <Grid xs={2} item justifyContent="flex-end">
                        <Button variant="contained" onClick={handleClearSelection}>Clear selection</Button>
                </Grid>
                <Grid xs={3} item justifyContent="flex-end">
                    {showFilters ? <Button variant="contained" onClick={handleClearFilters}>Clear filters</Button> : ""}

                </Grid>
                <Grid item xs={showFilters ? 8 : 8}>
                    {called && loading ? <Grid item xs={8}><CircularProgress /></Grid> : <ResultView results={data ? data.expressions : []}/>}
                </Grid>
                {showFilters ? <Grid item xs={2}>
                    <FilterList results={data ? data.expressions : []}/>
                </Grid> : ""}
            </Grid>
        </React.Fragment>
    );
}