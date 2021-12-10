const { Neo4jGraphQL } = require("@neo4j/graphql");
const { ApolloServer, gql } = require("apollo-server");
const neo4j = require("neo4j-driver");

const typeDefs = gql`
    type Expression @fulltext(indexes: [{ name: "expressions", fields: ["title"] }]) {
        title: String
        manifestations: [Manifestation] @relationship(type: "EMBODIES", direction: IN)
        work: [Work] @relationship(type: "REALIZES", direction: OUT)
        language: [Concept] @relationship(type: "LANGUAGE", direction: OUT)
        content: [Concept] @relationship(type: "CONTENT", direction: OUT)
        creators: [Agent] @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
    }
    type Work {
        title: String
        type: [Concept] @relationship(type: "TYPE", direction: OUT)
        creators: [Agent] @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
    }
    type Manifestation {
        title: String
        responsibility: String
        extent: String
        dimensions: String
        numbering: String
        publicationdate: String
        publicationplace: String
        publisher: String
        manufacturedate: String
        manufactureplace: String
        manufacturename: String
        carrier: [Concept] @relationship(type: "CARRIER", direction: OUT)
        media: [Concept] @relationship(type: "MEDIA", direction: OUT)
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

server.listen().then(({ url }) => {
    console.log(`🚀 Server ready at ${url}`);
});


