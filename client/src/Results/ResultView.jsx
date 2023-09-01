import React from "react";
import {selectedVar} from "../api/Cache";
import Expression from "./Expression";

export default function ResultView(props) {

    return (
         <div className={"expressionList"}>
                {selectedVar().size === 0 ?
                    props.results ? props.results.map(x => (<Expression expression={x.expression} key={x.expression.uri} checkboxes={props.checkboxes}/>)) : [] :
                    props.results ? props.results.filter(exp => exp.checked).map(x => (<Expression expression={x.expression} key={x.expression.uri} checkboxes={props.checkboxes}/>)) : []
                }
         </div>
    );
}