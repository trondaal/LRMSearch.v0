import React, {useMemo} from 'react';
import List from '@mui/material/List';
import ListSubheader from '@mui/material/ListSubheader';
import Filter from './Filter';
import {selectedVar} from './Cache';
//import {FilterContext} from "./FilterContext";
//import Button from '@mui/material/Button';

function createFilterList(expressions){
    const filters = new Map();
    expressions.forEach((exp) => {
        exp.language.forEach(language => {
            let filter = {source: "Expression", target: "Concept", category: "Language", value: language.label, uri: language.uri, selection: new Set([exp.uri]), count: 1};
            let key = [filter.target, filter.category, filter.uri].join("+");
            if (filters.has(key)){
                //Updating already added filter
                filters.get(key).count++;
                filters.get(key).selection.add(exp.uri);
            }else{
                filters.set(key, filter);
            }
        });
        exp.content.forEach(content => {
            let filter = {source: "Expression", target: "Concept", category: "Content", value: content.label, uri: content.uri, selection: new Set([exp.uri]), count: 1};
            let key = [filter.target, filter.category, filter.uri].join("+");
            if (filters.has(key)){
                //Updating already added filter
                filters.get(key).count++;
                filters.get(key).selection.add(exp.uri);
            }else{
                filters.set(key, filter);
            }
        });
        exp.creatorsConnection.edges.forEach(edge => {
            let filter = {source: "Expression", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, selection: new Set([exp.uri]), count: 1};
            let key = [filter.target, filter.category, filter.uri].join("+");
            if (filters.has(key)){
                //Updating already added filter
                filters.get(key).count++;
                filters.get(key).selection.add(exp.uri);
            }else{
                filters.set(key, filter);
            }
        });
        exp.work.forEach(work => {
            work.type.forEach(type => {
                let filter = {source: "Work", target: "Concept", category: "Type", value: type.label, uri: type.uri, selection: new Set([exp.uri]), count: 1};
                let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(key)){
                    //Updating already added filter
                    filters.get(key).count++;
                    filters.get(key).selection.add(exp.uri);
                }else{
                    filters.set(key, filter);
                }
            })
            work.creatorsConnection.edges.forEach(edge => {
                let filter = {source: "Work", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, selection: new Set([exp.uri]), count: 1};
                let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(key)){
                    //Updating already added filter
                    filters.get(key).count++;
                    filters.get(key).selection.add(exp.uri);
                }else{
                    filters.set(key, filter);
                }
            })
        });
        exp.manifestations.forEach(manifestation => {
            manifestation.carrier.forEach(carrier => {
                let filter = {source: "Manifestation", target: "Concept", category: "Carrier", value: carrier.label, uri: carrier.uri, selection: new Set([exp.uri]), count: 1};
                let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(key)){
                    //Updating already added filter
                    filters.get(key).count++;
                    filters.get(key).selection.add(exp.uri);
                }else{
                    filters.set(key, filter);
                }
            });
            manifestation.media.forEach(media => {
                let filter = {source: "Manifestation", target: "Concept", category: "Media", value: media.label, uri: media.uri, selection: new Set([exp.uri]), count: 1};
                let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(key)){
                    //Updating already added filter
                    filters.get(key).count++;
                    filters.get(key).selection.add(exp.uri);
                }else{
                    filters.set(key, filter);
                }
            })
            manifestation.creatorsConnection.edges.forEach(edge => {
                let filter = {source: "Manifestation", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, selection: new Set([exp.uri]), count: 1};
                let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(key)){
                    //Updating already added filter
                    filters.get(key).count++;
                    filters.get(key).selection.add(exp.uri);
                }else{
                    filters.set(key, filter);
                }
            })
        })

    })
    return filters;
}

export default function FilterList(props) {
    const filterMap = useMemo(() => createFilterList(props.results ? props.results : []), [props.results]);
    console.log(filterMap);

    const filters = useMemo(() => Array.from(filterMap.values()), [filterMap]);
    //console.log(filters);

    const roles = useMemo(() => [...new Set(filters.filter(x => x.target === "Agent").map(f => f.category))].sort(), [filters]);
    //console.log(roles)

    const [checked, setChecked] = React.useState([]);

    const handleToggle = (filterKey) => () => {
        const currentIndex = checked.indexOf(filterKey);
        const newChecked = [...checked];

        if (currentIndex === -1) {
            newChecked.push(filterKey);
        } else {
            newChecked.splice(currentIndex, 1);
        }
        setChecked(newChecked);
        //console.log(newChecked);

        let selected = new Set([]);
        newChecked.forEach(f => filterMap.get(f).selection.forEach(selected.add, selected));
        //filters.forEach(x => x.selection.forEach(s => selected.add(s)));
        selectedVar(selected);
        //console.log(selectedVar());
    };

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
        <Filter filters={filters.filter(entry => entry.category === 'Language')} checked={checked} handleToggle={handleToggle} header={"Language"}/>
        <Filter filters={filters.filter(entry => entry.category === 'Content')} checked={checked} handleToggle={handleToggle} header={"Content type"}/>
        <Filter filters={filters.filter(entry => entry.category === 'Media')} checked={checked} handleToggle={handleToggle} header={"Media type"}/>
        <Filter filters={filters.filter(entry => entry.category === 'Carrier')} checked={checked} handleToggle={handleToggle} header={"Type of carrier"}/>
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
        {roles.map(category => <Filter filters={filters.filter(entry => entry.target === 'Agent' && entry.category === category)} checked={checked} handleToggle={handleToggle} header={category} key={category}/>
        )}
    </List>
        </React.Fragment>
    );
}

