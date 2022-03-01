import React from 'react';
import Typography from "@mui/material/Typography";
import ListItemText from "@mui/material/ListItemText";
import "./ResultList.css";
import ListItemButton from '@mui/material/ListItemButton';
import ListItem from '@mui/material/ListItem';
import {itemsSelectedState, selectableState} from '../state/state';
import {useRecoilState} from 'recoil';

function isEmpty(str) {
    return (!str || str.length === 0 );
}

export default function Manifestation(props){
    const [itemsSelected, setItemsSelected] = useRecoilState(itemsSelectedState)
    const [selectable] = useRecoilState(selectableState)
    const {title, subtitle, numbering, part, responsibility, extent, edition, uri} = props.manifestation;
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

    const handleClick = () => {
        console.log(itemsSelected);
        const pos = itemsSelected.indexOf(uri)
        if (pos === -1) {
            setItemsSelected([...itemsSelected, uri]);
        } else {
            setItemsSelected([...itemsSelected.slice(0, pos), ...itemsSelected.slice(pos + 1)]);
        }
    };

    const description = () => {
        return <ListItemText className={itemsSelected.includes(uri) ? "selected" : ""}
            primary={<React.Fragment>
            <Typography color="primary.main" variant="mtitle.light" className={"mtitle"}>{statement.join(" / ")}</Typography>
            {extent && <Typography variant="body2"  >Extent: {extent}</Typography>}
            <Typography variant="body2"  >Published: {metadata.join(", ")}</Typography>
            </React.Fragment>}
        >
        </ListItemText>
    }

    return selectable ? <ListItemButton alignItems="flex-start" onClick={handleClick}sx={{pl: 9, pr: 0}}>
                            {description()}
                        </ListItemButton>
                        :
                        <ListItem alignItems="flex-start" sx={{pl: 9, pr: 0}}>
                            {description()}
                        </ListItem>
}