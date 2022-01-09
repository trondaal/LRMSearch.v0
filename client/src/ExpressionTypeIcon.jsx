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

const ExpressionTypeIcon = props => {
    const { type } = props;
    switch (type){
        case ('cartographic image'):
            return <MapIcon fontSize="small"/>;
        case ('computer program'):
            return <ComputerIcon fontSize="small"/>;
        case ('notated music'):
            return <QueueMusicIcon fontSize="small"/>;
        case ('performed music'):
            return <MusicNoteIcon fontSize="small"/>;
        case ('spoken word'):
            return <HeadsetIcon fontSize="small"/>;
        case ('still image'):
            return <PhotoIcon fontSize="small"/>;
        case ('text'):
            return <MenuBookIcon fontSize="small"/>;
        case ('three-dimensional moving image'):
            return <LocalMoviesIcon fontSize="small"/>;
        case ('two-dimensional moving image'):
            return <LocalMoviesIcon fontSize="small"/>;
        default:
            return <QuestionMarkIcon fontSize="small"/>;
    }
};

export default ExpressionTypeIcon;