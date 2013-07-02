'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import pickle
import numpy as np
from sklearn import mixture

class Learner(object):
    '''
    Base class for all learners
    Defines a few commonalities between the learner classes.
    '''
    
    minSamples = 20

    def __init__(self,evidenceGenerator):
        '''
        OBJ=LEARNER(EVIDENCEGENERATOR)
        The standard constructor for all learner classes. An evidence
        generator is always necessary and is assigned during construction.
         
        @attention: Unlike the MATLAB code, also initializing the model
        structure here, as a dictionary of learned models (SciKit class).        
        '''
        self.evidenceGenerator = evidenceGenerator
        self.model = dict()
        
class LocationLearner(Learner):
    '''
    Base class for location learning
    Extends the basic Learner.Learner interface. 
    Adds a method: removeParents.
    
    TODO: Is this class necessary in Python code?
    '''
    

class ContinuousGMMLearner(LocationLearner):
    '''
    Models relative location as a mixture of Gaussian
    This method is used to learn a mixture of Gaussians model of the
    distribution of relative locations between object pairs.
    
    Samples are NOT slices as opposed to MATLAB code.
    TODO: consider updating models incrementally, as new data arrives.
    '''
    
    maxComponents = 5
    splitSize = 3
    savefile = 'GMMmodels'
    
    def learn(self, dataStr):
        '''
        Learns the GMM probabilities.
        Loads the model if it exists otherwise runs the learning process.
        '''
        
        try:
            f = open(self.savefile, 'r')
            self.model = pickle.load(f)
        except IOError:
            #Get the relative location samples (dictionary)
            samples = self.evidenceGenerator.getEvidence(dataStr)
            classes = dataStr.getClassNames()
            
            for key,val in samples.iteritems():
                # compute the gmm
                if len(val) is not 0:
                    clf = self.doGMM(val)
                    # save it
                    print "Learned parameters for the class pairs:", key
                    self.model[key] = clf
            
            # pickle the dictionary of GMM models
            f = open(self.savefile, 'w')
            pickle.dump(self.model, f)
        finally:
            f.close()
        
    def doGMM(self, samples):
        '''
        Learns the GMM probabilities for the particular class pair i,j
        with samples containing distance information as a list of 2-d vectors
        
        Learning is done with EM algorithm.
        Number of components is determined with the BIC-score.
        Restricting the number of components to MAXCOMPONENTS.
        
        Returns the learned model as a class.
        TODO: maybe just return the parameters instead?
        
        TODO: use Dirichlet process instead of BIC score.
        '''
        
        # Split the dataset into 3 parts, 
        # use 2 parts for training and 1 for testing        
        randomInd = np.random.permutation(range(len(samples)))
        set_randomInd = set(randomInd.tolist())
        split = np.ceil(len(randomInd)/self.splitSize)
        
        # Generate possible combinations for CROSSVALIDATION
        
        # for array indexing convert samples list into numpy array
        npsamp = np.array(samples)
        # test and train are lists containing corresponding 
        # numpy array data for crossvalidation
        test = list()
        train = list()
        
        # TODO: check to see if working
        for i in range(self.splitSize):
            ind_i = randomInd[(i * split):((i+1) * split)]
            test[i] = npsamp[ind_i]
            # get the difference of indices
            set_ind_i_diff = set_randomInd.difference(set(ind_i.tolist()))
            ind_i_diff = list(set_ind_i_diff)
            train[i] = npsamp[ind_i_diff]
        
        score = np.zeros(self.maxComponents)
        # For every possible number of components calculate the score
        for k in range(self.maxComponents):
            # add the scores for all dataset splits
            for s in range(self.splitSize):
                score[k] = score[k] + self.evaluateModelComplexity(train[s], test[s], k+1)
    
        # find the lowest cost
        kOPT = score.argmin()
        # train model with optimal component size
        clf = mixture.GMM(n_components = kOPT, covariance_type = 'full')
        clf.fit(npsamp)
        
        # return the learned model
        return clf
    
    def getProbabilityFromEvidence(self, evidence, fromClass, toClass):
        '''
        Returns the learned probabilities (PDF) between the two classes.
        TODO: check to see if it works!
        '''
        
        return np.exp(self.model[(fromClass, toClass)].score(evidence))
    
    def evaluateModelComplexity(self, trainSet, testSet, k):
        '''
        Evaluate the Bayesian Information Criterion (BIC) score 
        of the GMM where the BIC is defined as:
        
        BIC = NlogN + m * log(n)
        
        NlogN: negative-log-likelihood of the test data in testSet
        m: estimated number of parameters
        n: number of data points    
        
        Using Scikit-learn to implement GMM.
        '''
        
        clf = mixture.GMM(n_components = k, covariance_type = 'full')
        # train with EM
        clf.fit(trainSet)
        bic = clf.bic(testSet)
        
        return bic