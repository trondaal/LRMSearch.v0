import {InMemoryCache, makeVar} from "@apollo/client";

export const filtersVar = makeVar([]);
export const selectedVar = makeVar(new Set());

export const Cache = new InMemoryCache({
    typePolicies: { // Type policy map
        Expression: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        //console.log()
                        return selectedVar().has(readField('uri'));
                    }
                }
            }
        },
        Concept: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        //console.log()
                        return (filtersVar().findIndex(i => i.includes(readField('uri'))) > -1)
                    }
                }
            }
        },
        ExpressionCreatorsRelationship: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        const key = 'Agent' + "+" + readField('role') + "+" + readField('node').uri
                        return filtersVar().findIndex(i => i.includes(key)) > -1 ;
                    }
                }
            }
        },
        WorkCreatorsRelationship: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        const key = 'Agent' + "+" + readField('role') + "+" + readField('node').uri
                        return filtersVar().findIndex(i => i.includes(key)) > -1 ;
                    }
                }
            }
        },
        ManifestationCreatorsRelationship: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        const key = 'Agent' + "+" + readField('role') + "+" + readField('node').uri
                        return filtersVar().findIndex(i => i.includes(key)) > -1 ;
                    }
                }
            }
        }/*,
        ExpressionCreatorsRelationship: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        WorkCreatorsRelationship: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Concept: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        }*/
    }
});