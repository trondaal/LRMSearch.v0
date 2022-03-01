import {
    atom
} from 'recoil';

// state with boolean value used to decide if URIs are displayed with entities or not
// primarily used for debugging
export const showUriState = atom({
    key: 'showUri', // unique ID (with respect to other atoms/selectors)
    default: false, // default value (aka initial value)
});

// state to control if the list of filters is visible or not
export const showFiltersState = atom({
    key: 'showFilters', // unique ID (with respect to other atoms/selectors)
    default: true, // default value (aka initial value)
});

// state to control if resultitems can be selected or not
export const selectableState = atom({
    key: 'selectable', // unique ID (with respect to other atoms/selectors)
    default: true, // default value (aka initial value)
});

// state to control if result listing is styled or not
export const styledState = atom({
    key: 'styled', // unique ID (with respect to other atoms/selectors)
    default: true, // default value (aka initial value)
});

// state to manage selected items in the resultlist
export const itemsSelectedState = atom({
    key: 'itemsSelected',
    default: []
});

export const filterState = atom({
    key: 'checked',
    default: []
    }
);

export default showUriState;