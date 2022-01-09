import React, {useState, createContext} from "react";

export const FilterContext = createContext();

export function FilterContextProvider(props){

    const [checked, setChecked] = useState([0]);

    const handleToggle = (value) => () => {
        const currentIndex = checked.indexOf(value);
        const newChecked = [...checked];

        if (currentIndex === -1) {
            newChecked.push(value);
        } else {
            newChecked.splice(currentIndex, 1);
        }

        setChecked(newChecked);
        //console.log(newChecked);
    };

    return <FilterContext.Provider value={[checked, handleToggle]}>
        {props.children}
    </FilterContext.Provider>
}
