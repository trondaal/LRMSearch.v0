import {InMemoryCache, makeVar} from "@apollo/client";

export const selectedVar = makeVar(new Set());

export const Cache = new InMemoryCache({
    typePolicies: {
        Expression: {
            fields: {
                checked: {
                    read(_, { readField }) { // The read function for the isInCart field
                        return selectedVar().has(readField('uri'));
                    }
                }
            }
        }
    }
});