import Grid from "@mui/material/Grid";
import ResultList from "./ResultList";
import FilterList from "../Filters/FilterList"
import React from "react";
import Item from '../Item';
//import {filtersVar} from "./Cache";
import {selectedVar} from "../api/Cache";

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
    console.log(props.checkboxes);
    return (
         <Item>
                {selectedVar().size === 0 ? <ResultList results={props.results ? props.results : []} checkboxes={props.checkboxes}/> :
                    <ResultList results={props.results ? props.results.filter(exp => exp.checked) : []} checkboxes={props.checkboxes}/>
                }
            </Item>
    );
}