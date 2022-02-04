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
        case ('Cartographic image'):
            return <MapIcon fontSize="small"/>;
        case ('Software'):
            return <ComputerIcon fontSize="small"/>;
        case ('Score'):
            return <QueueMusicIcon fontSize="small"/>;
        case ('Performed music'):
            return <MusicNoteIcon fontSize="small"/>;
        case ('Audio book'):
            return <HeadsetIcon fontSize="small"/>;
        case ('Illustrations'):
            return <PhotoIcon fontSize="small"/>;
        case ('Text'):
            return <MenuBookIcon fontSize="small"/>;
        case ('Movie (3D)'):
            return <LocalMoviesIcon fontSize="small"/>;
        case ('Movie'):
            return <LocalMoviesIcon fontSize="small"/>;
        default:
            return <QuestionMarkIcon fontSize="small"/>;
    }
};

export default ExpressionTypeIcon;