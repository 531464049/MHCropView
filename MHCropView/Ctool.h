//
//  Ctool.h
//  CPlusPlusTest
//
//  Created by 小沫 on 16/2/22.
//  Copyright © 2016年 小沫. All rights reserved.
//

#import <Foundation/Foundation.h>

class CPoint
{
public:
    double x;
    double y;
    
    CPoint(void);
    CPoint( double x, double y );
};

BOOL LineIntersects( const CPoint& s1, const CPoint& e1, const CPoint& s2, const CPoint& e2 );