import {InMemoryCache, makeVar} from "@apollo/client";

export const filtersVar = makeVar([]);

export const Cache = new InMemoryCache({
    typePolicies: { // Type policy map
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
                            return false;
                    }
                }
            }
        },
        WorkCreatorsRelationship: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        return false;

                    }
                }
            }
        },
        ManifestationCreatorsRelationship: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        return false;

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