(function(){
custom_namespace = custom_namespace || {};
var template = function(str){var fn = new Function('obj', 'var __p=[],print=function(){__p.push.apply(__p,arguments);};with(obj||{}){__p.push(\''+str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/<%=([\s\S]+?)%>/g,function(match,code){return "',"+code.replace(/\\'/g, "'")+",'";}).replace(/<%([\s\S]+?)%>/g,function(match,code){return "');"+code.replace(/\\'/g, "'").replace(/[\r\n\t]/g,' ')+"__p.push('";}).replace(/\r/g,'\\r').replace(/\n/g,'\\n').replace(/\t/g,'\\t')+"');}return __p.join('');");return fn;};
custom_namespace['template1'] = template('<a href="<%= to_somewhere %>"><%= saying_something %></a>');
custom_namespace['template2'] = template('<% _([1,2,3]).each(function(num) { %>\n  <li class="number">\n    <%= num %>\n  </li>\n<% }) %>');
})();