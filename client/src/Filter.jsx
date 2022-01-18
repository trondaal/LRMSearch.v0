import React from 'react';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Checkbox from '@mui/material/Checkbox';
import Collapse from '@mui/material/Collapse';
import ExpandLess from '@mui/icons-material/ExpandLess';
import ExpandMore from '@mui/icons-material/ExpandMore';
import {filtersVar} from './Cache';
import { useReactiveVar } from '@apollo/client';

const handleToggle = (filterkey) => () => {
    console.log("TOGGLE: " + filterkey);
    const filters = filtersVar();
    const idx = filters.indexOf(filterkey)
    //console.log(filters);

    if (idx === -1) {
        filtersVar([...filters, filterkey]);
    } else {
        filtersVar([...filters.slice(0, idx), ...filters.slice(idx + 1)]);
    }
    //filtersVar([...filters, filter]);
    //console.log(filters);
};


export default function Filter(props) {

    // for open close collapsible
    const [open, setOpen] = React.useState(false);

    const handleClick = () => {
        setOpen(!open);
    };

    const filters = useReactiveVar(filtersVar);

    //console.log(props.filters)

    return (<React.Fragment>
        <ListItemButton onClick={handleClick}>
                <ListItemText primary={props.header} />
                {open ? <ExpandLess /> : <ExpandMore />}
            </ListItemButton>
            <Collapse in={open} timeout="auto" unmountOnExit>
                <List component="div" dense>
                    {props.filters.map((entry) => {
                        const {uri, value, count, category, target} = entry;
                        let filterkey = target + "+" + category + "+" + uri;
                        const labelId = `checkbox-list-label-${filterkey}`;
                        return (
                            <ListItem
                                key={filterkey}
                                disablePadding
                            >
                                <ListItemButton role={undefined} onClick={handleToggle(filterkey)} dense sx={{ my: -1 }}>
                                    <ListItemIcon>
                                        <Checkbox
                                            edge="start"
                                            checked={filters.indexOf(filterkey) !== -1}
                                            tabIndex={-1}
                                            disableRipple
                                            inputProps={{ 'aria-labelledby': labelId }}
                                        />
                                    </ListItemIcon>
                                    <ListItemText id={labelId} primary={`${value} (${count})`} />
                                </ListItemButton>
                            </ListItem>
                        );
                    })}
                </List>
            </Collapse>
        </React.Fragment>
    );
}

