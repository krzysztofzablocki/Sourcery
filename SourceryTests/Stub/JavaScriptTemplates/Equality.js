<% for (type of types.classes) { -%>
    <%_ %><%# this is a comment -%>
extension <%= type.name %>: Equatable {}

<%_ if (type.annotations.showComment) { -%>
<% _%> // <%= type.name %> has Annotations

<% } -%>
func == (lhs: <%= type.name %>, rhs: <%= type.name %>) -> Bool {
<%_ for (variable of type.variables) { -%>
    if lhs.<%= variable.name %> != rhs.<%= variable.name %> { return false }
<%_ } %>
    return true
}

<% } -%>
