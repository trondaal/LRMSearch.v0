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
import Manifestation from "./Manifestation";

function isEmpty(str) {
    return (!str || str.length === 0 );
}

export default function Expression(props){
    //const {uri} = props.expression;

    //console.log("Expression : " + props.checkboxes);
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

    return <Paper elevation={0} square className={"expression"} key={props.expression.uri}>
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
                              {creators.map(creator => <div className={"creatorname"} key={creator[0] + creator[1]}>{creator[0] + creator[1]}</div>) }
                              {contributors.map(contributor => <div className={"creatorname"} key={contributor[0] + contributor[1]}>{contributor[0] + contributor[1]}</div>) }
                          </React.Fragment>}
            />
            <ListItemSecondaryAction sx={{top:"0%", marginTop:"35px", width: '20%', textAlign: 'left'}}>
                <Typography color={"dimgray"} variant={"body2"}>{'Content type: ' +  content.join(", ")}</Typography>
                {(language.length !== 0) ? <Typography color={"dimgray"} variant={"body2"}>{'Language: ' +  language.join(", ")}</Typography> : ""}
            </ListItemSecondaryAction>
        </ListItem>
        <List dense={true} sx={{pt: 0}}>
            {props.expression && props.expression.manifestations.map(m => (<Manifestation manifestation={m} key={m.uri} checkboxes={props.checkboxes}/>))}
        </List>
    </Paper>
}