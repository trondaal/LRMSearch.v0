import React from 'react';
import List from '@mui/material/List';
import "./ResultList.css";
import Expression from "./Expression";

export default function ResultList(props){
    return (<List sx={{ width: '100%', bgcolor: 'background.paper' }} className={"expressionlist"}>
        {props.results && props.results.map(x => (<Expression expression={x} key={x.uri} checkboxes={props.checkboxes}/>))}
    </List>);
}
