import ResultList from "./ResultList";
import React from "react";
import Item from './Item';
import {selectedVar} from "../api/Cache";
import Paper from "@mui/material/Paper";

export default function ResultView(props) {

    return (
         <Item>
                {selectedVar().size === 0 ? <ResultList results={props.results ? props.results : []} /> :
                    <ResultList results={props.results ? props.results.filter(exp => exp.checked) : []} />
                }
         </Item>
    );
}