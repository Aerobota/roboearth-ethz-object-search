classdef DataStructure<handle
    %DATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        addImage(obj,filename,folder)
        load(obj,path)
        save(obj,path)
    end
    
end

