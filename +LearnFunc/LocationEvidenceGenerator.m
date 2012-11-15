classdef LocationEvidenceGenerator<LearnFunc.EvidenceGenerator
    %LOCATIONEVIDENCEGENERATOR Produces location Evidence
    %   This class is an abstract class that produces evidence of relative
    %   and absolute locations of objects.
    
    methods
        function evidence=getEvidence(obj,data)
            %EVIDENCE=GETEVIDENCE(OBJ,DATA)
            %   Produces relative location evidence.
            %
            %DATA is a DataHandlers.DataStructure class instance that
            %   contains the location data.
            %
            %EVIDENCE is a cxc cell matrix where EVIDENCE{i,j} contains the
            %   samples from class i to class j. The format of the samples
            %   depends on the implementation of GETRELATIVEEVIDENCE in the
            %   dervied class.
            
            classes=data.getClassNames();
            evidence=cell(length(classes),length(classes));
            for i=1:length(data)
                pos=obj.getPositionEvidence(data,i);
                relEvidence=obj.getRelativeEvidence(pos,pos);
                
                ind=data.className2Index({data.getObject(i).name});
                for o=1:length(ind)
                    for t=o+1:length(ind)
                        evidence{ind(o),ind(t)}(end+1,:)=relEvidence(o,t,:);
                        evidence{ind(t),ind(o)}(end+1,:)=relEvidence(t,o,:);
                    end
                end
            end
        end
        
        function evidence=getEvidenceForImage(obj,data,index)
            %EVIDENCE=GETEVIDENCEFORIMAGE(OBJ,DATA,INDEX)
            %   Produces relative location evidence for all pixels in a
            %   single scene.
            %
            %DATA is a DataHandlers.DataStructure class instance that
            %   contains the location data.
            %
            %INDEX is the index of the desired scene.
            %
            %EVIDENCE is a struct with three fields:
            %   'names': the class names of the observed objects
            %   'absEvi': the 3D-location of every pixel
            %   'relEvi': the relative location from every observed object
            %       to every pixel
            allNames={data.getObject(index).name};
            baseIndices=ismember(allNames,data.getLargeClassNames());
            evidence.names=allNames(baseIndices);
            
            objectPos=obj.getPositionEvidence(data,index);
            objectPos=objectPos(:,baseIndices);
            
            evidence.absEvi=obj.getPositionForImage(data,index);
            
            evidence.relEvi=obj.getRelativeEvidence(objectPos,evidence.absEvi);
        end
    end
    
    methods(Abstract,Static,Access='protected')
        %EVIDENCE=GETRELATIVEEVIDENCE(SOURCEPOS,TARGETPOS)
        %   Computes the relative location evidence from SOURCEPOS to
        %   TARGETPOS.
        %
        %SOURCEPOS is a 3xn matrix where every column is a 3D-location.
        %
        %TARGETPOS is a 3xm matrix where every column is a 3D-location.
        %
        %EVIDENCE is a nxmxd matrix where d is the dimensionality of the
        %   evidence. It contains the relative location from every
        %   SOURCEPOS to every TARGETPOS. The dimensionality and exact
        %   computation of the output is defined by the deriving class.
        evidence=getRelativeEvidence(sourcePos,targetPos)
        pos=getPositionEvidence(images,index)
        pos=getPositionForImage(images,index)
    end
end

