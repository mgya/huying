//
//  MapViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/10/26.
//  Copyright © 2015年 yfCui. All rights reserved.
//

#import "MapViewController.h"





@interface MapViewController (){
    BMKMapView * _mapView;
    
    BMKLocationService* _locService;
    
    BMKGeoCodeSearch* _geocodesearch;
    
    CLLocationCoordinate2D myLocation;
    
    BMKPointAnnotation* pointAnnotation;
    
    NSString *title;
    
    UIButton *buttonMore;
    
}

@end



@implementation MapViewController

@synthesize coordinate;
@synthesize address;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    
    //发送
    buttonMore = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-32, (NAVI_HEIGHT-40)/2, 32, 40)];
    buttonMore.backgroundColor = [UIColor clearColor];
    buttonMore.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [buttonMore setTitle:@"发送" forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(pushLocation) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:buttonMore];
    if (coordinate.longitude != 0 && coordinate.latitude != 0) {
        self.navTitleLabel.text = @"当前位置";

    }else{
        self.navTitleLabel.text = @"获取位置中....";
    }

    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth,KDeviceHeight - LocationY)];
    
    _mapView.zoomLevel = 18;
    
    [self.view addSubview:_mapView];
    
      _locService = [[BMKLocationService alloc]init];
    
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];

}


-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    buttonMore.hidden = YES;
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    if (coordinate.longitude == 0 && coordinate.latitude == 0) {
        [_locService startUserLocationService];
    }else{
        myLocation = coordinate;
        title = address;
        [self addPointAnnotation];
    }

    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    [MobClick beginLogPageView:@"MapViewController"];

}



-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时，置nil
    [MobClick endLogPageView:@"MapViewController"];

}


//逆地理编码
-(void)reverseGeocode
{
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    pt = (CLLocationCoordinate2D){myLocation.latitude, myLocation.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        _mapView.centerCoordinate = result.location;
        
        title = result.address;
        buttonMore.hidden = NO;
        [self addPointAnnotation];
        
    }
}


-(void)returnLastPage{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];

    if (userLocation.location != nil) {
        _mapView.centerCoordinate = userLocation.location.coordinate;
        myLocation = userLocation.location.coordinate;
        [_locService stopUserLocationService];
        [self reverseGeocode];
    }

}


//添加标注
- (void)addPointAnnotation
{
    if (pointAnnotation == nil) {
        pointAnnotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = myLocation.latitude;
        coor.longitude = myLocation.longitude;
        pointAnnotation.coordinate = coor;
        pointAnnotation.title = title;

    }
    [_mapView addAnnotation:pointAnnotation];
    _mapView.centerCoordinate = myLocation;
}

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //普通annotation
    if (annotation == pointAnnotation) {
        NSString *AnnotationViewID = @"renameMark";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            // 设置颜色
            annotationView.pinColor = BMKPinAnnotationColorPurple;
            [annotationView setSelected:YES animated:YES];
        }
        if (coordinate.latitude == 0 && coordinate.longitude == 0) {
            self.navTitleLabel.text = @"我的位置";
        }
        return annotationView;
    }
    return nil;
}

-(void)pushLocation{
    
    if (self.delegate  && [self.delegate  respondsToSelector:@selector(locationInfo:location:)]) {
        [self.delegate locationInfo:title location:myLocation];
    }

    [self returnLastPage];

}


-(void)test:(NSString*)a{
    NSLog(@"%@",a);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
