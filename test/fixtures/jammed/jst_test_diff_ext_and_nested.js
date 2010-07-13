(function(){
window.JST = window.JST || {};
var template = function(str){var fn = new Function('obj', 'var p=[],print=function(){p.push.apply(p,arguments);};with(obj){p.push(\''+str.replace(/[\r\t\n]/g, " ").replace(/'(?=[^%]*%>)/g,"\t").split("'").join("\\'").split("\t").join("'").replace(/<%=(.+?)%>/g,"',$1,'").split("<%").join("');").split("%>").join("p.push('")+"');}return p.join('');"); return fn;};
window.JST['nested/double_nested/double_nested'] = template('<h1>Hello again, {{name}}!</h1>');
window.JST['nested/nested3'] = template('<h1>Goodbye, {{name}}</h1>');
window.JST['template3'] = template('<h1>Hello, {{name}}</h1>');
})();