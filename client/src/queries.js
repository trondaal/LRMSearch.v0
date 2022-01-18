import {gql} from "@apollo/client";

export const GET_RESULTS = gql`
    query ($query: String!){
        expressions(fulltext: {expressions: {phrase: $query}}){
            title,
            titlepreferred,
            titlevariant,
            uri,
            language{
                checked @client,
                label,
                uri
            }
            content{
                checked @client,
                label,
                uri
            }
            creatorsConnection{
                edges{
                    checked @client,
                    node{
                        name,
                        uri
                    },
                    role
                }
            }
            work{
                title,
                type{
                    checked @client,
                    label,
                    uri
                }
                creatorsConnection{
                    edges{
                        checked @client,
                        node{
                            name,
                            uri
                        },
                        role
                    }
                }
            },
            manifestations{
                uri,
                identifier,
                title,
                subtitle,
                numbering,
                part,
                responsibility,
                edition,
                extent,
                dimensions,
                productionplace,
                producer,
                productiondate,
                publicationplace,
                publisher,
                publicationdate,
                distributionplace,
                distributor,
                distributiondate,
                manufactureplace,
                manufacturer,
                manufacturedate,
                copyright,
                series,
                seriesnumbering,
                carrier{
                    uri,
                    label
                },
                media{
                    uri,
                    label
                },
                creatorsConnection{
                    edges{
                        checked @client,
                        node{
                            name,
                            uri
                        },
                        role
                    }
                }
            }
        }
    }
`