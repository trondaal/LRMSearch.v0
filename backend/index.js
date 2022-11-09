const { Neo4jGraphQL } = require("@neo4j/graphql");
const { ApolloServer, gql } = require("apollo-server");
const neo4j = require("neo4j-driver");

// noinspection GraphQLMissingType
const typeDefs = gql`
    type Expression @fulltext(indexes: [{ name: "expressions", fields: ["titles", "names"] }]) {
        label: String
        uri: String
        title: String
        titlepreferred: String
        titlevariant: String
        titles: String
        names: String
        manifestations: [Manifestation!]! @relationship(type: "EMBODIES", direction: IN)
        work: [Work!]! @relationship(type: "REALIZES", direction: OUT)
        language: [Concept!]! @relationship(type: "LANGUAGE", direction: OUT)
        content: [Concept!]! @relationship(type: "CONTENT", direction: OUT)
        creators: [Agent!]! @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
        partOf: [Expression!]! @relationship(type: "PARTOF", direction: OUT)
        hasPart: [Expression!]! @relationship(type: "PARTOF", direction: IN)
        relatedTo: [Expression!]! @relationship(type: "RELATED", properties: "roleType", direction: OUT)
        relatedFrom: [Expression!]! @relationship(type: "RELATED", properties: "roleType", direction: IN)
    }
    type Work @fulltext(indexes: [{ name: "works", fields: ["titles", "names"] }]) {
        label: String
        uri: String
        title: String
        titlepreferred: String
        titlevariant: String
        titles: String
        names: String
        type: [Concept!]! @relationship(type: "TYPE", direction: OUT)
        creators: [Agent!]! @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
        hasSubjectWork: [Work!]! @relationship(type: "SUBJECT", direction: OUT)
        isSubjectWork: [Work!]! @relationship(type: "SUBJECT", direction: IN)
        hasSubjectAgent: [Agent!]! @relationship(type: "SUBJECT", direction: OUT)
        partOf: [Work!]! @relationship(type: "PARTOF", direction: OUT)
        hasPart: [Work!]! @relationship(type: "PARTOF", direction: IN)
        relatedTo: [Work!]! @relationship(type: "RELATED", properties: "roleType", direction: OUT)
        relatedFrom: [Work!]! @relationship(type: "RELATED", properties: "roleType", direction: IN)

    }
    type Manifestation {
        label: String
        uri: String
        identifier: String
        title: String
        subtitle: String
        numbering: String
        part: String
        responsibility: String
        edition: String
        extent: String
        dimensions: String
        publication: String
        production: String
        distribution: String
        manufacture: String
        productionplace: String
        producer: String
        productiondate: String
        publicationplace: String
        publisher: String
        publicationdate: String
        distributionplace: String
        distributor: String
        distributiondate: String
        manufactureplace: String
        manufacturer: String
        manufacturedate: String
        copyright: String
        series: String
        seriesnumbering: String
        partnote: String
        carrier: [Concept!]! @relationship(type: "CARRIER", direction: OUT)
        media: [Concept!]! @relationship(type: "MEDIATYPE", direction: OUT)
        creators: [Agent!]! @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
        expressions: [Expression!]! @relationship(type: "EMBODIES", direction: OUT)
    }
    type Concept{
        label: String,
        uri: String
    }
    type Agent {
        label: String
        name: String
        uri: String
    }
    interface roleType @relationshipProperties {
        role: String
    }
`;

const driver = neo4j.driver(
    "bolt://dif04.idi.ntnu.no:7687",
    //"bolt://localhost:11006",
    neo4j.auth.basic("neo4j", "letmein")
);

const neoSchema = new Neo4jGraphQL({ typeDefs, driver });

neoSchema.getSchema().then((schema) => {
    const server = new ApolloServer({
        schema,
    });

    server.listen(8080).then(({ url }) => {
        console.log(`🚀 Server ready at ${url}`);
    });
})