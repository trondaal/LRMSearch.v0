const { Neo4jGraphQL } = require("@neo4j/graphql");
const { ApolloServer, gql } = require("apollo-server");
const neo4j = require("neo4j-driver");

const typeDefs = gql`
    type Stats{
        source: String
        target: String
        key: String
        value: String
        uri: String
        count: Int
    }
    type Query {
        getStats(searchString: String): [Stats] @cypher(statement: """
        CALL db.index.fulltext.queryNodes('expressions', $searchString) yield node as expression
        CALL{
        WITH expression
        match (expression)-[r:REALIZES]->(w:Work)-[c:CREATOR]-(p:Agent)
        return 'work' as source, 'person' as target, c.role as key, p.name as value, p.uri as uri
        UNION
        WITH expression
        match (expression)-[c:CREATOR]->(p:Agent)
        return 'expression' as source, 'person' as target, c.role as key, p.name as value, p.uri as uri
        UNION
        WITH expression
        match (expression)<-[r:EMBODIES]->(m:Manifestation)-[c:CREATOR]-(p:Agent)
        return 'manifestation' as source, 'person' as target, c.role as key, p.name as value, p.uri as uri
        UNION
        WITH expression
        MATCH (expression)-[r:REALIZES]->(w:Work)-[t:TYPE]->(c:Concept)
        return 'expression' as source, 'concept' as target, 'type' as key, c.label as value, c.uri as uri
        UNION
        WITH expression
        MATCH (expression)-[r:CONTENT]->(c:Concept)
        return 'expression' as source, 'concept' as target, 'content' as key, c.label as value, c.uri as uri
        UNION
        WITH expression
        MATCH (expression)-[r:LANGUAGE]->(c:Concept)
        return 'expression' as source, 'concept' as target, 'language' as key, c.label as value, c.uri as uri
        UNION
        WITH expression
        MATCH (expression)<-[r:EMBODIES]->(m:Manifestation)-[rm:MEDIATYPE]->(c:Concept)
        return 'expression' as source, 'concept' as target, 'media' as key, c.label as value, c.uri as uri
        UNION
        WITH expression
        MATCH (expression)<-[r:EMBODIES]->(m:Manifestation)-[rc:CARRIER]->(c:Concept)
        return 'expression' as source, 'concept' as target, 'carrier' as key, c.label as value, c.uri as uri
        }
        return {source: source, target: target, key: key, value: value, uri: uri, count: count(*)} as stat
        order by stat.source, stat.target, stat.key, stat.count descending
        """)
    }
    type Expression @fulltext(indexes: [{ name: "expressions", fields: ["title"] }]) {
        uri: String
        title: String
        titlepreferred: String
        titlevariant: String
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
        media: [Concept] @relationship(type: "MEDIATYPE", direction: OUT)
        creators: [Agent] @relationship(type: "CREATOR", properties: "roleType", direction: OUT)
    }
    type Concept{
        label: String,
        uri: String
    }
    type Agent {
        name: String
        uri: String
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


/*
       CALL db.index.fulltext.queryNodes('expressions', $searchString)
        yield node as expression
        match (expression)-[c:CREATOR]->(p:Agent)
        WITH 'expression' as source, 'person' as target, c.role as key, p.uri as uri, p.name as value, count(*) as co
        order by key ascending, co descending
        return {source: source, target: target, key: key, value: value, uri: uri, count: co} as stat
        UNION ALL
        match (expression)-[r:REALIZES]->(w:Work)-[c:CREATOR]-(p:Agent)
        WITH 'work' as source, 'person' as target, c.role as key, p.uri as uri, p.name as value, count(*) as co
        return {source: source, target: target, key: key, value: value, uri: uri, count: co} as stat
        UNION ALL
        match (expression)<-[r:EMBODIES]->(m:Manifestation)-[c:CREATOR]-(p:Agent)
        WITH 'manifestation' as source, 'person' as target, c.role as key, p.uri as uri, p.name as value, count(*) as co
        return {source: source, target: target, key: key, value: value, uri: uri, count: co} as stat
        UNION ALL
        MATCH (expression)-[l:LANGUAGE]->(c:Concept)
        WITH 'expression' as source, 'concept' as target, 'language' as key, c.uri as uri, c.label as value, count(*) as co
        order by key ascending, co descending
        return {source: source, target: target, key: key, value: value, uri: uri, count: co} as stat
        UNION ALL
        MATCH (expression)-[r:CONTENT]->(c:Concept)
        WITH 'expression' as source, 'concept' as target, 'content' as key, c.uri as uri, c.label as value, count(*) as co
        order by key ascending, co descending
        return {source: source, target: target, key: key, value: value, uri: uri, count: co} as stat
 */