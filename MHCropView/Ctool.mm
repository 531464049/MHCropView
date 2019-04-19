//
//  Ctool.m
//  CPlusPlusTest
//
//  Created by 小沫 on 16/2/22.
//  Copyright © 2016年 小沫. All rights reserved.
//

#import "Ctool.h"

CPoint::CPoint(void)
{
    x = 0.0;
    
    y = 0.0;
}

CPoint::CPoint( double x, double y )
{
    this->x = x;
    this->y = y;
}

static CPoint PointSub( const CPoint& fir, const CPoint& sec )
{
    return CPoint( fir.x - sec.x, fir.y - sec.y );
}

static double PointCrossPow( const CPoint& fir, const CPoint& sec )
{
    return fir.x * 1.0 * sec.y - sec.x * 1.0 * fir.y;
}


BOOL LineIntersects( const CPoint& s1, const CPoint& e1, const CPoint& s2, const CPoint& e2 )
{
    if ( fmax( s1.x, e1.x ) < fmin( s2.x, e2.x )//测试外包，右上点与坐下点比较
        || fmax( s1.y, e1.y ) < fmin( s2.y, e2.y )
        || fmin( s1.x, e1.x ) > fmax( s2.x, e2.x )//左下点和右上点比较
        || fmin( s1.y, e1.y ) > fmax( s2.y, e2.y ) )
    {
        return FALSE;
    }
    
    //通过外包排斥
    //利用跨立实验（地理信息系统算法)
    double pow1 = PointCrossPow( PointSub( s1, s2 ), PointSub( e2, s2 ) ) *
    PointCrossPow( PointSub( e2, s2 ), PointSub( e1, s2 ) );
    
    double pow2 = PointCrossPow( PointSub( s2, s1 ), PointSub( e1, s1 ) ) *
    PointCrossPow( PointSub( e1, s1 ), PointSub( e2, s1 ) );
    
    if ( pow1 >= 0.0 && pow2 >= 0.0 )
    {
        return TRUE;
    }
    return FALSE;
}
