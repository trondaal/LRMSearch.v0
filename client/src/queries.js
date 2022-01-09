import {gql} from "@apollo/client";

export const GET_RESULTS = gql`
    query ($query: String!){
        expressions(fulltext: {expressions: {phrase: $query}}){
            visible @client,
            title,
            titlepreferred,
            titlevariant,
            uri,
            language{
                visible @client,
                label,
                uri
            }
            content{
                visible @client,
                label,
                uri
            }
            work{
                visible @client,
                title,
                type{
                    visible @client,
                    label,
                    uri
                }
                creatorsConnection{
                    edges{
                        node{
                            visible @client,
                            name,
                            uri
                        },
                        role
                    }
                }
            },
            manifestations{
                visible @client,
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
                carrier{label}
                media{label}
            }
            creatorsConnection{
                edges{
                    node{
                        visible @client,
                        name,
                        uri
                    },
                    role
                }
            }
        }
    }
`