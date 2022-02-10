import React from 'react';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Checkbox from '@mui/material/Checkbox';

export default function Filter(props) {
    //const [selected, setSelected] = useState(0);

    const {key, value, category, selection} = props.entry;
    const labelId = `checkbox-list-label-${key}`;
    const available = props.getAvailable(category, selection).length;
    let disabled = false;
    if ((available === 0 && props.checked.length > 0) && props.checked.indexOf(key) === -1){
        disabled=true;
    }
    return (
        <ListItem
            key={key}
            disablePadding
        >
            <ListItemButton role={undefined} onClick={props.handleToggle(key)} dense sx={{ my: -1 }} disabled={disabled}>
                <ListItemIcon>
                    <Checkbox
                        edge="start"
                        checked={props.checked.indexOf(key) !== -1}
                        tabIndex={-1}
                        disableRipple
                        inputProps={{ 'aria-labelledby': labelId }}
                    />
                </ListItemIcon>
                <ListItemText id={labelId} primary={`${value} (${available})`} />
            </ListItemButton>
        </ListItem>
    );
}