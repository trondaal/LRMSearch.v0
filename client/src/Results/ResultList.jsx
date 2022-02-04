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
import "./ResultList.css";
import {groupBy} from "lodash";
import {ListItemSecondaryAction} from "@mui/material";
import Checkbox from '@mui/material/Checkbox';

function isEmpty(str) {
    return (!str || str.length === 0 );
}

function Manifestation(props){
    console.log("Manifestation: " + props.checkboxes);
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

    return <ListItem alignItems="flex-start"
                     disablePadding
                     sx={{
                            width: '80%',
                            pl: 10,
                            pb: 1
                        }}
    >
        <ListItemText
                      primary={<div className={"manifestation"}>
                          <Typography color={"steelblue"} variant="subtitle2" className={"manifestationtitle"}>{statement.join(" / ")}</Typography>
                          <Typography color={"dimgray"} variant="body2" className={"manifestationtitle"}>Extent: {extent}</Typography>
                          <Typography color={"dimgray"} variant="body2" className={"manifestationtitle"}>Published: {metadata.join(", ")}</Typography>
                      </div>}>
        </ListItemText>
        {props.checkboxes ?
            <ListItemSecondaryAction
                sx={{top: "0%", marginTop: "17px", width: '20%', textAlign: 'left', alignItems: 'left'}}>
                <Checkbox
                    sx={{pl: 0}}
                    edge="end"
                    checked={false}

                />
            </ListItemSecondaryAction>
            : ""
        }
    </ListItem>
}

function Expression(props){
    //const {uri} = props.expression;

    console.log("Expression : " + props.checkboxes);
    const worktitle = !isEmpty(props.expression.work[0].title) ? props.expression.work[0].title : "";

    const titles = [];
    if (!isEmpty(props.expression.titlepreferred)) titles.push(props.expression.titlepreferred);
    if (!isEmpty(props.expression.title)) titles.push(props.expression.title);
    if (!isEmpty(props.expression.titlevariant)) titles.push(props.expression.titlevariant);
    const title = titles[0];

    const isTranslation = titles.includes(worktitle)

    const creatorsmap = groupBy(props.expression.work[0].creatorsConnection.edges, a => a.role);
    const creators = [];
    creatorsmap.Author && creators.push(["Author: ", (creatorsmap.Author.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Creator && creators.push(["Creator: ", (creatorsmap.Creator.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Artist && creators.push(["Artist: ", (creatorsmap.Artist.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Director && creators.push(["Director: ", (creatorsmap.Director.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Composer && creators.push(["Composer: ", (creatorsmap.Composer.map(a => a.node.name)).join(" ; ")]);
    //console.log(creators)

    const contributorsmap = groupBy(props.expression.creatorsConnection.edges, a => a.role);
    const contributors = [];
    contributorsmap.Translator && contributors.push(["Translator: ", (contributorsmap.Translator.map(a => a.node.name)).join(" ; ")]);
    contributorsmap.Narrator && contributors.push(["Narrator: ", (contributorsmap.Narrator.map(a => a.node.name)).join(" ; ")]);
    contributorsmap.Abridger && contributors.push(["Abridger: ", (contributorsmap.Abridger.map(a => a.node.name)).join(" ; ")]);
    const language = props.expression.language.map(l => l.label);
    const content = props.expression.content.map(c => c.label);
    content.sort();
    content.reverse();

    //console.log(contributors)
    //const contributors = props.expression.creatorsConnection.edges.map(e => e.node.name + " (" + e.role + ")").join(', ');

    //const categories = [];
    //if (type !== '')
    //    categories.push(type.toLowerCase());
    // if (content !== '')
    //     categories.push(content);
    // if (language !== '')
    //     categories.push(language);

    return <Paper elevation={0} square className={"expression"}>
        <ListItem alignItems="flex-start" sx={{width: '80%'}}>
            <ListItemAvatar>
                <Avatar sx={{ bgcolor: grey[400] }}>
                    <ExpressionTypeIcon type={content[0]} />
                </Avatar>
            </ListItemAvatar>
            <ListItemText className={"expressionheading"}
                primary={<React.Fragment>
                            <span className={"expressiontitle"}>{title}</span>
                            {!isTranslation && <span className={"worktitle"}> ({worktitle})</span>}
                            <br/>
                            {creators.map(creator => <div className={"creatorname"}>{creator[0] + creator[1]}</div>) }
                            {contributors.map(contributor => <div className={"creatorname"}>{contributor[0] + contributor[1]}</div>) }
                        </React.Fragment>}
            />
            <ListItemSecondaryAction sx={{top:"0%", marginTop:"35px", width: '20%', textAlign: 'left'}}>
                <Typography color={"dimgray"} variant={"body2"}>{'Content type: ' +  content.join(", ")}</Typography>
                <Typography color={"dimgray"} variant={"body2"}>{'Language: ' +  language.join(", ")}</Typography>
            </ListItemSecondaryAction>
        </ListItem>
        <List dense={true} sx={{pt: 0}}>
            {props.expression && props.expression.manifestations.map(m => (<Manifestation manifestation={m} key={m.uri} checkboxes={props.checkboxes}/>))}
        </List>
    </Paper>
}

export default function ResultList(props){
    console.log("Resultlist: " + props.checkboxes);
    return (<List sx={{ width: '100%', bgcolor: 'background.paper' }} className={"expressionlist"}>
        {props.results && props.results.map(x => (<Expression expression={x} key={x.uri} checkboxes={props.checkboxes}/>))}
    </List>);
}
