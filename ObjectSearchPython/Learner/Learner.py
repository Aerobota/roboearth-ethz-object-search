'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import sys
import pickle
import numpy as np
from sklearn import mixture

class Learner(object):
    '''
    Base class for all learners
    Defines a few commonalities between the learner classes.
    '''
    

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
    

class ContinuousGMMLearner(Learner):
    '''
    Models relative location as a mixture of Gaussian
    This method is used to learn a mixture of Gaussians model of the
    distribution of relative locations between object pairs.
    
    Samples are NOT slices as opposed to MATLAB code.
    TODO: consider updating models incrementally, as new data arrives.
    '''
    
    maxComponents = 5
    splitSize = 3
    minSample = np.ceil(maxComponents * splitSize / (splitSize - 1))
    savefile = 'GMMmodels'
    
    def load(self):
        '''
        Loads the GMM models.
        '''
        try:
            f = open(self.savefile, 'r')
            print 'Loading GMM Models...'
            self.model = pickle.load(f)
        except IOError:
            print 'GMM Models have not been learned.'
            print 'Please run Location.py script to learn location models.'
            raise
    
    def learn(self, dataStr):
        '''
        Learns the GMM probabilities.
        Loads the model if it exists otherwise runs the learning process.
        '''
        
        try:
            f = open(self.savefile, 'r')
            print 'GMM Models have already been learned.'
            print 'You can find a brief summary in the gmm text file'
            stdout = sys.stdout  #keep a handle on the real standard output
            sys.stdout = open('gmm.txt', 'w')
            self.model = pickle.load(f)
            print 'Brief summary of the GMM Models:'
            for key,mixture in self.model.iteritems():
                print 'Learned parameters for the class pair:', key
                print 'Number of components:', mixture.CLF.n_components
                print 'Number of samples:', mixture.numSamples 
                print 'Weights:'
                print mixture.CLF.weights_
                print 'Means:'
                print mixture.CLF.means_
                print 'Covariances:'
                print mixture.CLF.covars_
            #restore std output
            sys.stdout = stdout
            
        except IOError:
            print 'Learning GMM Models ...'
            
            #Get the relative location samples (dictionary)
            samples = self.evidenceGenerator.getEvidence(dataStr)
            classes = dataStr.getClassNames()
            
            for key,val in samples.iteritems():
                # compute the gmm 
                # if key does not include unknowns 
                if not 'unknown' in key and len(val) is not 0:
                    clf = self.doGMM(val)
                    mixture = Mixture(clf, len(val))
                    # save it
                    print "Learned parameters for the class pair:", key
                    self.model[key] = mixture
            
            # pickle the dictionary of GMM models
            f = open(self.savefile, 'w')
            pickle.dump(self.model, f)
            f.close()
            
    def learnFromOneSample(self, semMap, smallObject):
        '''
        This is a method which implements the scenario where the locations
        of an unknown small object and a known large object pair are 
        received and the task is to store their mean distance along with the
        previously learned models.
         
        '''
                
        # get names for the large objects
        objs = semMap.objects
        for c in objs:
            largeName = c.type
            # for each large object learn one sample-model
            key = (largeName, smallObject.type)
            if key not in self.model:
                # learn from one sample and add it to model dictionary
                    val = []
                    dist = smallObject.loc - c.loc
                    cylDistance = [np.sqrt(dist[1]**2 + dist[2]**2), dist[0]]
                    val.append(cylDistance)
                    clf = self.doGMM(val)
                    mixture = Mixture(clf, 1)
                    # save it
                    print "Learned mean from one example for pair:", key
                    self.model[key] = mixture
            
            # pickle the dictionary of GMM models
            f = open(self.savefile, 'w')
            pickle.dump(self.model, f)
            f.close()
        
    def doGMM(self, samples):
        '''
        Learns the GMM probabilities for the particular class pair i,j
        with samples containing distance information as a list of 2-d vectors
        
        Learning is done with EM algorithm.
        Number of components is determined with the BIC-score.
        Restricting the number of components to MAXCOMPONENTS.
        
        Returns the learned model as a class.
        
        INPUT: Samples is an Nx2 numpy array containing evidence
        between a particular object pair.
        
        OUTPUT: CLF is a learned GMM model using the ML scikit-learn toolkit.
        
        TODO: use Dirichlet process instead of BIC score.
        '''
        
        if len(samples) > self.minSample:
            # Split the dataset into 3 parts, 
            # use 2 parts for training and 1 for testing        
            randomInd = np.random.permutation(range(samples.shape[0]))
            split = np.floor(len(samples)/self.splitSize)
                    
            # Generate possible combinations for CROSSVALIDATION
            
            # test and train are lists containing corresponding 
            # numpy array data for crossvalidation
            test = list()
            train = list()
            for i in range(self.splitSize):
                ind_i = randomInd[(i * split):((i+1) * split)]
                test.append(samples[ind_i,:])
                # get the difference of indices
                ind_i_diff = np.hstack((randomInd[0:(i * split)],randomInd[((i+1) * split):]))             
                train.append(samples[ind_i_diff,:])
            
            score = np.zeros(self.maxComponents)
            # For every possible number of components calculate the score
            for k in range(self.maxComponents):
                # add the scores for all dataset splits
                for s in range(self.splitSize):
                    score[k] = score[k] + self.evaluateModelComplexity(train[s], test[s], k+1)
        
            # find the lowest cost
            kOPT = score.argmin() + 1
            # train model with optimal component size
            clf = mixture.GMM(n_components = kOPT, covariance_type = 'full')
            clf.fit(samples)
        else:
            kOPT = np.min([len(samples), self.maxComponents]) 
            # initialize model without doing EM
            clf = mixture.GMM(n_components = kOPT, n_iter = 0, init_params = 'wm')
            # skipping (diagonal) covariance initialization
            shape =  (kOPT, 2)
            clf._set_covars(self.infs(shape))
            clf.fit(samples)
        
        # return the learned model
        return clf
    
    def getProbabilityFromEvidence(self, evidence, fromClass, toClass):
        '''
        Returns the learned probabilities (PDF) between the two classes.
        '''
        
        return np.exp(self.model[(fromClass, toClass)].CLF.score(evidence))
    
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
    
    def infs(self, shape, dtype=float):
        '''
        Utility method that returns an array of inf values.
        TODO: Put this in a utility package.
        '''
        
        mat = np.empty(shape, dtype)
        mat.fill(np.inf)
        return mat
    
class Mixture(object):
    '''
    Wrapper for the CLF learned GMM model using the ML scikit-learn toolkit.
    Adds number of samples as a field, which is useful to indicate unsafe inferences.
    '''

    numSamples = 0
    
    def __init__(self, clf, val):
        '''
        Initializes the wrapper class for the GMM models.
        The second argument is the sample size which is added as a field.
        '''        
        
        self.CLF = clf
        self.numSamples = val