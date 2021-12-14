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

const Icon = props => {
    const { type } = props;
    switch (type){
        case ('cartographic image'):
            return <MapIcon/>;
        case ('computer program'):
            return <ComputerIcon/>;
        case ('notated music'):
            return <QueueMusicIcon/>;
        case ('performed music'):
            return <MusicNoteIcon/>;
        case ('spoken word'):
            return <HeadsetIcon/>;
        case ('still image'):
            return <PhotoIcon/>;
        case ('text'):
            return <MenuBookIcon />;
        case ('three-dimensional moving image'):
            return <LocalMoviesIcon/>;
        case ('two-dimensional moving image'):
            return <LocalMoviesIcon/>;
        default:
            return <QuestionMarkIcon/>;
    }
};

export default Icon;