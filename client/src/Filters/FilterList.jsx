import React, {useMemo} from 'react';
import List from '@mui/material/List';
import ListSubheader from '@mui/material/ListSubheader';
import FilterGroup from './FilterGroup';
import {selectedVar} from '../api/Cache';
import { intersection } from 'lodash';
import {filterState} from '../state/state';
import {useRecoilState} from 'recoil';

function createFilterList(expressions){
    const filters = new Map();
    expressions.forEach((exp) => {
        exp.expression.language.forEach(language => {
            let filter = {key: "Language+"+language.uri, source: "Expression", target: "Concept", category: "Language", value: language.label, uri: language.uri, selection: new Set([exp.uri]), count: 1};
            ////let key = [filter.target, filter.category, filter.uri].join("+");
            if (filters.has(filter.key)){
                //Updating already added filter
                filters.get(filter.key).count++;
                filters.get(filter.key).selection.add(exp.uri);
            }else{
                filters.set(filter.key, filter);
            }
        });
        exp.expression.content.forEach(content => {
            let filter = {key: "Content+"+content.uri, source: "Expression", target: "Concept", category: "Content", value: content.label, uri: content.uri, selection: new Set([exp.uri]), count: 1};
            ////let key = [filter.target, filter.category, filter.uri].join("+");
            if (filters.has(filter.key)){
                //Updating already added filter
                filters.get(filter.key).count++;
                filters.get(filter.key).selection.add(exp.uri);
            }else{
                filters.set(filter.key, filter);
            }
        });
        exp.expression.creatorsConnection.edges.forEach(edge => {
            let filter = {key: "Contributor+"+edge.role+"+"+edge.node.uri, source: "Expression", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, selection: new Set([exp.uri]), count: 1};
            //let key = [filter.target, filter.category, filter.uri].join("+");
            if (filters.has(filter.key)){
                //Updating already added filter
                filters.get(filter.key).count++;
                filters.get(filter.key).selection.add(exp.uri);
            }else{
                filters.set(filter.key, filter);
            }
        });
        exp.expression.work.forEach(work => {
            work.type.forEach(type => {
                let filter = {key: "Type+"+type.uri, source: "Work", target: "Concept", category: "Type", value: type.label, uri: type.uri, selection: new Set([exp.uri]), count: 1};
                //let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(filter.key)){
                    //Updating already added filter
                    filters.get(filter.key).count++;
                    filters.get(filter.key).selection.add(exp.uri);
                }else{
                    filters.set(filter.key, filter);
                }
            })
            work.creatorsConnection.edges.forEach(edge => {
                let filter = {key: "Creator+"+edge.role+"+"+edge.node.uri, source: "Work", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, selection: new Set([exp.uri]), count: 1};
                //let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(filter.key)){
                    //Updating already added filter
                    filters.get(filter.key).count++;
                    filters.get(filter.key).selection.add(exp.uri);
                }else{
                    filters.set(filter.key, filter);
                }
            })
        });
        exp.expression.manifestations.forEach(manifestation => {
            manifestation.carrier.forEach(carrier => {
                let filter = {key: "Carrier+"+carrier.uri, source: "Manifestation", target: "Concept", category: "Carrier", value: carrier.label, uri: carrier.uri, selection: new Set([exp.uri]), count: 1};
                //let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(filter.key)){
                    //Updating already added filter
                    filters.get(filter.key).count++;
                    filters.get(filter.key).selection.add(exp.uri);
                }else{
                    filters.set(filter.key, filter);
                }
            });
            manifestation.media.forEach(media => {
                let filter = {key: "Media+"+media.uri, source: "Manifestation", target: "Concept", category: "Media", value: media.label, uri: media.uri, selection: new Set([exp.uri]), count: 1};
                //let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(filter.key)){
                    //Updating already added filter
                    filters.get(filter.key).count++;
                    filters.get(filter.key).selection.add(exp.uri);
                }else{
                    filters.set(filter.key, filter);
                }
            })
            manifestation.creatorsConnection.edges.forEach(edge => {
                let filter = {key: "Supplemental+"+edge.role+"+"+edge.node.uri, source: "Manifestation", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, selection: new Set([exp.uri]), count: 1};
                //let key = [filter.target, filter.category, filter.uri].join("+");
                if (filters.has(filter.key)){
                    //Updating already added filter
                    filters.get(filter.key).count++;
                    filters.get(filter.key).selection.add(exp.uri);
                }else{
                    filters.set(filter.key, filter);
                }
            })
        })
    })
    //console.log(filters);
    return filters;
}

