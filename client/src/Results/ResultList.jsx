import React from 'react';
import List from '@mui/material/List';
import "./ResultList.css";
import Expression from "./Expression";

export default function ResultList(props){
    return (<List sx={{ width: '100%', bgcolor: 'background.paper' }} className={"expressionlist"}>
        {props.results && props.results.map(x => (<Expression expression={x.expression} key={x.expression.uri} checkboxes={props.checkboxes}/>))}
    </List>);
}
