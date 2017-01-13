{% for type in types.based.AutoMockable %}{% if type.kind == 'protocol' %}
{% if not type.name == "AutoMockable" %}
class {{ type.name }}Mock: {{ type.name }} {

    {% for variable in type.allVariables %}
    var {{ variable.name }}: {{ variable.typeName }}
    {% endfor %}

    {% for method in type.allMethods %}
    //MARK: - {{ method.shortName }}

    {% if not method.shortName == "init" %}var {{ method.shortName }}Called = false{% endif %}
    {%if method.parameters.count == 1 %}var {{ method.shortName }}Recieved{% for param in method.parameters %}{{ param.name|upperFirst }}: {{ param.typeName.unwrappedTypeName }}?{% endfor %}{% else %}{% if not method.parameters.count == 0 %}var {{ method.shortName }}RecievedArguments: ({% for param in method.parameters %}{{ param.name }}: {% if param.typeAttributes.escaping %}{{ param.unwrappedTypeName }}{% else %}{{ param.typeName }}{% endif %}{% if not forloop.last %}, {% endif %}{% endfor %})?{% endif %}{% endif %}
    {% if not method.returnTypeName.isVoid and not method.shortName == "init" %}var {{ method.shortName }}ReturnValue: {{ method.returnTypeName }}!{% endif %}

    func {{ method.shortName }}({% for param in method.parameters %}{{ param.argumentLabel }}{% if not param.argumentLabel == param.name %} {{ param.name }}{% endif %}: {{ param.typeName }}{% if not forloop.last %}, {% endif %}{% endfor %}){% if not method.returnTypeName.isVoid %} -> {{ method.returnTypeName }}{% endif %} {

        {% if not method.shortName == "init" %}{{ method.shortName }}Called = true{% endif %}
        {%if method.parameters.count == 1 %}{{ method.shortName }}Recieved{% for param in method.parameters %}{{ param.name|upperFirst }} = {{ param.name }}{% endfor %}{% else %}{% if not method.parameters.count == 0 %}{{ method.shortName }}RecievedArguments = ({% for param in method.parameters %}{{ param.name }}: {{ param.name }}{% if not forloop.last%}, {% endif %}{% endfor %}){% endif %}{% if not method.returnTypeName.isVoid %}{% endif %}
        {% if not method.returnTypeName.isVoid and not method.shortName == "init" %}return {{ method.shortName }}ReturnValue{% endif %}{% endif %}
    }

{% endfor %}
}
{% endif %}{% endif %}
{% endfor %}
