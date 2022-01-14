import {gql} from "@apollo/client";

export const GET_RESULTS = gql`
    query ($query: String!){
        expressions(fulltext: {expressions: {phrase: $query}}){
            checked @client,
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
            work{
                checked @client,
                title,
                type{
                    checked @client,
                    label,
                    uri
                }
                creatorsConnection{
                    edges{
                        node{
                            name,
                            uri
                        },
                        role
                    }
                }
            },
            manifestations{
                checked @client,
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
                        name,
                        uri
                    },
                    role
                }
            }
        }
    }
`