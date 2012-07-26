%% Init

if exist('ll','var')~=1 || ~isa(ll,'LearnFunc.Learner')
    error('Need to run Test.testDistance first')
end

%% Run evaluator

evalFROC=Evaluation.FROCLocationEvaluator(false);
evalFirstN=Evaluation.FirstNLocationEvaluator(false);
resultFROC=evalFROC.evaluate(ll);
resultFirstN=evalFirstN.evaluate(ll);