declare namespace marc="http://www.loc.gov/MARC21/slim";
(: Inserting URI relationship types for relator codes, also adds relator codes when only URI is included :)
for $person in doc("../xml/ballard.xml")//marc:datafield[@tag = ('100', '700') and not(marc:subfield/@code='t') ]
return (
    (: author of introduction :)
    (: same URI is used for several codes so we skip checking for reverse :)
    if ($person/marc:subfield[@code='4'] = 'aui' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/m/object/P30328')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/m/object/P30328</marc:subfield> after $person/marc:subfield[@code='4' and . = 'aui']  else insert node () into $person, 

    (: screenwriter :)
    if ($person/marc:subfield[@code='4'] = 'aus' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10203')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10203</marc:subfield> after $person/marc:subfield[@code='4' and . = 'aus']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10203' and not($person/marc:subfield[@code='4'] = 'aus')) 
        then insert node <marc:subfield code="4">aus</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10203']  else insert node () into $person, 

    (: author :)
    if ($person/marc:subfield[@code='4'] = 'aut' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10061')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10061</marc:subfield> after $person/marc:subfield[@code='4' and . = 'aut']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10061' and not($person/marc:subfield[@code='4'] = 'aut')) 
        then insert node <marc:subfield code="4">aut</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10061']  else insert node () into $person, 
        
    (: artist :)
    if ($person/marc:subfield[@code='4'] = 'art' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10058')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10058</marc:subfield> after $person/marc:subfield[@code='4' and . = 'art']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10058' and not($person/marc:subfield[@code='4'] = 'art')) 
        then insert node <marc:subfield code="4">art</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10058']  else insert node () into $person,
        
    (: editor of compilation :)
    if ($person/marc:subfield[@code='4'] = 'edc' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10055')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10055</marc:subfield> after $person/marc:subfield[@code='4' and . = 'edc']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10055' and not($person/marc:subfield[@code='4'] = 'edc')) 
        then insert node <marc:subfield code="4">edc</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10055']  else insert node () into $person,

    (: composer :)
    if ($person/marc:subfield[@code='4'] = 'cmp' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10053')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10053</marc:subfield> after $person/marc:subfield[@code='4' and . = 'cmp']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10053' and not($person/marc:subfield[@code='4'] = 'cmp')) 
        then insert node <marc:subfield code="4">cmp</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10053']  else insert node () into $person,

    (: cinematographer :)
    if ($person/marc:subfield[@code='4'] = 'cng' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10068')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10068</marc:subfield> after $person/marc:subfield[@code='4' and . = 'cng']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10068' and not($person/marc:subfield[@code='4'] = 'cng')) 
        then insert node <marc:subfield code="4">cmp</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10068']  else insert node () into $person,

    (: illustrator :)
    if ($person/marc:subfield[@code='4'] = 'ill' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/m/object/P30321')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/m/object/P30321</marc:subfield> after $person/marc:subfield[@code='4' and . = 'ill']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/m/object/P30321' and not($person/marc:subfield[@code='4'] = 'ill')) 
        then insert node <marc:subfield code="4">ill</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/m/object/P30321']  else insert node () into $person,
   
    (: interviewee :)
    if ($person/marc:subfield[@code='4'] = 'ive' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10059')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10059</marc:subfield> after $person/marc:subfield[@code='4' and . = 'ive']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10059' and not($person/marc:subfield[@code='4'] = 'ive')) 
        then insert node <marc:subfield code="4">ive</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10059']  else insert node () into $person,
        
    (: interviewer :)
    if ($person/marc:subfield[@code='4'] = 'ivr' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10057')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/w/object/P10057</marc:subfield> after $person/marc:subfield[@code='4' and . = 'ivr']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/w/object/P10057' and not($person/marc:subfield[@code='4'] = 'ivr')) 
        then insert node <marc:subfield code="4">ivr</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/w/object/P10057']  else insert node () into $person,

    (: musical director :)
    if ($person/marc:subfield[@code='4'] = 'msd' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/e/object/P20035')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/e/object/P20035</marc:subfield> after $person/marc:subfield[@code='4' and . = 'msd']  else insert node () into $person, 
    if ($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/e/object/P20035' and not($person/marc:subfield[@code='4'] = 'msd')) 
        then insert node <marc:subfield code="4">msd</marc:subfield> before $person/marc:subfield[@code='4' and . = 'http://rdaregistry.info/Elements/e/object/P20035']  else insert node () into $person,

    (: writer of introduction :)
    (: same URI is used for several codes so we skip checking for reverse :)
    if ($person/marc:subfield[@code='4'] = 'win' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/m/object/P30328')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/m/object/P30328</marc:subfield> after $person/marc:subfield[@code='4' and . = 'win']  else insert node () into $person, 
        
    (: writer of preface :)
    (: same URI is used for several codes so we skip checking for reverse :)
    if ($person/marc:subfield[@code='4'] = 'wrp' and not($person/marc:subfield[@code='4'] = 'http://rdaregistry.info/Elements/m/object/P30328')) 
        then insert node <marc:subfield code="4">http://rdaregistry.info/Elements/m/object/P30328</marc:subfield> after $person/marc:subfield[@code='4' and . = 'wrp']  else insert node () into $person

   )
    (: translator :)
    
    (: illustrator :)
    
    (: composer :)

