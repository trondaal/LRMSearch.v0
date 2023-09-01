import React from 'react';
import List from '@mui/material/List';
import Typography from "@mui/material/Typography";
import ListItemText from "@mui/material/ListItemText";
import IconTypes from "./IconTypes";
import Paper from "@mui/material/Paper";
import Popover from '@mui/material/Popover';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import ButtonGroup from '@mui/material/ButtonGroup';
import "./ResultList.css";
import {groupBy} from "lodash";
import {ListItemSecondaryAction} from "@mui/material";
import ListItemButton from '@mui/material/ListItemButton';
import ListItem from '@mui/material/ListItem';
import KeyboardArrowUpIcon from '@mui/icons-material/KeyboardArrowUp';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import KeyboardDoubleArrowUpIcon from '@mui/icons-material/KeyboardDoubleArrowUp';
import RemoveCircleOutlineIcon from '@mui/icons-material/RemoveCircleOutline';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import ArrowCircleDownIcon from '@mui/icons-material/ArrowCircleDown';
import ArrowCircleUpIcon from '@mui/icons-material/ArrowCircleUp';
import KeyboardDoubleArrowDownIcon from '@mui/icons-material/KeyboardDoubleArrowDown';
import ClearIcon from '@mui/icons-material/Clear';
import Manifestation from "./Manifestation";
import {useRecoilState} from 'recoil';
import {showUriState, clickableState, selectedState} from "../state/state";
import ListItemIcon from "@mui/material/ListItemIcon";
import "./ResultList.css";
import Related from "./Related"
import {rankingVar} from "../api/Cache";
import Tooltip from '@mui/material/Tooltip';

function moveLeft(arr, index) {
    if (index > 0 && index < arr.length) {
        const temp = arr[index];
        arr[index] = arr[index - 1];
        arr[index - 1] = temp;
    }
    return arr;
}

function moveRight(arr, index) {
    if (index >= 0 && index < arr.length - 1) {
        const temp = arr[index];
        arr[index] = arr[index + 1];
        arr[index + 1] = temp;
    }
    return arr;
}

function isEmpty(str) {
    return (!str || str.length === 0 );
}

function capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function plurals(str){
    //Returns an s to be added to a role in case of multiple agents
    if (str.includes(' ; ')){
        return 's';
    }else{
        return ''
    }
}

