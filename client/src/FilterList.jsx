import React, {useState} from 'react';
import List from '@mui/material/List';
import ListSubheader from '@mui/material/ListSubheader';
import Filter from './Filter';
//import {FilterContext} from "./FilterContext";
//import Button from '@mui/material/Button';

function createFilterList(expressions){
    let filters =[];
    expressions.forEach((exp) => {
        exp.language.forEach(language => {
            let n = {source: "Expression", target: "Concept", category: "Language", value: language.label, uri: language.uri, isChecked: language.checked, selection: new Set([exp.uri]), count: 1};
            let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
            if (index === -1){
                filters.push(n);
            }else{
                filters[index].count++;
                filters[index].selection.add(exp.uri);
            }
        })
        exp.content.forEach(content => {
            let n = {source: "Expression", target: "Concept", category: "Content", value: content.label, isChecked: content.checked, selection: new Set([exp.uri]), uri: content.uri, count: 1};
            let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
            if (index === -1){
                filters.push(n);
            }else{
                filters[index].count++;
                filters[index].selection.add(exp.uri);
            }
        });
        exp.creatorsConnection.edges.forEach(edge => {
            let n = {source: "Expression", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, isChecked: edge.checked, selection: new Set([exp.uri]), count: 1};
            let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
            if (index === -1){
                filters.push(n);
            }else{
                filters[index].count++;
                filters[index].selection.add(exp.uri);
            }
        });
        exp.work.forEach(work => {
            work.type.forEach(type => {
                let n = {source: "Work", target: "Concept", category: "Type", value: type.label, uri: type.uri, isChecked: type.checked, selection: new Set([exp.uri]), count: 1};
                let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
                if (index === -1){
                    filters.push(n);
                }else{
                    filters[index].count++;
                    filters[index].selection.add(exp.uri);
                }
            })
            work.creatorsConnection.edges.forEach(edge => {
                let n = {source: "Work", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, isChecked: edge.checked, selection: new Set([exp.uri]), count: 1};
                let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
                if (index === -1){
                    filters.push(n);
                }else{
                    filters[index].count++;
                    filters[index].selection.add(exp.uri);
                }
            })
        });
        exp.manifestations.forEach(manifestation => {
            manifestation.carrier.forEach(carrier => {
                let n = {source: "Manifestation", target: "Concept", category: "Carrier", value: carrier.label, uri: carrier.uri, isChecked: carrier.checked, selection: new Set([exp.uri]), count: 1};
                let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
                if (index === -1){
                    filters.push(n);
                }else{
                    filters[index].count++;
                    filters[index].selection.add(exp.uri);
                }
            });
            manifestation.media.forEach(media => {
                let n = {source: "Manifestation", target: "Concept", category: "Media", value: media.label, uri: media.uri, isChecked: media.checked, selection: new Set([exp.uri]), count: 1};
                let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
                if (index === -1){
                    filters.push(n);
                }else{
                    filters[index].count++;
                    filters[index].selection.add(exp.uri);
                }
            })
            manifestation.creatorsConnection.edges.forEach(edge => {
                let n = {source: "Manifestation", target: "Agent", category: edge.role, value: edge.node.name, uri: edge.node.uri, isChecked: edge.checked, selection: new Set([exp.uri]), count: 1};
                let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
                if (index === -1){
                    filters.push(n);
                }else{
                    filters[index].count++;
                    filters[index].selection.add(exp.uri);
                }
            })
        })

    })
    return filters;
}

export default function FilterList(props) {
    const [selection, setSelection] = useState([])

    
    //const [checked, handleToggle, clear] = useContext(FilterContext);

    //extracting filters (and roles used for agents)
    const filters = createFilterList(props.results ? props.results : []);
    let selected = new Set();
    filters.filter(entry => entry.isChecked).forEach(x => x.selection.forEach(s => selected.add(s)));
    const roles = [...new Set(filters.filter(entry => entry.target === 'Agent').map(x => x.category))].sort();

    console.log(selected);

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
        <Filter filters={filters.filter(entry => entry.category === 'Language')} header={"Language"}/>
        <Filter filters={filters.filter(entry => entry.category === 'Content')} header={"Content type"}/>
        <Filter filters={filters.filter(entry => entry.category === 'Media')} header={"Media type"}/>
        <Filter filters={filters.filter(entry => entry.category === 'Carrier')} header={"Type of carrier"}/>
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
        {roles.map(category => <Filter filters={filters.filter(entry => entry.target === 'Agent' && entry.category === category)} header={category} key={category}/>
        )}
    </List>
        </React.Fragment>
    );
}

