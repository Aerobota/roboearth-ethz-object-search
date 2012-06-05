classdef Graph<handle
    %GRAPH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        compiled;
    end
    
    methods(Sealed)
        function obj=Graph()
            obj.compiled=false;
        end
        function addNode(obj,node)
            if(obj.compiled)
                obj.compiled=false;
            end
            obj.addNodeImpl(node);
        end
        function marginals=calculateMarginals(obj,queryNodes)
            if(~obj.compiled)
                obj.compile();
                obj.compiled=true;
            end
            marginals=obj.calculateMarginalsImpl(obj,queryNodes);
        end
        function viewGraph(obj,handle)
            if(~obj.compiled)
                obj.compile();
                obj.compiled=true;
            end
            if nargin<2
                obj.viewGraphImpl(node);
            else
                obj.viewGraphImpl(node,handle);
            end
        end
    end
    methods(Abstract,Access='protected')
        addNodeImpl(obj,node);
        compile(obj);
        viewGraphImpl(obj,handle);
        marginals=calculateMarginalsImpl(obj,queryNodes);
    end
end

