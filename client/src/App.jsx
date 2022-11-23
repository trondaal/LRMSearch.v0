import CssBaseline from '@mui/material/CssBaseline';
import React from 'react';
import Grid from '@mui/material/Grid';
import ResultView from "./Results/ResultView";
import { useLazyQuery} from '@apollo/client';
import {GET_EXPRESSIONS} from "./api/Queries";
//import Checkbox from '@mui/material/Checkbox';
import SearchBar from "./Search/SearchBar";
import CircularProgress from '@mui/material/CircularProgress';
import FilterList from "./Filters/FilterList";
import Button from '@mui/material/Button';
import {filterState, showFiltersState, selectedState, configState} from './state/state';
import {useRecoilState, useSetRecoilState, useRecoilValue} from 'recoil';
import {selectedVar} from "./api/Cache";
//import OutlinedInput from '@mui/material/OutlinedInput';
//import InputLabel from '@mui/material/InputLabel';
//import MenuItem from '@mui/material/MenuItem';
//import FormControl from '@mui/material/FormControl';
//import ListItemText from '@mui/material/ListItemText';
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
    'Clickable',
    'Formatting',
    'Show URIs'
];



export default function MyApp() {
    const [config, setConfig] = useRecoilState(configState);
    const showFilters = useRecoilValue(showFiltersState);
    const setChecked = useSetRecoilState(filterState);
    const setSelected = useSetRecoilState(selectedState);

    const params = new URLSearchParams(window.location.search)
    const uriquery = params.get("query") || "Hobbit";

    const handleClearFilters = (event) => {
        setChecked([]);
        selectedVar(new Set([]));
    }

    const handleClearSelection = (event) => {
        setSelected([]);
    }

    const handleConfigChange = (event) => {
        setConfig(event.target.value)
        //console.log(event.target.value);
    };


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
                {/*<Grid item xs={2}>
                    <FormControl sx={{ m: 0, width: 200 }}>
                        <InputLabel id="demo-multiple-checkbox-label">Config</InputLabel>
                        <Select
                            labelId="demo-multiple-checkbox-label"
                            id="demo-multiple-checkbox"
                            multiple
                            value={config}
                            onChange={handleConfigChange}
                            input={<OutlinedInput label="Config" />}
                            renderValue={(selected) => ' '}
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
                <Grid xs={3} item justifyContent="flex-end">
                        <Button variant="contained" onClick={handleClearSelection}>Clear selection</Button>
                </Grid>*/}
                <Grid xs={3} item justifyContent="flex-end">
                    {showFilters ? <Button variant="outlined" size="small" onClick={handleClearFilters}>Clear filters</Button> : ""}

                </Grid>
                <Grid item xs={showFilters ? 9 : 9}>
                    {called && loading ? <Grid item xs={9}><CircularProgress /></Grid> : <ResultView results={data ? data.expressions : []}/>}
                </Grid>
                {showFilters ? <Grid item xs={3}>
                    <FilterList results={data ? data.expressions : []}/>
                </Grid> : ""}
            </Grid>
        </React.Fragment>
    );
}