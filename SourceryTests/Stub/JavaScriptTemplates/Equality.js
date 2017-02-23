<% for (type of types.classes) { -%>
extension <%= type.name %>: Equatable {}

<% if (type.annotations.showComment) { _%> // <%= type.name %> has Annotations <%_ } %>

func == (lhs: <%= type.name %>, rhs: <%= type.name %>) -> Bool {
    <% for (variable of type.variables) { -%>
    if lhs.<%= variable.name %> != rhs.<%= variable.name %> { return false }
    <% } -%>
    return true
}
<% } %>
