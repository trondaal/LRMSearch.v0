import React from 'react';
import ListItem from "@mui/material/ListItem";
import Typography from "@mui/material/Typography";
import ListItemText from "@mui/material/ListItemText";
import "./ResultList.css";
import {groupBy} from "lodash";
import {ListItemSecondaryAction} from "@mui/material";
import Checkbox from '@mui/material/Checkbox';

function isEmpty(str) {
    return (!str || str.length === 0 );
}

export default function Manifestation(props){
    //console.log("Manifestation: " + props.checkboxes);
    const {title, subtitle, numbering, part, responsibility, extent, edition, identifier} = props.manifestation;
    const {distributionplace, distributor, distributiondate, publicationdate, publicationplace, publisher, productionplace, producer, productiondate, manufactureplace, manufacturer, manufacturedate} = props.manifestation;
    const statement = [];
    if (!isEmpty(title) && !isEmpty(subtitle)){
        statement.push(title + " : " + subtitle)
    }else if (!isEmpty(title)){
        statement.push(title);
    }
    if (!isEmpty(numbering)) statement.push(numbering);
    if (!isEmpty(part)) statement.push(part);
    if (!isEmpty(responsibility)) statement.push(responsibility);

    const metadata = [];
    //if (!isEmpty(extent)) metadata.push(extent);

    if (!isEmpty(distributionplace)) metadata.push(distributionplace);
    if (!isEmpty(distributor)) metadata.push(distributor);
    if (!isEmpty(distributiondate)) metadata.push(distributiondate);

    if (!isEmpty(publicationplace)) metadata.push(publicationplace);
    if (!isEmpty(publisher)) metadata.push(publisher);
    if (!isEmpty(publicationdate)) metadata.push(publicationdate);

    if (!isEmpty(productionplace)) metadata.push(productionplace);
    if (!isEmpty(producer)) metadata.push(producer);
    if (!isEmpty(productiondate)) metadata.push(productiondate);

    if (!isEmpty(manufactureplace)) metadata.push(manufactureplace);
    if (!isEmpty(manufacturer)) metadata.push(manufacturer);
    if (!isEmpty(manufacturedate)) metadata.push(manufacturedate);

    if (!isEmpty(edition)) metadata.push(edition);

    //if (!isEmpty(identifier)) metadata.push(identifier);
    //if (!isEmpty(uri)) metadata.push(uri);

    return <ListItem alignItems="flex-start"
                     disablePadding
                     sx={{
                         width: '80%',
                         pl: 10,
                         pb: 1
                     }}
    >
        <ListItemText
            primary={<div className={"manifestation"}>
                <Typography color={"steelblue"} variant="subtitle2" className={"manifestationtitle"}>{statement.join(" / ")}</Typography>
                {extent && <Typography color={"dimgray"} variant="body2" className={"manifestationtitle"}>Extent: {extent}</Typography>}
                <Typography color={"dimgray"} variant="body2" className={"manifestationtitle"}>Published: {metadata.join(", ")}</Typography>
            </div>}>
        </ListItemText>
        {props.checkboxes ?
            <ListItemSecondaryAction
                sx={{top: "0%", marginTop: "17px", width: '20%', textAlign: 'left', alignItems: 'left'}}>
                <Checkbox
                    sx={{pl: 0}}
                    edge="end"
                    checked={false}

                />
            </ListItemSecondaryAction>
            : ""
        }
    </ListItem>
}