import Grid from "@mui/material/Grid";
import ResultList from "./ResultList";
import FilterList from "./FilterList"
import React from "react";
import {useQuery} from '@apollo/client';
import Item from './Item';
import {GET_RESULTS} from "./queries";

function createFilterList(expressions){
    let filters =[];
    //language

    //filter:
    /*
    filter:
    {source, target, category, value, count, uri}
     */
    expressions.forEach((exp) => {
        exp.language.forEach(language => {
            let n = {source: "Expression", target: "Concept", category: "Language", value: language.label, uri: language.uri, count: 1};
            let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
            if (index === -1){
                filters.push(n);
            }else{
                filters[index].count++;
            }
        })
        exp.content.forEach(content => {
            let n = {source: "Expression", target: "Concept", category: "Content", value: content.label, uri: content.uri, count: 1};
            let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
            if (index === -1){
                filters.push(n);
            }else{
                filters[index].count++;
            }
        });
        exp.creatorsConnection.edges.forEach(edge => {
            let n = {source: "Expression", target: "Person", category: edge.role, value: edge.node.name, uri: edge.node.uri, count: 1};
            let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
            if (index === -1){
                filters.push(n);
            }else{
                filters[index].count++;
            }
        })
        exp.work.forEach(work => {
            work.type.forEach(type => {
                let n = {source: "Work", target: "Concept", category: "Type", value: type.label, uri: type.uri, count: 1};
                let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
                if (index === -1){
                    filters.push(n);
                }else{
                    filters[index].count++;
                }
            })
            work.creatorsConnection.edges.forEach(edge => {
                let n = {source: "Work", target: "Person", category: edge.role, value: edge.node.name, uri: edge.node.uri, count: 1};
                let index = filters.findIndex((f) => f.category === n.category && f.value === n.value);
                if (index === -1){
                    filters.push(n);
                }else{
                    filters[index].count++;
                }
            })
        })

    })
    return filters;
}

export default function ResultView(props) {

    const { loading, error, data} = useQuery(GET_RESULTS, {
        variables: {query: props.query, offset: 0},
        fetchPolicy: "cache-and-network"
    });

    if (error)
        console.log(error);

    //console.log(data);
   console.log(data);

    if (loading) return <p>Loading ...</p>;

    const filters = createFilterList(data.expressions ? data.expressions : []);
    //console.log(filters);

    return (
        <React.Fragment>
            <Grid item xs={8}>
                <Item>
                    <ResultList result={data.expressions}/>
                </Item>
            </Grid>
            <Grid item xs={4}>
                <FilterList filters={filters}/>
            </Grid>
        </React.Fragment>
    )

}