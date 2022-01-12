import {InMemoryCache} from "@apollo/client";

export const Cache = new InMemoryCache({
    typePolicies: { // Type policy map
        Expression: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Work: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Manifestation: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
                    read(_, { variables }) { // The read function for the isInCart field
                        return true;
                    }
                }
            }
        },
        Agent: {
            fields: { // Field policy map for the Product type
                visible: { // Field policy for the isInCart field
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
        }
    }
});