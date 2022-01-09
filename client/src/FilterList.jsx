import React, {useContext}from 'react';
import List from '@mui/material/List';
import ListSubheader from '@mui/material/ListSubheader';
import Filter from './Filter';
import {FilterContext} from "./FilterContext";



export default function FilterList(props) {

    const [checked, handleToggle] = useContext(FilterContext);

    //const [checked, setChecked] = React.useState([0]);

    /*const handleToggle = (value) => () => {
        const currentIndex = checked.indexOf(value);
        const newChecked = [...checked];

        if (currentIndex === -1) {
            newChecked.push(value);
        } else {
            newChecked.splice(currentIndex, 1);
        }

        setChecked(newChecked);
        //console.log(newChecked);
    };*/


    const roles = [...new Set(props.filters.filter(entry => entry.target === 'Person').map(x => x.category))].sort();

    //console.log(roles);

    return (<React.Fragment>
        <List
            sx={{ width: '100%', maxWidth: 360, bgcolor: 'background.paper' }}
            component="nav"
            aria-labelledby="nested-list-subheader"
            subheader={
                <ListSubheader component="div" id="nested-list-subheader">
                    Categories
                </ListSubheader>
            }
        >
        <Filter filters={props.filters.filter(entry => entry.category === 'Language')} checked={checked} handleToggle={handleToggle} header={"Language"}/>
        <Filter filters={props.filters.filter(entry => entry.category === 'Content')} checked={checked} handleToggle={handleToggle} header={"Content type"}/>
        <Filter filters={props.filters.filter(entry => entry.category === 'Media')} checked={checked} handleToggle={handleToggle} header={"Media type"}/>
        <Filter filters={props.filters.filter(entry => entry.category === 'Carrier')} checked={checked} handleToggle={handleToggle} header={"Type of carrier"}/>
        </List>
    <List
        sx={{ width: '100%', maxWidth: 360, bgcolor: 'background.paper' }}
        component="nav"
        aria-labelledby="nested-list-subheader"
        subheader={
            <ListSubheader component="div" id="nested-list-subheader">
                Names
            </ListSubheader>
        }
    >
        {roles.map(category => <Filter filters={props.filters.filter(entry => entry.target === 'Person' && entry.category === category)} checked={checked} handleToggle={handleToggle} header={category} key={category}/>
        )}
    </List>
        </React.Fragment>
    );
}