export default function FilterList(props) {
    const filterMap = useMemo(() => createFilterList(props.results ? props.results : []), [props.results]);
    //console.log(filterMap);

    const filters = useMemo(() => Array.from(filterMap.values()), [filterMap]);
    //console.log(filters);

    const creators = useMemo(() => [...new Set(filters.filter(x => x.source === "Work" && x.target === "Agent").map(f => f.category))].sort(), [filters]);
    const contributors = useMemo(() => [...new Set(filters.filter(x => x.source === "Expression" && x.target === "Agent").map(f => f.category))].sort(), [filters]);
    const supplement = useMemo(() => [...new Set(filters.filter(x => x.source === "Manifestation" && x.target === "Agent").map(f => f.category))].sort(), [filters]);

    const [checked, setChecked] = useRecoilState(filterState)
    //const [checked, setChecked] = React.useState([]);

    const handleToggle = (filterKey) => () => {
        const currentIndex = checked.indexOf(filterKey);
        const newChecked = [...checked];

        if (currentIndex === -1) {
            newChecked.push(filterKey);
        } else {
            newChecked.splice(currentIndex, 1);
        }
        setChecked(newChecked);

        const selection = new Map();
        selection.set("Language", []);
        selection.set("Content", []);
        selection.set("Media", []);
        selection.set("Carrier", []);
        selection.set("Creator", []);
        selection.set("Contributor", []);
        selection.set("Supplemental", []);
        //adding items that have been selected for filters that are checked
        newChecked.forEach(key => selection.get(key.split("+")[0]).push(...filterMap.get(key).selection) );
        //removing the keys for empty categories (so that we can do intersection of the rest)
        for(let k of selection.keys()){
            if (selection.get(k).length === 0){
                selection.delete(k);
            }
        }
        //console.log("Category " + category);
        //console.log([...potential]);
        //console.log(intersection(...selection.values()));
        if (newChecked.length === 0){
            //console.log(true);
            selectedVar(new Set([]));
        }else {
            //const test = intersection(...selection.values())
            //console.log(test);
            selectedVar(new Set(intersection(...selection.values())));
            console.log(selectedVar())
            //console.log(false);
        }
        //console.log(selectedVar());
    };


    const getAvailable = (category, potential) => {
        const selection = new Map();
        selection.set("Language", []);
        selection.set("Content", []);
        selection.set("Media", []);
        selection.set("Carrier", []);
        selection.set("Creator", []);
        selection.set("Contributor", []);
        selection.set("Supplemental", []);
        checked.forEach(key => selection.get(key.split("+")[0]).push(...filterMap.get(key).selection) );
        selection.delete(category.split("+")[0])
        for(let k of selection.keys()){
            //deleting unselected categories
            if (selection.get(k).length === 0){
                selection.delete(k);
            }
        }
        //console.log(category.split("+")[0]);
       // console.log(selection);
        //sconsole.log(selection.size);
        //console.log([...potential]);
        //console.log(intersection(...selection.values()));

        // if (selection.size === 1 and selection.key == category)
        // return available - what is already selected

        if (selection.size === 0){
            return [...potential];
        } else if (selection.size === 1 && selection.keys()[0] === category.split("+")[0]){
            return [...potential];
        }
        else {
            //console.log(without([...potential], intersection(...selection.values())));
            return intersection([...potential], intersection(...selection.values()));
        }
    }

    return (<React.Fragment>
        <List
            sx={{ width: '100%', bgcolor: 'background.paper' }}
            component="nav"
            aria-labelledby="nested-list-subheader"
            subheader={
                <ListSubheader component="div" id="nested-list-subheader">
                    CATEGORIES
                </ListSubheader>
            }
        >
            <FilterGroup filters={filters.filter(entry => entry.category === 'Language')} checked={checked} handleToggle={handleToggle} getAvailable={getAvailable} header={"Language"} category={"Language"}/>
            <FilterGroup filters={filters.filter(entry => entry.category === 'Content')} checked={checked} handleToggle={handleToggle} getAvailable={getAvailable} header={"Type of content"} category={""}/>
            <FilterGroup filters={filters.filter(entry => entry.category === 'Media')} checked={checked} handleToggle={handleToggle} getAvailable={getAvailable} header={"Media type"} category={"Media"}/>
            <FilterGroup filters={filters.filter(entry => entry.category === 'Carrier')} checked={checked} handleToggle={handleToggle} getAvailable={getAvailable} header={"Carrier type"} category={"Carrier"}/>
        </List>
        <List
            sx={{ width: '100%',bgcolor: 'background.paper' }}
            component="nav"
            aria-labelledby="nested-list-subheader"
            subheader={
                <ListSubheader component="div" id="nested-list-subheader">
                    CREATORS
                </ListSubheader>
            }
        >
            {creators.map(category => <FilterGroup filters={filters.filter(entry => entry.target === 'Agent' && entry.category === category)} checked={checked} handleToggle={handleToggle} getAvailable={getAvailable} category={"Carrier"} header={category} key={category}/>)}
        </List>
        <List
            sx={{ width: '100%', bgcolor: 'background.paper' }}
            component="nav"
            aria-labelledby="nested-list-subheader"
            subheader={
                <ListSubheader component="div" id="nested-list-subheader">
                    CONTRIBUTORS
                </ListSubheader>
            }
        >
            {contributors.map(category => <FilterGroup filters={filters.filter(entry => entry.target === 'Agent' && entry.category === category)} checked={checked} handleToggle={handleToggle} getAvailable={getAvailable} category={"Carrier"} header={category} key={category}/>
            )}
        </List>
        <List
            sx={{ width: '100%', bgcolor: 'background.paper' }}
            component="nav"
            aria-labelledby="nested-list-subheader"
            subheader={
                <ListSubheader component="div" id="nested-list-subheader">
                    SUPPLEMENT BY
                </ListSubheader>
            }>
            {supplement.map(category => <FilterGroup filters={filters.filter(entry => entry.target === 'Agent' && entry.category === category)} checked={checked} handleToggle={handleToggle} getAvailable={getAvailable} category={"Carrier"} header={category} key={category}/>
            )}
        </List>
        </React.Fragment>
    );
}

