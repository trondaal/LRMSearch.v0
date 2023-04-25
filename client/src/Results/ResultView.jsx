import ResultList from "./ResultList";
import React from "react";
import Item from './Item';
import {selectedVar} from "../api/Cache";

export default function ResultView(props) {

    console.log(props.results);

    return (
         <Item>
                {selectedVar().size === 0 ? <ResultList results={props.results ? props.results : []} /> :
                    <ResultList results={props.results ? props.results.filter(exp => exp.checked) : []} />
                }
         </Item>
    );
}