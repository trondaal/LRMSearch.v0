import React from 'react';
import List from '@mui/material/List';
import ListItem from "@mui/material/ListItem";
import Typography from "@mui/material/Typography";
import ListItemAvatar from "@mui/material/ListItemAvatar";
import Avatar from "@mui/material/Avatar";
import {grey} from "@mui/material/colors";
import ListItemText from "@mui/material/ListItemText";
import IconTypes from "./IconTypes";
import Paper from "@mui/material/Paper";
import "./ResultList.css";
import {groupBy} from "lodash";
import {ListItemSecondaryAction} from "@mui/material";
import Manifestation from "./Manifestation";
import Expression from "./Expression";



export default function ResultList(props){
    //console.log("Resultlist: " + props.checkboxes);
    return (<List sx={{ width: '100%', bgcolor: 'background.paper' }} className={"expressionlist"}>
        {props.results && props.results.map(x => (<Expression expression={x} key={x.uri} checkboxes={props.checkboxes}/>))}
    </List>);
}
