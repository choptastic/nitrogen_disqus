-module (element_disqus).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-include("records.hrl").

reflect() -> record_info(fields, disqus).

var(_,undefined) ->
	[];
var(_,[]) ->
	[];
var(Field,Val) when is_boolean(Val) ->
	var_final(Field,atom_to_list(Val));
var(Field,Val) when is_integer(Val) ->
	var_final(Field,integer_to_list(Val));
var(Field,Val) when is_list(Val) ->
	var_final(Field,["\"",wf:js_escape(Val),"\""]).

var_final(Field,Val) ->
	["var disqus_",wf:to_list(Field)," = ",Val,";"].

loaded_counter() ->
	wf:state_default(loaded_counter,false).

load_counter() ->
	wf:state(loaded_counter,true).

render_element(D = #disqus{countonly=false}) ->
	["<div id=\"disqus_thread\" class=\"disqus_thread\"></div>
	<script type=\"text/javascript\">
	    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */",
			var(developer,D#disqus.developer),
			var(identifier,D#disqus.identifier),
			var(url,D#disqus.url),
			var(title,D#disqus.title),
			var(shortname,D#disqus.shortname),
		    "/* * * DON'T EDIT BELOW THIS LINE * * */
			    (function() {
						        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
		        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
		        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href=\"http://disqus.com/?ref_noscript\">comments powered by Disqus.</a></noscript>
<a href=\"http://disqus.com\" class=\"dsq-brlink\">comments powered by <span class=\"logo-disqus\">Disqus</span></a>"];
%% TODO: MAke this more kosher.  Must add "data" attribute to base record
render_element(D = #disqus{countonly=true}) ->
	Element = ["<a href=\"",wf:html_encode(D#disqus.url),"#disqus_thread\" class=\"disqus_counter\" data-disqus-identifier=\"",wf:html_encode(D#disqus.identifier),"\">",wf:html_encode(D#disqus.comment_text),"</a>
		<script type=\"text/javascript\">",var(shortname,D#disqus.shortname),"</script>"],


	case loaded_counter() of
		true -> do_nothing;
		false -> 
			load_counter(),
			Script =  "(function () {
					var s = document.createElement('script'); s.async = true;
					s.type = 'text/javascript';
					s.src = 'http://" ++ D#disqus.shortname ++ ".disqus.com/count.js';
					(document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
					}());",
			wf:wire(Script)
	end,
	Element.




