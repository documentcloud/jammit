(function(){
window.JST = window.JST || {};
var template = function(str){var fn = new Function('obj', 'var p=[],print=function(){p.push.apply(p,arguments);};with(obj){p.push(\''+str.replace(/[\r\t\n]/g, " ").replace(/'(?=[^%]*%>)/g,"\t").split("'").join("\\'").split("\t").join("'").replace(/<%=(.+?)%>/g,"',$1,'").split("<%").join("');").split("%>").join("p.push('")+"');}return p.join('');"); return fn;};
window.JST['template1'] = template('<a href="<%= to_somewhere %>"><%= saying_something %></a>');
window.JST['template2'] = template('<% _([1,2,3]).each(function(num) { %>\n  <li class="number">\n    <%= num %>\n  </li>\n<% }) %>');
})();