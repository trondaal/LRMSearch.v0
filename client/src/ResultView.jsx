import Grid from "@mui/material/Grid";
import ResultList from "./ResultList";
import FilterList from "./FilterList"
import React from "react";
import Item from './Item';
//import {filtersVar} from "./Cache";
import {selectedVar} from "./Cache";

/*const isSelected = (exp) => {
    let content = true;
    if (filtersVar().findIndex(f => f.includes("Content")) > -1) {
        content = exp.content.some(content => content.checked)
    }
    let language = true;
    if (filtersVar().findIndex(f => f.includes("Language")) > -1) {
        language = exp.language.some(language => language.checked)
    }
    let media = true;
    if (filtersVar().findIndex(f => f.includes("Media")) > -1) {
        media = exp.manifestations.some(manifestation => manifestation.media.some(media => media.checked));
    }
    let carrier = true;
    if (filtersVar().findIndex(f => f.includes("Carrier")) > -1) {
        media = exp.manifestations.some(manifestation => manifestation.carrier.some(carrier => carrier.checked));
    }
    return content && language && media && carrier
}*/

export default function ResultView(props) {
    //console.log(props.results)
    return (
        <React.Fragment>
            <Grid item xs={8}>
                <Item>
                    {selectedVar().size === 0 ? <ResultList results={props.results ? props.results.slice(0,30) : []}/> :
                        <ResultList results={props.results ? props.results.filter(exp => exp.checked).slice(0,30) : []}/>
                    }
                </Item>
            </Grid>
            <Grid item xs={4}>
                <FilterList results={props.results}/>
            </Grid>
        </React.Fragment>
    );
}