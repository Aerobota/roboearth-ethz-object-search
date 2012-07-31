function smallClasses = extractSmallClasses(allClasses)
    smallList={...
        'bag',...
        'basket',...
        'book',...
        'bottle',...
        'bowl',...
        'box',...
        'clock',...
        'clothes',...
        'cup',...
        'cushion',...
        'electricalOutlet',...
        'faucet',...
        'floorMat',...
        'flowers',...
        'glass',...
        'lamp',...
        'paper',...
        'picture',...
        'plate',...
        'pot',...
        'tissueBox',...
        'towel',...
        'tray',...
        'vase'};
        
    smallClasses=allClasses(ismember(allClasses,smallList));
end
