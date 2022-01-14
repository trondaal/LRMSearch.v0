import {InMemoryCache, ReactiveVar, makeVar} from "@apollo/client";

export const filtersVar = makeVar(["dummy"]);

export const Cache = new InMemoryCache({
    typePolicies: { // Type policy map
        Expression: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read() { // The read function for the isInCart field
                        return filtersVar();
                    }
                }
            }
        },
        Work: {
            fields: { // Field policy map for the Product type
                checked: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Manifestation: {
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
                checked: { // Field policy for the isInCart field
                    read(_, { readField }) { // The read function for the isInCart field
                        if (filtersVar().indexOf(readField('uri') + "|+|" + "Language")){
                            return true;
                        }else{
                            return false;
                        }
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