export default function Expression(props){
    const [showUri] = useRecoilState(showUriState);
    const [selected, setSelectedState] = useRecoilState(selectedState);
    const [clickable] = useRecoilState(clickableState);
    const {uri, manifestations} = props.expression;
    const worktitle = !isEmpty(props.expression.work[0].title) ? props.expression.work[0].title : "";
    const titles = [];
    if (!isEmpty(props.expression.titlepreferred)){
        titles.push(props.expression.titlepreferred);
    }else{
        if (!isEmpty(props.expression.title)) titles.push(props.expression.title);
    }

    const title = titles[0];
    const isTranslation = titles.find(element => element.toLowerCase().replace(/[^a-z]/g, '').includes(worktitle.toLowerCase().replace(/[^a-z]/g, '')))

    //roles that should default be displayed, in the order they should be presented, contains both work and expression roles
    const primaryroles = ['Author', 'Creator', 'Artist', 'Director', 'Producer', 'Composer', 'Lyricist', 'Interviewer', 'Interviewee', 'Honouree', 'Compiler', 'Translator', 'Narrator', 'Abridger', 'Editor'];

    const creatorsmap = groupBy(props.expression.work[0].creatorsConnection.edges, a => a.role);
    const creators = [];
    for (const r in creatorsmap){
        if (primaryroles.includes(r)) {
            creatorsmap[r] && creators.push([r, (creatorsmap[r].map(a => a.node.name)).join(" ; ")]);
        }
    }

    const contributorsmap = groupBy(props.expression.creatorsConnection.edges, a => a.role);
    const contributors = [];
    for (const r in contributorsmap){
        if (primaryroles.includes(r)) {
            contributorsmap[r] && contributors.push([r, (contributorsmap[r].map(a => a.node.name)).join(" ; ")]);
        }
    }

    const others = [];
    for (const k in creatorsmap){
        if (!primaryroles.includes(k)){
            others.push([k, (creatorsmap[k].map(a => a.node.name)).join(" ; ")]);
        }
    }

    for (const k in contributorsmap){
        if (!primaryroles.includes(k)){
            others.push([k, (contributorsmap[k].map(a => a.node.name)).join(" ; ")]);
        }
    }

    let showRelated = false;

    if (others.length > 0){
        showRelated = true;
    }

    const language = props.expression.language.map(l => l.label);
    const content = props.expression.content.map(c => c.label);
    content.sort();
    content.reverse();
    const worktype = props.expression.work[0].type.map(c => c.label);


    //const isRelatedToMap = groupBy(props.expression.work[0].relatedToConnection.edges, a => a.role);
    //console.log(isRelatedToMap);
    //console.log(props.expression.work[0].relatedToConnection)

    const isWorkRelatedToWork = props.expression.work[0].relatedToConnection;
    const hasRelated = props.expression.work[0].relatedFromConnection;
    const partOf = props.expression.work[0].partOfConnection;
    const hasPart = props.expression.work[0].hasPartConnection;
    const isSubjectWork = props.expression.work[0].isSubjectWorkConnection;
    const hasSubjectWork = props.expression.work[0].hasSubjectWorkConnection;
    const hasSubjectAgent = props.expression.work[0].hasSubjectAgentConnection;
    const isExpressionRelatedToExpression = props.expression.relatedToConnection;

    if (isWorkRelatedToWork.totalCount > 0){
        showRelated = true;
    }
    if (partOf.totalCount > 0){
        showRelated = true;
    }
    if (hasSubjectWork.totalCount > 0){
        showRelated = true;
    }
    if (hasSubjectAgent.totalCount > 0){
        showRelated = true;
    }
    if (isExpressionRelatedToExpression.totalCount > 0){
        showRelated = true;
    }

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
        return <React.Fragment>
                <Typography color="primary.main" component="div" variant="etitle" align="left">{title}
                {!isTranslation && <Typography color='grey.700' variant="wtitle" component="span"> ({worktitle})</Typography>}
                </Typography>
                {creators.map(creator => <Typography component="div" align="left" variant="body2" key={creator[0] + creator[1]}>{creator[0] + plurals(creator[1]) + ": " + creator[1]}</Typography>) }
                {contributors.map(contributor => <Typography component="div" align="left" variant="body2" key={contributor[0] + contributor[1]}>{contributor[0] + plurals(contributor[1]) + ": " + contributor[1]}</Typography>) }
                {showUri && <Typography component="div" align="left" variant="body2">{props.expression.uri}</Typography>}
                {showRelated  && <Typography component="div" align="left" variant="body2" >
                <details>
                    <summary>More</summary>
                    {others.map(other => <Typography component="div" key={other[0] + other[1]}>
                        <Typography component="span" variant={"relatedprefix"}>{other[0] + plurals(other[1]) + ": "}</Typography>
                        <Typography component="span" variant={"relatedlabel"}>{other[1]}</Typography>
                    </Typography>) }
                    {isWorkRelatedToWork.edges.map(x => <Typography component="div"key={x.role + x.node.label}>
                        <Typography component="span" variant={"relatedprefix"}>{capitalize(x.role) + ": "}</Typography>
                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                    </Typography>)}
                    {partOf.edges.map(x => <Typography component="div"key={"is part of" + x.node.label}>
                        <Typography component="span" variant={"relatedprefix"}>{"Is part of: "}</Typography>
                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                    </Typography>)}
                    {hasSubjectWork.edges.map(x => <Typography component="div"key={"has subject work" + x.node.label}>
                        <Typography component="span" variant={"relatedprefix"}>{"Has subject work: "}</Typography>
                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                    </Typography>)}
                    {hasSubjectAgent.edges.map(x => <Typography component="div"key={"has subject agent" + x.node.label}>
                        <Typography component="span" variant={"relatedprefix"}>{"Has subject agent: "}</Typography>
                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                    </Typography>)}
                    {isExpressionRelatedToExpression.edges.map(x => <Typography component="div"key={x.role + x.node.label}>
                        <Typography component="span" variant={"relatedprefix"}>{capitalize(x.role) + ": "}</Typography>
                        <Typography component="span" variant={"relatedlabel"}>{x.node.label}</Typography>
                    </Typography>)}
                </details>
                </Typography>}
        </React.Fragment>
    }

    /* Moved expression-classname from paper to expression entry */
    return <div style={{'--ranking': `${props.expression.ranking}`}} className={"expression"} key={props.expression.uri}>
                <div className={(props.expression.ranking === - 1) ? "expressionLeft" : "expressionLeft ranked"}>
                    <IconTypes type={content[0]}/>
                    <div className={"rankingbuttons"}>
                        {rankingVar().indexOf(props.expression.uri) === -1 &&
                        <Tooltip title={"Add to list of ranked"} placement={"right"}>
                            <IconButton size="small" onClick={() => {
                                //Adding or moving to the end so that up => highest index in the ranking array
                                let arr = rankingVar();
                                let index = arr.indexOf(props.expression.uri);
                                if (index === -1) {
                                    arr.unshift(props.expression.uri);
                                }else {
                                    arr.push(arr.splice(index, 1)[0]);
                                }
                                rankingVar([...arr]);
                                localStorage.setItem(sessionStorage.getItem('query').toLowerCase(), JSON.stringify(rankingVar()));
                            }}>
                                <AddCircleOutlineIcon color="action" fontSize="small"/>
                            </IconButton>
                        </Tooltip> }
                        {rankingVar().indexOf(props.expression.uri) > -1 && rankingVar().indexOf(props.expression.uri) < (rankingVar().length - 1) ?
                            <Tooltip title={"Move up in the list of ranked"} placement={"right"}>
                            <IconButton size="small" fontSize={"small"} onClick={() => {
                                //Adding or moving to the end so that up => highest index in the ranking array
                                let arr = moveRight(rankingVar(), rankingVar().indexOf(props.expression.uri));
                                rankingVar([...arr]);
                                localStorage.setItem(sessionStorage.getItem('query').toLowerCase(), JSON.stringify(rankingVar()));
                            }}><ArrowCircleUpIcon color="action" fontSize="small"/></IconButton></Tooltip> : <span/>}
                        {rankingVar().indexOf(props.expression.uri) > 0 ?
                            <Tooltip title={"Move down in the list of ranked"} placement={"right"}>
                            <IconButton size="small"  onClick={() => {
                                //Adding or moving to the end so that up => highest index in the ranking array
                                let arr = moveLeft(rankingVar(), rankingVar().indexOf(props.expression.uri));
                                rankingVar([...arr]);
                                localStorage.setItem(sessionStorage.getItem('query').toLowerCase(), JSON.stringify(rankingVar()));
                            }}><ArrowCircleDownIcon color="action" fontSize="small"/></IconButton></Tooltip> : <span/>}
                        {rankingVar().indexOf(props.expression.uri) > -1 ?
                            <Tooltip title={"Remove from list of ranked"} placement={"right"}>
                            <IconButton size="small" onClick={() => {
                                //Adding or moving to the end so that up => highest index in the ranking array
                                let arr = rankingVar();
                                let index = arr.indexOf(props.expression.uri);
                                if (index === -1) {
                                    //do nothing
                                } else {
                                    arr.splice(index, 1);
                                }
                                rankingVar([...arr]);
                                localStorage.setItem(sessionStorage.getItem('query').toLowerCase(), JSON.stringify(rankingVar()));
                            }}>
                                <RemoveCircleOutlineIcon color="action" fontSize="small"/>
                            </IconButton>
                        </Tooltip> : <span/>}
                    </div>
                </div>

                <div className="resultitem expression expressionRight">
                    <div className={"expressionHeader"}>
                        <div className={"expressionHeaderTitle"}>
                            {description()}
                        </div>
                        <div className={"expressionHeaderTypes"}>
                            {/*<Typography color={"dimgray"} component="div" align="left" variant={"body2"}>{'Type of work: ' +  worktype.join(", ")}</Typography>*/}
                                <Typography color={"dimgray"} component="div" align="left" variant={"body2"}>{'Content type: ' +  content.join(", ")}</Typography>
                                {(language.length !== 0) ? <Typography color={"dimgray"} component="div" align="left" variant={"body2"}>{'Language: ' +  language.join(", ")}</Typography> : ""}
                        </div>
                    </div>
                    <div className={"expressionManifestationListing"}>
                        <ul>
                            {props.expression && props.expression.manifestations.slice(0,10).map(m => (<Manifestation manifestation={m} key={m.uri} checkboxes={props.checkboxes}/>))}
                        </ul>
                    </div>
                </div>
            </div>

}