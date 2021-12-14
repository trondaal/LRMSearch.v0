
import CssBaseline from '@mui/material/CssBaseline';
import React, {useState, useEffect, useMemo} from 'react';
import { styled } from '@mui/material/styles';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import debounce from 'lodash.debounce';
import Results from "./Results";
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Divider from '@mui/material/Divider';
import ListItemText from '@mui/material/ListItemText';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import Avatar from '@mui/material/Avatar';
import Typography from '@mui/material/Typography';
import MenuBookIcon from '@mui/icons-material/MenuBook';
import { deepOrange, green } from '@mui/material/colors';

const Item = styled(Paper)(({ theme }) => ({
    ...theme.typography.body2,
    padding: theme.spacing(1),
    textAlign: 'center',
    color: theme.palette.text.secondary,
}));


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
      <React.Fragment>
        <CssBaseline />
        <Grid container spacing={4} marginTop={2}>
          <Grid item xs={12}>
            <Item>
                <TextField
                    fullWidth="true"
                id="filled-search"
                label="Search field"
                type="search"
                variant="filled"
                onChange={debouncedChangeHandler}
            /></Item>
          </Grid>
          <Grid item xs={8}>
            <Item>
                <Results query={query}></Results>
            </Item>
          </Grid>
          <Grid item xs={4}>
            <Item>Filters go here</Item>
          </Grid>
        </Grid>
      </React.Fragment>
  );
}