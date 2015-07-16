//
//  MainViewController.m
//  UISearchDisplayControllerDemo
//
//  Created by Enwaysoft on 14-8-20.
//  Copyright (c) 2014年 Enway. All rights reserved.
//

#import "QSearchViewController.h"

@interface QSearchViewController ()

@property CLGeocoder *geocoder;
@property UISearchBar *searchBar;
@property UITableView *resultTableview;

@end

@implementation QSearchViewController



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationItem.title=@"目的地搜索";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(quitsearching:)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.delegate=self;
    _searchBar.placeholder = @"点击搜索";
    self.tableView.tableHeaderView = _searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    recordData=[[NSMutableArray alloc]init];
    searchResults=[[NSDictionary alloc]init];
    Resultarray=[[NSMutableArray alloc]init];
    Resultname=[[NSMutableArray alloc]init];
    Resultaddr=[[NSMutableArray alloc]init];
    
    _geocoder = [[CLGeocoder alloc] init];
}


-(void)quitsearching:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
 * 如果原 TableView 和 SearchDisplayController 中的 TableView 的 delete 指向同一个对象
 * 需要在回调中区分出当前是哪个 TableView
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return recordData.count;
    }else{
        return Resultarray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"mycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    if (tableView == self.tableView) {
        cell.textLabel.text = recordData[indexPath.row];
    }else{
        cell.imageView.image=[UIImage imageNamed:@"anjuke_icon_itis_position"];
        cell.textLabel.text=Resultname[indexPath.row];
        cell.detailTextLabel.text=Resultaddr[indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"number:%d",Resultarray.count);
    
    NSMutableDictionary *thisresult=[Resultarray objectAtIndex:indexPath.row];
    NSDictionary *localtion=[thisresult objectForKey:@"location"];
    
    //NSLog(@"xxx:%@,%@,%@",[thisresult objectForKey:@"address"],[localtion objectForKey:@"lat"],(NSString *)[thisresult objectForKey:@"name"]);
    
    NSMutableDictionary *navidic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                [thisresult objectForKey:@"address"],@"address",
                                [thisresult objectForKey:@"address"],@"city",
                                @"baidu",@"from_map_type",
                                [NSString stringWithFormat:@"%@",[localtion objectForKey:@"lat"]],@"baidu_lat",
                                [NSString stringWithFormat:@"%@",[localtion objectForKey:@"lng"]],@"baidu_lng",
                                [thisresult objectForKey:@"name"],@"region", nil];
    [self.delegate updateAlert:navidic];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    NSLog(@"Begin search");
}

-(void)requestforplace:(NSString*)string{
    /*
    NSLog(@"查询位置信息:%@",string);
    [_geocoder geocodeAddressString:string completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"%@",placemarks);
        if ([placemarks count] > 0 && error == nil){
            NSLog(@"Found %lu placemark(s).", (unsigned long)[placemarks count]);
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            NSLog(@"Longitude = %f", firstPlacemark.location.coordinate.longitude);
            NSLog(@"Latitude = %f", firstPlacemark.location.coordinate.latitude);
            NSLog(@"name = %@",firstPlacemark.name);
            NSLog(@"city = %@",firstPlacemark.locality);
            NSLog(@"addr = %@",firstPlacemark.subLocality);
            
            [searchResult removeAllObjects];
            [Resultname removeAllObjects];
            [Resultaddr removeAllObjects];
            
            for(CLPlacemark *Placemark in placemarks){
                [searchResult addObject:Placemark];
                [Resultname addObject:Placemark.name];
                [Resultaddr addObject:@"xxxx"];
            }
            [searchDisplayController.searchResultsTableView reloadData];
        }
        else if ([placemarks count] == 0 && error == nil){
            NSLog(@"Found no placemarks.");
        }
        else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
    }];
    */
    NSString *urlstr=[NSString stringWithFormat:@"http://api.map.baidu.com/place/search"];
    
    NSDictionary *searchdic=[NSDictionary dictionaryWithObjectsAndKeys:
                       string, @"query",
                       self.city, @"region",
                       @"json", @"output",
                       @"bqApldE1oh6oBb98VYyIfy9S", @"key",nil];
    
    [[ShenAFN shenInstance] JSONDataWithUrl:urlstr parameter:searchdic success:^(id jsondata) {
        //NSLog(@"%@",jsondata);
        [Resultarray removeAllObjects];
        [Resultname removeAllObjects];
        [Resultaddr removeAllObjects];
        
         NSString *status=(NSString *)jsondata[@"status"];
         if([status isEqualToString:@"OK"]){
             searchResults=jsondata[@"results"];

             for(NSDictionary *thisresult in searchResults){
                 if([thisresult objectForKey:@"address"]!=nil){
                     [Resultarray addObject:thisresult];
                     [Resultname addObject:[thisresult objectForKey:@"name"]];
                     [Resultaddr addObject:[thisresult objectForKey:@"address"]];
                 }
             }
             [searchDisplayController.searchResultsTableView reloadData];
          }
    } fail:^{
        NSLog(@"请求失败");
    }];

    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self requestforplace:searchText];
}
@end
