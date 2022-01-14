import React, {useState, createContext} from "react";
import {filtersVar} from './Cache';


export const FilterContext = createContext();

export function FilterContextProvider(props){

    const [checked, setChecked] = useState([]);

    const handleToggle = (value) => () => {

        const filter = value.uri + "|+|" + value.category;
        const filters = filtersVar();
        const idx = filters.indexOf(filter)
        //console.log(filters);

        if (idx === -1) {
            filtersVar([...filters, filter]);
        } else {
            filtersVar([...filters.slice(0, idx), ...filters.slice(idx + 1)]);
        }
        //filtersVar([...filters, filter]);
        console.log(filter);


        const currentIndex = checked.findIndex(x => x.uri === value.uri && x.category === value.category );
        const newChecked = [...checked];

        if (currentIndex === -1) {
            newChecked.push(value);
            if (value.target === "Agent") {
                sessionStorage.setItem(value.uri + "/" + value.category, value.category);
            }else{
                sessionStorage.setItem(value.uri, value.uri);
            }
        } else {
            newChecked.splice(currentIndex, 1);
            if (value.target === "Agent") {
                sessionStorage.removeItem(value.uri + "/" + value.category);
            }else{
                sessionStorage.removeItem(value.uri);
            }
        }
        setChecked(newChecked);
        //console.log(checked);
    };

    const clear = () => {sessionStorage.clear();setChecked([]);}

    return <FilterContext.Provider value={[checked, handleToggle, clear]}>
        {props.children}
    </FilterContext.Provider>
}
