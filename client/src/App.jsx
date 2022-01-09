import CssBaseline from '@mui/material/CssBaseline';
import React, {useState, useEffect, useMemo} from 'react';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import debounce from 'lodash.debounce';
import ResultView from "./ResultView";
import Item from './Item';
import { ApolloProvider, ApolloClient, InMemoryCache } from '@apollo/client';

const cache = new InMemoryCache({
    typePolicies: { // Type policy map
        Expression: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Work: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Manifestation: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Agent: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Concept: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        }
    }
});


const client = new ApolloClient({
    uri: 'http://localhost:8080/graphql',
    cache: cache
});

export default function MyApp() {
    const [query, setQuery] = useState("rowling");

    const changeHandler = (event) => {
        setQuery(event.target.value);
    };

    const debouncedChangeHandler = useMemo(
        () => debounce(changeHandler, 800)
        , []);
    useEffect(() => {
        return () => {
            debouncedChangeHandler.cancel();
        }
    });

    return (
        <ApolloProvider client={client}>
        <React.Fragment>
            <CssBaseline/>
            <Grid container spacing={4} marginTop={2}>
                <Grid item xs={12}>
                    <Item>
                        <TextField
                            fullWidth
                            id="filled-search"
                            label="Search field"
                            type="search"
                            variant="filled"
                            onChange={debouncedChangeHandler}
                        /></Item>
                </Grid>
                <ResultView query={query}/>
            </Grid>
        </React.Fragment>
        </ApolloProvider>
    );
    /*export default function MyApp() {
        const [search, { loading, error, data, }] = useLazyQuery(GET_RESULTS);
        const debouncer = useCallback(_.debounce(search, 500), []);
        const [q, setQuery] = useState("rowling");

        const changeHandler = (event) => {
            setQuery(event.target.value);
            search({variables: {query: q, offset: 0}});
            console.log("change")
            if (loading) return <p>Loading ...</p>;
            if (error) return `Error! ${error}`;
        };

        const debouncedChangeHandler = useMemo(
            () => _.debounce(changeHandler, 800)
            , []);
        useEffect(() => {
            return () => {
                debouncedChangeHandler.cancel();
            }
        });

        return (
          <React.Fragment>
            <CssBaseline />
            <Grid container spacing={4} marginTop={2}>
              <Grid item xs={12}>
                <Item>
                    <TextField
                        fullWidth
                    id="filled-search"
                    label="Search field"
                    type="search"
                    variant="filled"
                    onChange={e => debouncer({ variables: { query: e.target.value } })}
                /></Item>
              </Grid>
              <Grid item xs={8}>
                <Item>
                    ITEM
                    { <ResultList expressions={data?.expressions && data.expressions}></ResultList> }
                </Item>
              </Grid>
              <Grid item xs={4}>
                <Item>Filters go here</Item>
              </Grid>
            </Grid>
          </React.Fragment>
      );*/
}