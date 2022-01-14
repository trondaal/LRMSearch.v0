import Grid from "@mui/material/Grid";
import ResultList from "./ResultList";
import FilterList from "./FilterList"
import React from "react";
import Item from './Item';

export default function ResultView(props) {
    //console.log(props.results)
    return (
        <React.Fragment>
            <Grid item xs={8}>
                <Item>
                    <ResultList results={props.results}/>
                </Item>
            </Grid>
            <Grid item xs={4}>
                <FilterList results={props.results}/>
            </Grid>
        </React.Fragment>
    )

}