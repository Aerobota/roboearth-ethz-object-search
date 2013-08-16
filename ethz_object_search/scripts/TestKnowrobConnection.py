#!/usr/bin/env python
'''
Created on May 15, 2013

@author: okankoc
'''

import roslib; roslib.load_manifest('json_prolog')

import rospy
import json_prolog


def main():
    try:
        rospy.init_node('test_json_prolog')
        prolog = json_prolog.Prolog()
        query = prolog.query("member(A, [1, 2, 3, 4]), B = ['x', A]")
        for solution in query.solutions():
            print 'Found solution. A = %s, B = %s' % (solution['A'], solution['B'])
        query.finish()
    except rospy.ROSInterruptException:
            pass


if __name__ == '__main__':
    main()
