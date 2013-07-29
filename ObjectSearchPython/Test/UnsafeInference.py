'''
Created on July 29, 2013

This scenario investigates the use of inference in learned models.
@author: okankoc

TODO:
1. Build a dictionary relating classes to definitions in knowrob.url
2. Receive a semantic map from Knowrob and parse it.
3. Learn the location of undefined class from a few samples [generally just the mean].
4. Receive a second semantic map.
5. Infer the location of previously undefined small object using few samples.
6. Send it back. 

'''

#!/usr/bin/env python