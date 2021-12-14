import React from 'react';
import { useQuery, gql } from '@apollo/client';
import List from '@mui/material/List';
import ListItem from "@mui/material/ListItem";
import ListItemAvatar from "@mui/material/ListItemAvatar";
import Avatar from "@mui/material/Avatar";
import {green, grey} from "@mui/material/colors";
import MenuBookIcon from "@mui/icons-material/MenuBook";
import ListItemText from "@mui/material/ListItemText";
import Typography from "@mui/material/Typography";
import Divider from "@mui/material/Divider";
import Icon from "./Icon";


const GET_RESULTS = gql`
    query ($query: String!){
        expressions(fulltext: {expressions: {phrase: $query}}){
            title,
            uri,
            language{
                label
            }
            content{
                label
            }
            work{
                title,
                type{
                    label
                }
                creatorsConnection{
                    edges{
                        node{
                            name
                        },
                        role
                    }
                }
            },
            manifestations{
                uri,
                identifier,
                title,
                subtitle,
                numbering,
                part,
                responsibility,
                edition,
                extent,
                dimensions,
                productionplace,
                producer,
                productiondate,
                publicationplace,
                publisher,
                publicationdate,
                distributionplace,
                distributor,
                distributiondate,
                manufactureplace,
                manufacturer,
                manufacturedate,
                copyright,
                series,
                seriesnumbering,
                carrier{label}
                media{label}
            }
            creatorsConnection{
                edges{
                    node{
                        name
                    },
                    role
                }
            }
        }
    }
`
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
    if (!isEmpty(extent)) metadata.push(extent);
    if (!isEmpty(edition)) metadata.push(edition);

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

    if (!isEmpty(identifier)) metadata.push(identifier);

    return <ListItem>
                <ListItemText inset
                                primary={statement.join(" / ")}
                                secondary={metadata.join(", ")}>
                </ListItemText>
    </ListItem>
}

function Expression(props){
    const title = props.expression.title;
    const creators = props.expression.work[0].creatorsConnection.edges.map(e => e.node.name + " (" + e.role + ")").join(', ');
    const type = props.expression.work[0].type.map(t => t.label).join(', ');
    const language = props.expression.language.map(l => l.label).join(', ');
    const content = props.expression.content.map(c => c.label).join(', ');
    const contributors = props.expression.creatorsConnection.edges.map(e => e.node.name + " (" + e.role + ")").join(', ');

    const categories = [];
    if (type !== '')
        categories.push(type.toLowerCase());
    if (content !== '')
        categories.push(content.toLowerCase());
    if (language !== '')
        categories.push(language.toLowerCase());

    return <React.Fragment>
        <ListItem alignItems="flex-start">
            <ListItemAvatar>
                <Avatar sx={{ bgcolor: grey[500] }}>
                    <Icon type={content.split(", ")[0]} />
                </Avatar>
            </ListItemAvatar>
            <ListItemText
                primary={title + " / "+ creators}
                secondary={
                    <React.Fragment>
                        <Typography
                            sx={{ display: 'inline' }}
                            component="span"
                            variant="body2"
                            color="text.primary"
                        >
                            {"" + categories.join(' - ') + " / " + contributors}
                        </Typography>
                    </React.Fragment>
                }
            />
        </ListItem>
        <List component="div" disablePadding>
            {props.expression && props.expression.manifestations.map(m => (<Manifestation manifestation={m} key={m.uri}/>))}
        </List>
        <Divider variant="inset" component="li" />
    </React.Fragment>
}

export default function Results(props){
    const { loading, error, data, refetch} = useQuery(GET_RESULTS, {
        variables: {query: props.query, offset: 0},
        fetchPolicy: "cache-and-network"
    });

    if (error)
        console.log(error);

    console.log(data);

    return (<List sx={{ width: '100%', bgcolor: 'background.paper' }}>
        {data && data.expressions.map(x => (<Expression expression={x} key={x.uri}/>))}
        </List>);
}