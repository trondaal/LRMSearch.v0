import React from 'react';
import List from '@mui/material/List';
import Typography from "@mui/material/Typography";
import ListItemText from "@mui/material/ListItemText";
import IconTypes from "./IconTypes";
import Paper from "@mui/material/Paper";
import "./ResultList.css";
import {groupBy} from "lodash";
import {ListItemSecondaryAction} from "@mui/material";
import ListItemButton from '@mui/material/ListItemButton';
import ListItem from '@mui/material/ListItem';
import Manifestation from "./Manifestation";
import {useRecoilState} from 'recoil';
import {itemSelectedState, selectableState, showUriState, styledState} from "../state/state";
import ListItemIcon from "@mui/material/ListItemIcon";
import "./ResultList.css";

function isEmpty(str) {
    return (!str || str.length === 0 );
}

export default function Expression(props){
    const [showUri] = useRecoilState(showUriState);
    const [itemSelected, setItemSelected] = useRecoilState(itemSelectedState);
    const [selectable] = useRecoilState(selectableState);
    const [styled] = useRecoilState(styledState);
    const {uri} = props.expression;

    //console.log("Expression : " + props.checkboxes);
    const worktitle = !isEmpty(props.expression.work[0].title) ? props.expression.work[0].title : "";

    const titles = [];
    if (!isEmpty(props.expression.titlepreferred)) titles.push(props.expression.titlepreferred);
    if (!isEmpty(props.expression.title)) titles.push(props.expression.title);
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
    creatorsmap.Producer && creators.push(["Producer: ", (creatorsmap.Producer.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Composer && creators.push(["Composer: ", (creatorsmap.Composer.map(a => a.node.name)).join(" ; ")]);
    creatorsmap.Lyricist && creators.push(["Lyricist: ", (creatorsmap.Lyricist.map(a => a.node.name)).join(" ; ")]);
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

    const handleClick = () => {
        console.log(itemSelected);
        const pos = itemSelected.indexOf(uri)
        if (pos === -1) {
            setItemSelected([...itemSelected, uri]);
        } else {
            setItemSelected([...itemSelected.slice(0, pos), ...itemSelected.slice(pos + 1)]);
        }
    };

    const description = () => {
        return <React.Fragment>
            <ListItemIcon>
                <IconTypes type={content[0]}/>
            </ListItemIcon>
            <ListItemText className={itemSelected.includes(uri) ? "selected" : ""}
                          primary={
                            <React.Fragment>
                                <Typography color="primary.main" component="span" variant="etitle">{title}</Typography>
                                {!isTranslation && <Typography color='grey.700' variant="wtitle" component="span"> ({worktitle})</Typography>}
                            </React.Fragment>}
                          secondary={
                              <React.Fragment>
                                  {creators.slice(0,2).map(creator => <Typography variant="body2" key={creator[0] + creator[1]}>{creator[0] + creator[1]}</Typography>) }
                                  {contributors.slice(0,2).map(contributor => <Typography variant="body2" key={contributor[0] + contributor[1]}>{contributor[0] + contributor[1]}</Typography>) }
                                  {showUri && <Typography variant="body2">{props.expression.uri}</Typography>}
                              </React.Fragment>}
            />
            <ListItemSecondaryAction sx={{top:"0%", marginTop:"35px", width: '20%', textAlign: 'left'}}>
                <Typography color={"dimgray"} variant={"body2"}>{'Content type: ' +  content.join(", ")}</Typography>
                {(language.length !== 0) ? <Typography color={"dimgray"} variant={"body2"}>{'Language: ' +  language.join(", ")}</Typography> : ""}
            </ListItemSecondaryAction>
        </React.Fragment>
    }

    /* Moved expression-classname from paper to expression entry */
    return <Paper elevation={0} square key={props.expression.uri} sx={{mt: 2}}>
        {selectable ?
            <ListItemButton alignItems="flex-start" onClick={handleClick} className="expression">
                {description()}
            </ListItemButton>
            :
            <ListItem alignItems="flex-start" className="resultitem expression">
                {description()}
            </ListItem>
        }
        <List dense={true} sx={{pt: 0}}>
            {props.expression && props.expression.manifestations.slice(0,5).map(m => (<Manifestation manifestation={m} key={m.uri} checkboxes={props.checkboxes}/>))}
        </List>
    </Paper>
}