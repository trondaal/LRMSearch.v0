import React from 'react';
import List from '@mui/material/List';
import ListItem from "@mui/material/ListItem";
import Typography from "@mui/material/Typography";
import ListItemAvatar from "@mui/material/ListItemAvatar";
import Avatar from "@mui/material/Avatar";
import {grey} from "@mui/material/colors";
import ListItemText from "@mui/material/ListItemText";
import ExpressionTypeIcon from "./ExpressionTypeIcon";
import Paper from "@mui/material/Paper";
import "./Resultlist.css";
import {groupBy} from "lodash";
import {ListItemSecondaryAction} from "@mui/material";

function isEmpty(str) {
    return (!str || str.length === 0 );
}

function Manifestation(props){

    const {title, subtitle, numbering, part, responsibility, extent, edition, identifier} = props.manifestation;
    const {distributionplace, distributor, distributiondate, publicationdate, publicationplace, publisher, productionplace, producer, productiondate, manufactureplace, manufacturer, manufacturedate} = props.manifestation;
    const statement = [];
    if (!isEmpty(title)) statement.push(title);
    if (!isEmpty(subtitle)) statement.push(subtitle);
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

    return <ListItem alignItems="flex-start" disablePadding sx={{
        pl: 10
    }}>


        <ListItemText
                      sx={{
                        width: 300,
                          }}
                      primary={<div className={"manifestation"}>
                          <Typography color={"steelblue"} variant="subtitle2" className={"manifestationtitle"}>{statement.join(" / ")}</Typography>
                          <Typography color={"dimgray"} variant="body2" className={"manifestationtitle"}>Extent: {extent}</Typography>
                          <Typography color={"dimgray"} variant="body2" className={"manifestationtitle"}>Published: {metadata.join(", ")}</Typography>
                          <Typography color={"dimgray"} variant="body2" className={"manifestationtitle"}>{identifier}</Typography>
                      </div>}>
        </ListItemText>
    </ListItem>
}

function Expression(props){
    //const {uri} = props.expression;
    const worktitle = !isEmpty(props.expression.work[0].title) ? props.expression.work[0].title : "";

    const titles = [];
    if (!isEmpty(props.expression.titlepreferred)) titles.push(props.expression.titlepreferred);
    if (!isEmpty(props.expression.title)) titles.push(props.expression.title);
    if (!isEmpty(props.expression.titlevariant)) titles.push(props.expression.titlevariant);
    const title = titles[0];

    const isTranslation = titles.includes(worktitle)

    //const creators = props.expression.work[0].creatorsConnection.edges.map(e => e.node.name + " (" + e.role + ")").join(', ');
    //const type = props.expression.work[0].type.map(t => t.label).join(', ');

    const creatorsmap = groupBy(props.expression.work[0].creatorsConnection.edges, a => a.role);
    //console.log(creatorsmap);
    const contributorsmap = groupBy(props.expression.creatorsConnection.edges, a => a.role);
    //console.log(contributorsmap);

    const language = props.expression.language.map(l => l.label);
    const content = props.expression.content.map(c => c.label);

    //const contributors = props.expression.creatorsConnection.edges.map(e => e.node.name + " (" + e.role + ")").join(', ');

    const categories = [];
    //if (type !== '')
    //    categories.push(type.toLowerCase());
    if (content !== '')
        categories.push(content);
    if (language !== '')
        categories.push(language);

    return <Paper elevation={0} square className={"expression"}>
        <ListItem alignItems="flex-start">
            <ListItemAvatar>
                <Avatar sx={{ bgcolor: grey[400] }}>
                    <ExpressionTypeIcon type={content[0]} />
                </Avatar>
            </ListItemAvatar>
            <ListItemText
                primary={<React.Fragment>
                            <span className={"expressiontitle"}>{title}</span>
                            {!isTranslation && <span className={"worktitle"}> ({worktitle})</span>}
                            <br/>
                            {creatorsmap.author && <div className={"creatorname"}>Author: {(creatorsmap.author.map(a => a.node.name)).join(" ; ")}</div>}
                            {creatorsmap.director && <div className={"creatorname"}>Director: {(creatorsmap.director.map(a => a.node.name)).join(" ; ")}</div>}
                            {contributorsmap.translator && <div className={"creatorname"}>Translator: {(contributorsmap.translator.map(a => a.node.name)).join(" ; ")}</div>}
                            {contributorsmap.narrator && <div className={"creatorname"}>Narrator: {(contributorsmap.narrator.map(a => a.node.name)).join(" ; ")}</div>}
                        </React.Fragment>}
            />
            <ListItemSecondaryAction sx={{top:"0%", marginTop:"35px"}}>
                <Typography color={"dimgray"} variant={"body2"}>{'Content type: ' +  content}</Typography>
                <Typography color={"dimgray"} variant={"body2"}>{'Language: ' +  language}</Typography>
                <Typography color={"dimgray"} variant={"body2"}>{'Checked: ' +  props.expression.checked}</Typography>
            </ListItemSecondaryAction>
        </ListItem>
        <List dense={true}>
            {props.expression && props.expression.manifestations.map(m => (<Manifestation manifestation={m} key={m.uri}/>))}
        </List>
    </Paper>
}

export default function ResultList(props){
    return (<List sx={{ width: '100%', bgcolor: 'background.paper' }} className={"expressionlist"}>
        {props.results && props.results.map(x => (<Expression expression={x} key={x.uri}/>))}
    </List>);
}

/*export default function ResultList(props){

    const { loading, error, data, refetch} = useQuery(GET_RESULTS, {
        variables: {query: props.query, offset: 0},
        fetchPolicy: "cache-and-network"
    });

    const { sloading, serror, sdata, srefetch} = useQuery(GET_STATS, {
        variables: {query: props.query, offset: 0},
        fetchPolicy: "cache-and-network"
    });

    if (error )
        console.log(error);

    console.log(props.expressions);

    return (<List sx={{ width: '100%', bgcolor: 'background.paper' }}>
        {props.expressions && props.expressions.map(x => (<Expression expression={x} key={x.uri}/>))}
        </List>);
}*/

/*                secondary={
                    <React.Fragment>
                        <Typography
                            sx={{ display: 'inline' }}
                            component="span"
                            variant="body2"
                            color="text.primary"
                        >
                            {contributors}
                        </Typography>
                    </React.Fragment>
                }*/