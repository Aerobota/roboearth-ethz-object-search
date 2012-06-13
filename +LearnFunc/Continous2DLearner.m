classdef Continous2DLearner<LearnFunc.LocationLearner
    properties(Constant)
        minSamples=10;
    end
    properties(SetAccess='protected')
        data;
    end
    
    methods
        function obj=Continous2DLearner(classes,heights)
            obj=obj@LearnFunc.LocationLearner(classes);
            for c=1:length(obj.classes)
                obj.data.(obj.classes{c}).height=heights(c);
                for o=1:length(obj.classes)
                    obj.data.(obj.classes{c}).(obj.classes{o}).mean=[];
                    obj.data.(obj.classes{c}).(obj.classes{o}).cov=[];
                end
            end
        end
        
        function learnLocations(obj,images)
            dist=cell(length(obj.classes),length(obj.classes));
            for i=1:length(dist)
                dist{i}=zeros(2*length(images),2);
            end
            cInd=ones(size(dist));
            for i=1:length(images)
                nObj=length(images(i).annotation.object);
                pos=zeros(2,nObj);
                for o=1:nObj
%                     pos(:,o)=polygonCenterOfMass(...
%                         images(i).annotation.object(o).polygon.x/images(i).annotation.imagesize.ncols,...
%                         images(i).annotation.object(o).polygon.y/images(i).annotation.imagesize.nrows);
                    pos(:,o)=[mean(images(i).annotation.object(o).polygon.x/images(i).annotation.imagesize.ncols);...
                        mean(images(i).annotation.object(o).polygon.y/images(i).annotation.imagesize.nrows)];
                end
                
                dx=abs(pos(ones(nObj,1),:)-pos(ones(nObj,1),:)');
                dy=pos(2*ones(nObj,1),:)-pos(2*ones(nObj,1),:)';
                
                for o=1:nObj
                    for t=o+1:nObj
                        index=find(ismember(obj.classes,{images(i).annotation.object(o).name,images(i).annotation.object(t).name}),2);
                        ind1=min(index);
                        ind2=max(index);
                        dist{ind1,ind2}(cInd(ind1,ind2),:)=[dx(o,t) dy(o,t)];
                        cInd(ind1,ind2)=cInd(ind1,ind2)+1;
                    end
                end
            end
            
            for i=1:length(obj.classes)
                for j=i:length(obj.classes)
                    if size(dist{i,j},1)>=obj.minSamples;
                        tmpMean=mean(dist{i,j});
                        tmpCov=cov(dist{i,j});
                        obj.data.(obj.classes{j}).(obj.classes{i}).mean=[tmpMean(1) -tmpMean(2)];
                        obj.data.(obj.classes{j}).(obj.classes{i}).cov=tmpCov;
                        obj.data.(obj.classes{i}).(obj.classes{j}).mean=tmpMean;
                        obj.data.(obj.classes{i}).(obj.classes{j}).cov=tmpCov;
                    end
                end
            end
        end
        function CPD=getConnectionNodeCPD(obj,fromClass,toClass)
        end
        function evidence=adaptEvidence(obj,fromClass,toClass,evidence)
        end
    end
end

% function center=polygonCenterOfMass(x,y)
%     xShift=mean(x);
%     yShift=mean(y);
%     xScale=1;%sqrt(mean((x-mean(x)).^2));
%     yScale=1;%sqrt(mean((y-mean(y)).^2));
%     
%     nP=length(x)-1;
%     xn=(x(1:nP)-xShift)/xScale;
%     yn=(y(1:nP)-yShift)/yScale;
%     xs=(x(2:nP+1)-xShift)/xScale;
%     ys=(y(2:nP+1)-yShift)/yScale;
%     crossxy=xn.*ys-xs.*yn;
%     area=sum(crossxy)/2;
%     
%     center(2,1)=sum((yn+ys).*crossxy)/6/area*yScale+yShift;
%     center(1,1)=sum((xn+xs).*crossxy)/6/area*xScale+xShift;
%     
%     assert(~any(x>1.01 | x<-0.01 | y>1.01 | y<-0.01),'coordinates out of bounds %d,%d',...
%         x(x>1.01 | x<-0.01 | y>1.01 | y<-0.01),y(x>1.01 | x<-0.01 | y>1.01 | y<-0.01))
%     if ~(center(1)<max(x) && center(1)>min(x) && center(2)<max(y) && center(2)>min(y))
%         disp(area)
%         plot(x,y,'-b',center(1),center(2),'*r')
%         drawnow
%         disp([x y [xn yn xs ys;0 0 0 0]])
%         disp([xShift yShift xScale yScale])
%         global errorPoly;
%         errorPoly=[x y];
%         assert(center(1)<max(x) && center(1)>min(x) && center(2)<max(y) && center(2)>min(y),...
%             'center outside bounding box %d<%d<%d,%d<%d<%d ',min(x),center(1),max(x),min(y),center(2),max(y))
%     end
% end