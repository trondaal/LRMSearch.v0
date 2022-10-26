import React from 'react';
import Typography from "@mui/material/Typography";
import ListItemText from "@mui/material/ListItemText";
import "./ResultList.css";
import ListItemButton from '@mui/material/ListItemButton';
import ListItem from '@mui/material/ListItem';
import {selectedState, clickableState} from '../state/state';
import {useRecoilState} from 'recoil';

function isEmpty(str) {
    return (!str || str.length === 0 );
}

export default function Manifestation(props){
    const [selected, setSelected] = useRecoilState(selectedState)
    const [clickable] = useRecoilState(clickableState)
    const {title, subtitle, numbering, part, responsibility, extent, edition, uri, partnote} = props.manifestation;
    const {distribution, production, publication, manufacture, expressions} = props.manifestation;
    console.log(expressions.length)
    const statement = [];
    if (!isEmpty(title) && !isEmpty(subtitle)){
        statement.push(title + " : " + subtitle)
    }else if (!isEmpty(title)){
        statement.push(title);
    }
    if (!isEmpty(numbering)) statement.push(numbering);
    if (!isEmpty(part)) statement.push(part);
    if (!isEmpty(responsibility)) statement.push(responsibility);

    const published = [];
    if (!isEmpty(publication)) published.push(publication);
    if (!isEmpty(production)) published.push(production);
    if (!isEmpty(distribution)) published.push(distribution);
    if (!isEmpty(manufacture)) published.push(manufacture);

    //if (!isEmpty(identifier)) published.push(identifier);
    //if (!isEmpty(uri)) published.push(uri);

    const handleClick = () => {
        //console.log(selected);
        const pos = selected.indexOf(uri)
        if (pos === -1) {
            setSelected([...selected, uri]);
        } else {
            setSelected([...selected.slice(0, pos), ...selected.slice(pos + 1)]);
        }
    };

    const description = () => {
        return <ListItemText className={selected.includes(uri) ? "selected" : "manifestation"}
            primary={<React.Fragment>
            <Typography color="primary.main" variant="mtitle.light" className={"mtitle"}>{statement.join(" / ")}</Typography>
            {extent && <Typography variant="body2"  >Extent: {extent}</Typography>}
            {edition && <Typography variant="body2"  >Edition: {edition}</Typography>}
            {published.length > 0 && <Typography variant="body2">Published: {published.join(", ")}</Typography>}
            {partnote && <Typography variant="body2">In: {partnote}</Typography>}
                {(expressions.length) > 1 && <Typography variant="caption">
                    <details>
                        <summary>Contents</summary>
                        {expressions.map(x => <Typography component="div" variant="caption" key={x.title}>{x.title}</Typography>)}
                    </details>

                </Typography>}
            </React.Fragment>}
        >
        </ListItemText>
    }

    return clickable ? <ListItemButton alignItems="flex-start" onClick={handleClick}sx={{pl: 9, pr: 0}}>
                            {description()}
                        </ListItemButton>
                        :
                        <ListItem alignItems="flex-start" sx={{pl: 9, pr: 0}}>
                            {description()}
                        </ListItem>
}