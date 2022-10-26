import * as React from 'react';
import Box from '@mui/material/Box';
import Popper from '@mui/material/Popper';
import Button from '@mui/material/Button';

export default function Related() {
    const [anchorEl, setAnchorEl] = React.useState(null);

    const handleClick = (event) => {
        setAnchorEl(anchorEl ? null : event.currentTarget);
    };

    const open = Boolean(anchorEl);
    const id = open ? 'simple-popper' : undefined;

    return (
        <div>
            <Button aria-describedby={id} variant="outlined" size="small" onClick={handleClick}>
                More
            </Button>
            <Popper id={id} open={open} anchorEl={anchorEl} placement={'left-start'}>
                <Box sx={{ border: 1, p: 1, bgcolor: 'background.paper' }}>
                    <ul>
                        <li>related 1 very long with a link</li>
                        <li>related 2</li>
                        <li>related 3</li>
                        <li>related 4</li>
                        <li>related 5</li>
                        <li>related 6</li>
                    </ul>
                </Box>
            </Popper>
        </div>
    );
}