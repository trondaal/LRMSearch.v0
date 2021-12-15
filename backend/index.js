const { Neo4jGraphQL } = require("@neo4j/graphql");
const { ApolloServer, gql } = require("apollo-server");
const neo4j = require("neo4j-driver");

const typeDefs = gql`
    type Expression @fulltext(indexes: [{ name: "expressions", fields: ["title"] }]) {
        uri: String
        title: String
        manifestations: [Manifestation] @relationship(type: "EMBODIES", direction: IN)
        work: [Work] @relationship(type: "REALIZES", direction: OUT)
        language: [Concept] @relationship(type: "LANGUAGE", direction: OUT)
        content: [Concept] @relationship(type: "CONTENT", direction: OUT)
        creators: [Agent] @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
    }
    type Work {
        uri: String
        title: String
        type: [Concept] @relationship(type: "TYPE", direction: OUT)
        creators: [Agent] @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
    }
    type Manifestation {
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
        carrier: [Concept] @relationship(type: "CARRIER", direction: OUT)
        media: [Concept] @relationship(type: "MEDIA", direction: OUT)
        creators: [Agent] @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
    }
    type Concept{
        label: String,
        uri: String
    }
    type Agent {
        name: String
    }
    interface roleType @relationshipProperties {
        role: String
    }
`;

const driver = neo4j.driver(
    "bolt://dif04.idi.ntnu.no:7687",
    neo4j.auth.basic("neo4j", "letmein")
);

const neoSchema = new Neo4jGraphQL({ typeDefs, driver });

const server = new ApolloServer({
    schema: neoSchema.schema,
});

server.listen(8080).then(({ url }) => {
    console.log(`🚀 Server ready at ${url}`);
});


