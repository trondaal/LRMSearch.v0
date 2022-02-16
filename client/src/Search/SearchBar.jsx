
import React, {useState, useEffect} from 'react';
import TextField from '@mui/material/TextField';
import {selectedVar} from '../api/Cache';
import stopwords from './stopwords'

export default function SearchBar(props) {

    const [query, setQuery] = useState(sessionStorage.getItem('query') ? sessionStorage.getItem('query') : "Harry Potter");

    const {search} = props;

    const changeHandler = (event) => {
        if (event.key === 'Enter') {
            selectedVar(new Set());
            sessionStorage.setItem('query', query);
            props.search({ variables: { query: query.split(" ").filter((word) => !stopwords.includes(word.toLowerCase())).join(" AND ") } })
        }else{
            setQuery(event.target.value)
        }
    };

    useEffect(() => {
        if (sessionStorage.getItem('query') === null){
            sessionStorage.setItem('query', query);
        }else{
            setQuery(sessionStorage.getItem('query'))
        }
        search({ variables: { query: query.split(" ").join(" AND ") } });
        } , [search]

    );

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