import {InMemoryCache, makeVar} from "@apollo/client";

export const selectedVar = makeVar(new Set());

export const rankingVar = makeVar([]);

export const Cache = new InMemoryCache({
    typePolicies: {
        ExpressionFulltextResult: {
            fields: {
                ranking: {
                    read(_, { readField }) { // The read function for the isInCart field
                        return rankingVar().indexOf(readField('uri', readField('expression')));
                    }
                }
            }
        },
        Expression: {
            fields: {
                checked: {
                    read(_, { readField }) { // The read function for the isInCart field
                        return selectedVar().has(readField('uri'));
                    }
                },
                ranking: {
                    read(_, { readField }) { // The read function for the isInCart field
                        return rankingVar().indexOf(readField('uri'));
                    }
                }
            }
        }
    }
});