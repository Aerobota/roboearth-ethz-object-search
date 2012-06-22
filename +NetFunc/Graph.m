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
        
        function viewGraph(obj,handle)
            if(~obj.compiled)
                obj.compile();
                obj.compiled=true;
            end
            if nargin<2
                obj.viewGraphImpl();
            else
                obj.viewGraphImpl(handle);
            end
        end
        
        function setCompileState(obj,targetState)
            if(obj.compiled ~= targetState)
                if(~obj.compiled)
                    obj.compile();
                end
                obj.compiled=targetState;
            end
        end
    end
    methods(Abstract,Access='protected')
        addNodeImpl(obj,node);
        compile(obj);
        viewGraphImpl(obj,handle);
    end
end

