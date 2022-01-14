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


export default function Filter(props) {

    // for open close collapsible
    const [open, setOpen] = React.useState(false);

    const handleClick = () => {
        setOpen(!open);
    };

    return (<React.Fragment>
        <ListItemButton onClick={handleClick}>
                <ListItemText primary={props.header} />
                {open ? <ExpandLess /> : <ExpandMore />}
            </ListItemButton>
            <Collapse in={open} timeout="auto" unmountOnExit>
                <List component="div" dense>
                    {props.filters.map((entry) => {
                        const {uri, value, count, category, target} = entry;
                        //const filterkey = uri + "/" + category;
                        const labelId = `checkbox-list-label-${uri + "/" + category}`;
                        return (
                            <ListItem
                                key={uri}
                                disablePadding
                            >
                                <ListItemButton role={undefined} onClick={props.handleToggle({uri: uri, value: value, category: category, target: target})} dense sx={{ my: -1 }}>
                                    <ListItemIcon>
                                        <Checkbox
                                            edge="start"
                                            checked={props.checked.findIndex(x => x.uri === uri && x.category === category ) !== -1}
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

