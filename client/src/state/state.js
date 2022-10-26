import {
    atom, selector
} from 'recoil';

// state with boolean value used to decide if URIs are displayed with entities or not
// primarily used for debugging
/*export const showUriState = atom({
    key: 'showUri', // unique ID (with respect to other atoms/selectors)
    default: false, // default value (aka initial value)
});*/

// state to manage selected items in the resultlist
export const selectedState = atom({
    key: 'selected',
    default: []
});
// State to manage if filters are  to be shown or not
export const filterState = atom({
    key: 'checked',
    default: []
    }
);

// state to manage configuration options
export const configState = atom({
    key: 'configState',
    default: ["Filters", "Clickable", "Formatting", "ShowURIs"]
});

export const showFiltersState = selector({
    key: 'showFilters',
    get: ({get}) => {
        const config = get(configState);
        if (config.includes("Filters")){
            const params = new URLSearchParams(window.location.search)
            if (params.get("filters") === "false"){
                return false;
            } else{
                return true;
            }
        }else{
            return true;
        }
    },
});

export const clickableState = selector({
    key: 'clickable',
    get: ({get}) => {
        const config = get(configState);
        if (config.includes("Clickable")){
            const params = new URLSearchParams(window.location.search)
            if (params.get("clickable") === "true"){
                return true;
            } else{
                return false;
            }
        }else{
            return false;
        }
    },
});

export const formattingState = selector({
    key: 'formatting',
    get: ({get}) => {
        const config = get(configState);
        if (config.includes("Formatting")){
            return true;
        }else{
            return false;
        }
    },
});

export const showUriState = selector({
    key: 'showuri',
    get: ({get}) => {
        const config = get(configState);
        if (config.includes("ShowURIs")){
            const params = new URLSearchParams(window.location.search)
            if (params.get("showuri") === "true"){
                return true;
            } else{
                return false;
            }
        }else{
            return false;
        }
    },
});


export default showUriState;