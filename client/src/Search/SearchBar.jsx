
import React, {useState, useEffect} from 'react';
import TextField from '@mui/material/TextField';
import {selectedVar, rankingVar} from '../api/Cache';
import stopwords from './stopwords'

export default function SearchBar(props) {
    //const query = querystring.parse(window.location.search);
    const params = new URLSearchParams(window.location.search)
    const uriquery = params.get("query") || "Time for a tiger";
    //console.log(params.get("query"));
    //console.log(uriquery);
    const [query, setQuery] = useState(sessionStorage.getItem('query') ? sessionStorage.getItem('query') : uriquery);

    const {search} = props;

    const ranking = JSON.parse(localStorage.getItem(query.toLowerCase()));
    if (ranking){
        rankingVar([...ranking]);
    }else{
        rankingVar([]);
    }

    const changeHandler = (event) => {
        if (event.key === 'Enter') {
            selectedVar(new Set());
            //retrieve existing ranking from localstorage and insert into rankingVar
            //or set to empty array if no ranking exists
            const ranking = JSON.parse(localStorage.getItem(query));
            if (ranking){
                rankingVar([...ranking]);
            }else{
                rankingVar([]);
            }
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
        }, []
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