import React from "react";
import MenuBookTwoToneIcon from "@mui/icons-material/MenuBookTwoTone";
import LocalMoviesTwoToneIcon from '@mui/icons-material/LocalMovies';
import PhotoTwoToneIcon from '@mui/icons-material/PhotoTwoTone';
import HeadsetTwoToneIcon from '@mui/icons-material/HeadsetTwoTone';
import MusicNoteTwoToneIcon from '@mui/icons-material/MusicNoteTwoTone';
import QueueMusicTwoToneIcon from '@mui/icons-material/QueueMusicTwoTone';
import ComputerTwoToneIcon from '@mui/icons-material/ComputerTwoTone';
import MapTwoToneIcon from '@mui/icons-material/MapTwoTone';
import QuestionMarkTwoToneIcon from '@mui/icons-material/QuestionMarkTwoTone';
import AudiotrackTwoToneIcon from '@mui/icons-material/AudiotrackTwoTone';
import GrainTwoToneIcon from '@mui/icons-material/GrainTwoTone';

const IconTypes = props => {
    const { type } = props;
    switch (type){
        case ('Maps'):
            return <MapTwoToneIcon fontSize="large"/>;
        case ('Software'):
            return <ComputerTwoToneIcon fontSize="large"/>;
        case ('Score'):
            return <QueueMusicTwoToneIcon fontSize="large"/>;
        case ('Performed music'):
            return <MusicNoteTwoToneIcon fontSize="large"/>;
        case ('Audio book'):
            return <HeadsetTwoToneIcon fontSize="large"/>;
        case ('Illustrations'):
            return <PhotoTwoToneIcon fontSize="large"/>;
        case ('Text'):
            return <MenuBookTwoToneIcon fontSize="large"/>;
        case ('Movie (3D)'):
            return <LocalMoviesTwoToneIcon fontSize="large"/>;
        case ('Movie'):
            return <LocalMoviesTwoToneIcon fontSize="large"/>;
        case ('Music'):
            return <AudiotrackTwoToneIcon fontSize="large"/>;
        case ('Tactile text'):
            return <GrainTwoToneIcon fontSize="large"/>;
        default:
            return <QuestionMarkTwoToneIcon fontSize="large"/>;
    }
};

export default IconTypes;