import React from 'react';
import List from '@mui/material/List';
import Typography from "@mui/material/Typography";
import ListItemText from "@mui/material/ListItemText";
import IconTypes from "./IconTypes";
import Paper from "@mui/material/Paper";
import Popover from '@mui/material/Popover';
import Button from '@mui/material/Button';
import "./ResultList.css";
import {groupBy} from "lodash";
import {ListItemSecondaryAction} from "@mui/material";
import ListItemButton from '@mui/material/ListItemButton';
import ListItem from '@mui/material/ListItem';
import Manifestation from "./Manifestation";
import {useRecoilState} from 'recoil';
import {showUriState, clickableState, selectedState} from "../state/state";
import ListItemIcon from "@mui/material/ListItemIcon";
import "./ResultList.css";
import Related from "./Related"

function isEmpty(str) {
    return (!str || str.length === 0 );
}

export default function Expression(props){
    const [showUri] = useRecoilState(showUriState);
    const [selected, setSelectedState] = useRecoilState(selectedState);
    const [clickable] = useRecoilState(clickableState);
    const {uri, manifestations} = props.expression;

    //console.log("clickable : " + clickable);
    const worktitle = !isEmpty(props.expression.work[0].title) ? props.expression.work[0].title : "";

    const titles = [];
    if (!isEmpty(props.expression.titlepreferred)){
        titles.push(props.expression.titlepreferred);
    }else{
        if (!isEmpty(props.expression.title)) titles.push(props.expression.title);
    }
    //if (!isEmpty(props.expression.titlevariant)) titles.push(props.expression.titlevariant);
    const title = titles[0];

    const isTranslation = titles.find(element => element.toLowerCase().replace(/[^a-z]/g, '').includes(worktitle.toLowerCase().replace(/[^a-z]/g, '')))
    //console.log(worktitle.toLowerCase().replace(/[^a-z]/g, ''));
    const creatorsmap = groupBy(props.expression.work[0].creatorsConnection.edges, a => a.role);
    const creators = [];
    creatorsmap.Author && creators.push(["Author: ", (creatorsmap.Author.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Creator && creators.push(["Creator: ", (creatorsmap.Creator.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Artist && creators.push(["Artist: ", (creatorsmap.Artist.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Director && creators.push(["Director: ", (creatorsmap.Director.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Producer && creators.push(["Producer: ", (creatorsmap.Producer.map(a => a.node.name)).slice().sort().join(" ; ")]);
    creatorsmap.Composer && creators.push(["Composer: ", (creatorsmap.Composer.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Lyricist && creators.push(["Lyricist: ", (creatorsmap.Lyricist.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Interviewer && creators.push(["Interviewer: ", (creatorsmap.Interviewer.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Interviewee && creators.push(["Interviewee: ", (creatorsmap.Interviewee.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Honouree && creators.push(["Honouree: ", (creatorsmap.Honouree.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Compiler && creators.push(["Compiler: ", (creatorsmap.Compiler.map(a => a.node.name)).join(" ; ")]);
    //console.log(creators)

    const contributorsmap = groupBy(props.expression.creatorsConnection.edges, a => a.role);
    const contributors = [];
    contributorsmap.Translator && contributors.push(["Translator: ", (contributorsmap.Translator.map(a => a.node.name)).join(" ; ")]);
    contributorsmap.Narrator && contributors.push(["Narrator: ", (contributorsmap.Narrator.map(a => a.node.name)).join(" ; ")]);
    contributorsmap.Abridger && contributors.push(["Abridger: ", (contributorsmap.Abridger.map(a => a.node.name)).join(" ; ")]);
    contributorsmap.Editor && contributors.push(["Editor: ", (contributorsmap.Editor.map(a => a.node.name)).join(" ; ")]);
    const language = props.expression.language.map(l => l.label);
    const content = props.expression.content.map(c => c.label);
    content.sort();
    content.reverse();

    const worktype = props.expression.work[0].type.map(c => c.label);


    const isRelatedToMap = groupBy(props.expression.work[0].relatedToConnection.edges, a => a.role);
    //console.log(isRelatedToMap);
    //console.log(props.expression.work[0].relatedToConnection)

    const isRelatedTo = props.expression.work[0].relatedToConnection;
    const hasRelated = props.expression.work[0].relatedFromConnection;
    const partOf = props.expression.work[0].partOfConnection;
    const hasPart = props.expression.work[0].hasPartConnection;
    const isSubjectWork = props.expression.work[0].isSubjectWorkConnection;
    const hasSubjectWork = props.expression.work[0].hasSubjectWorkConnection;
    const hasSubjectAgent = props.expression.work[0].hasSubjectAgentConnection;

    const related = isRelatedTo.totalCount + partOf.totalCount + hasSubjectWork.totalCount + hasSubjectAgent.totalCount;


    const handleClick = () => {
        const epos = selected.indexOf(uri)
        const selectedSet = new Set();
        selected.forEach((e) => selectedSet.add(e));
        if (epos === -1) {
            //Adding expression and child manifestation uri to list of selected
            selectedSet.add(uri);
            manifestations.forEach((m) => selectedSet.add(m.uri));
        } else {
            //Removing expression and child manifestation uri to list of selected
            selectedSet.delete(uri);
            manifestations.forEach((m) => selectedSet.delete(m.uri));
        }
        setSelectedState([...selectedSet]);
        //console.log(itemsSelected);
    };

    const description = () => {
        //console.log(content[0]);
        return <React.Fragment>
            <ListItemIcon>
                <IconTypes type={content[0]}/>
            </ListItemIcon>
            <ListItemText sx={{'max-width': '60%'}}
                className={selected.includes(uri) ? "selected" : ""}
                          primary={
                            <React.Fragment>
                                <Typography color="primary.main" component="span" variant="etitle">{title}</Typography>
                                {!isTranslation && <Typography color='grey.700' variant="wtitle" component="span"> ({worktitle})</Typography>}
                                {creators.slice(0,2).map(creator => <Typography variant="body2" key={creator[0] + creator[1]}>{creator[0] + creator[1]}</Typography>) }
                                {contributors.slice(0,2).map(contributor => <Typography variant="body2" key={contributor[0] + contributor[1]}>{contributor[0] + contributor[1]}</Typography>) }
                                {showUri && <Typography component="span" variant="body2">{props.expression.uri}</Typography>}
                                {(related > 0)  && <Typography variant="caption" component="div">
                                <details>
                                    <summary>Related</summary>
                                    {isRelatedTo.edges.map(x => <Typography component="div"key={x.role + x.node.label}>
                                        <Typography component="span" variant={"relatedprefix"}>{x.role + ": "}</Typography>
                                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                                    </Typography>)}
                                    {partOf.edges.map(x => <Typography component="div"key={"is part of" + x.node.label}>
                                        <Typography component="span" variant={"relatedprefix"}>{"is part of" + ": "}</Typography>
                                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                                    </Typography>)}
                                    {hasSubjectWork.edges.map(x => <Typography component="div"key={"has subject work" + x.node.label}>
                                        <Typography component="span" variant={"relatedprefix"}>{"has subject work" + ": "}</Typography>
                                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                                    </Typography>)}
                                    {hasSubjectAgent.edges.map(x => <Typography component="div"key={"has subject agent" + x.node.label}>
                                        <Typography component="span" variant={"relatedprefix"}>{"has subject agent" + ": "}</Typography>
                                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                                    </Typography>)}
                                </details>
                                </Typography>}
                            </React.Fragment>}
            />
            <ListItemSecondaryAction sx={{top:"0%", marginTop:"35px", width: '30%', textAlign: 'left'}}>
                <Typography color={"dimgray"} variant={"body2"}>{'Type of work: ' +  worktype.join(", ")}</Typography>
                <Typography color={"dimgray"} variant={"body2"}>{'Content type: ' +  content.join(", ")}</Typography>
                {(language.length !== 0) ? <Typography color={"dimgray"} variant={"body2"}>{'Language: ' +  language.join(", ")}</Typography> : ""}
            </ListItemSecondaryAction>
        </React.Fragment>
    }

    /* Moved expression-classname from paper to expression entry */
    return <Paper elevation={0} square key={props.expression.uri} sx={{mt: 2}}>
        {clickable ?
            <ListItemButton alignItems="flex-start" onClick={handleClick} className="expression">
                {description()}
            </ListItemButton>
            :
            <ListItem alignItems="flex-start" className="resultitem expression">
                {description()}
            </ListItem>
        }
        <List dense={true} sx={{pt: 0}}>
            {props.expression && props.expression.manifestations.slice(0,10).map(m => (<Manifestation manifestation={m} key={m.uri} checkboxes={props.checkboxes}/>))}
        </List>
    </Paper>
}