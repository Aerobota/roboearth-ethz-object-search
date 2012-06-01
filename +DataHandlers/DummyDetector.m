classdef DummyDetector<DataHandlers.ObjectDetector
    properties(Constant)
        maxScore=10;
        maxSize=200;
        minPolySide=10;
    end
    properties(SetAccess='private')
        sizeAverage;
    end
    methods
        function obj=DummyDetector(dummyClasses)
            if nargin<1
                nrClasses=floor(randi(6))+4;
                dummyClasses=cell(nrClasses,1);
                for i=1:nrClasses
                    dummyClasses{i}=['Dummy' num2str(i,'%03d')];
                end
            end
            obj.classes=dummyClasses;
            obj.sizeAverage=(obj.maxSize-obj.minPolySide)*rand(2,length(dummyClasses))+obj.minPolySide;
        end
        function detections=detectClass(obj,className,image)
            nrDetections=poissrnd(2);
            if nrDetections>0
                cIndex=find(ismember(obj.classes,className),1);
                assert(~isempty(cIndex),'Requested class is unknown to detector');
                detections(nrDetections,1).class=className;
                for i=1:nrDetections
                    detections(i).class=className;
                    detections(i).score=obj.maxScore*(1-rand()^0.25);
                    detections(i).polygon=obj.samplePolygon(cIndex,size(image));
                end
            else
                detections=[];
            end
        end
     end
    methods(Access='private')
        function polygon=samplePolygon(obj,index,imgSize)
            goodSample=false;
            while(~goodSample)
                tmpSize=abs(obj.sizeAverage(:,index).*(0.25*randn(2,1)+1))/2;
                tmpPos=max(imgSize/2)*(randn(2,1)+1);
                points=[tmpPos+tmpSize [tmpPos(1)+tmpSize(1);tmpPos(2)-tmpSize(2)] tmpPos-tmpSize...
                    [tmpPos(1)-tmpSize(1);tmpPos(2)+tmpSize(2)]];
                points=max(points,1);
                points(1,:)=min(points(1,:),imgSize(1));
                points(2,:)=min(points(2,:),imgSize(2));
                if(points(1,1)-points(1,3)>obj.minPolySide &&points(2,1)-points(2,3)>obj.minPolySide)
                    goodSample=true;
                end
            end
            polygon.pt(4).x=0;
            for i=1:4
                polygon.pt(i).x=points(1,i);
                polygon.pt(i).y=points(2,i);
            end
        end
    end
end