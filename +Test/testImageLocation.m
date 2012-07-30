%% Init

if exist('ll','var')~=1 || ~isa(ll,'LearnFunc.Learner')
    error('Need to run Test.testDistance first')
end

%% Run evaluator

evalFROC=Evaluation.FROCLocationEvaluator(false);
evalFirstN=Evaluation.FirstNLocationEvaluator(false);
tic
resultFROC=evalFROC.evaluate(ll);
timeFROC=toc;
tic
resultFirstN=evalFirstN.evaluate(ll);
timeFirstN=toc;