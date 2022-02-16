import React from "react";
import MenuBookIcon from "@mui/icons-material/MenuBook";
import LocalMoviesIcon from '@mui/icons-material/LocalMovies';
import PhotoIcon from '@mui/icons-material/Photo';
import HeadsetIcon from '@mui/icons-material/Headset';
import MusicNoteIcon from '@mui/icons-material/MusicNote';
import QueueMusicIcon from '@mui/icons-material/QueueMusic';
import ComputerIcon from '@mui/icons-material/Computer';
import MapIcon from '@mui/icons-material/Map';
import QuestionMarkIcon from '@mui/icons-material/QuestionMark';
import AudiotrackIcon from '@mui/icons-material/Audiotrack';

const IconTypes = props => {
    const { type } = props;
    switch (type){
        case ('Maps'):
            return <MapIcon fontSize="large"/>;
        case ('Software'):
            return <ComputerIcon fontSize="large"/>;
        case ('Score'):
            return <QueueMusicIcon fontSize="large"/>;
        case ('Performed music'):
            return <MusicNoteIcon fontSize="large"/>;
        case ('Audio book'):
            return <HeadsetIcon fontSize="large"/>;
        case ('Illustrations'):
            return <PhotoIcon fontSize="large"/>;
        case ('Text'):
            return <MenuBookIcon fontSize="large"/>;
        case ('Movie (3D)'):
            return <LocalMoviesIcon fontSize="large"/>;
        case ('Movie'):
            return <LocalMoviesIcon fontSize="large"/>;
        case ('Music'):
            return <AudiotrackIcon fontSize="large"/>;
        default:
            return <QuestionMarkIcon fontSize="large"/>;
    }
};

export default IconTypes;