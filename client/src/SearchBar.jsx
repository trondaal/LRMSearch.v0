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


export default function SearchBar(props) {
    const [query, setQuery] = useState("Harry Potter");

    const changeHandler = (event) => {
        if (event.key === 'Enter') {
            selectedVar(new Set());
            props.search({ variables: { query: query.split(" ").join(" AND ") } })
        }else{
            setQuery(event.target.value)
        }
    };
    return <TextField
        id="filled-search"
        fullWidth
        label="Search field"
        type="search"
        variant="filled"
        value={query}
        onKeyPress={changeHandler}
        onChange={changeHandler}
    />
}