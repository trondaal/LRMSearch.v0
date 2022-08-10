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
import {filterState, showFiltersState} from './state/state';
import {useSetRecoilState, useRecoilValue} from 'recoil';
import {selectedVar} from "./api/Cache";
//import OutlinedInput from '@mui/material/OutlinedInput';
//import InputLabel from '@mui/material/InputLabel';
//import MenuItem from '@mui/material/MenuItem';
//import FormControl from '@mui/material/FormControl';
//import ListItemText from '@mui/material/ListItemText';
//import Select from '@mui/material/Select';
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';


// consts for meny item
//const ITEM_HEIGHT = 200;
//const ITEM_PADDING_TOP = 4;
/*const MenuProps = {
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
];*/

function TabPanel(props) {
    const { children, value, index, ...other } = props;

    return (
        <div
            role="tabpanel"
            hidden={value !== index}
            id={`simple-tabpanel-${index}`}
            aria-labelledby={`simple-tab-${index}`}
            {...other}
        >
            {value === index && (<div>{children}</div>)}
        </div>
    );
}

export default function MyApp() {
    //const [config, setConfig] = useRecoilState(configState);
    const showFilters = useRecoilValue(showFiltersState);
    const setChecked = useSetRecoilState(filterState);
    //const setSelected = useSetRecoilState(selectedState);

    const handleClearFilters = (event) => {
        setChecked([]);
        selectedVar(new Set([]));
    }

    /*
    const handleClearSelection = (event) => {
        setSelected([]);
    }

    const handleConfigChange = (event) => {
        setConfig(event.target.value)
        //console.log(event.target.value);
    };*/

    const [tabValue, setTabValue] = React.useState(1);

    const handleTabChange = (event, newValue) => {
        setTabValue(newValue);
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
                <Grid xs={3} item justifyContent="flex-end">
                    {showFilters ? <Button variant="contained" onClick={handleClearFilters}>Clear filters</Button> : ""}

                </Grid>
                <Grid item xs={showFilters ? 9 : 9}>
                    <Tabs
                        value={tabValue}
                        onChange={handleTabChange}
                        textColor="secondary"
                        indicatorColor="secondary"
                        aria-label="secondary tabs example"
                    >
                        <Tab label="Work View"/>
                        <Tab label="Expression View"/>
                        <Tab label="Manifestation View"/>
                    </Tabs>
                    <TabPanel value={tabValue} index={0}>
                        Item One
                    </TabPanel>
                    <TabPanel value={tabValue} index={1}>
                        Item Two
                    </TabPanel>
                    <TabPanel value={tabValue} index={2}>
                        Item Three
                    </TabPanel>
                    {called && loading ? <Grid item xs={9}><CircularProgress /></Grid> : <ResultView results={data ? data.expressions.slice(0,30) : []}/>}
                </Grid>
                {showFilters ? <Grid item xs={3}>
                    <FilterList results={data ? data.expressions.slice(0,30) : []}/>
                </Grid> : ""}
            </Grid>
        </React.Fragment>
    );
}